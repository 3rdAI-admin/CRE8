"""
Comprehensive PydanticAI Testing Examples

Demonstrates testing patterns and best practices for PydanticAI agents:
- TestModel for fast development validation
- Agent.override() for test isolation
- Pytest fixtures and async testing
- Tool validation and error handling tests
"""

import pytest
from unittest.mock import Mock, AsyncMock
from dataclasses import dataclass
from typing import Optional, List
from pydantic import BaseModel
from pydantic_ai import Agent, RunContext
from pydantic_ai.models.test import TestModel


@dataclass
class AgentTestDependencies:
    """Dependencies for agent testing (renamed to avoid pytest collection)."""

    database: Mock
    api_client: Mock
    user_id: str = "test_user_123"


class AgentTestResponse(BaseModel):
    """Response model for validation (renamed to avoid pytest collection)."""

    message: str
    confidence: float = 0.8
    actions: List[str] = []


# Create test agent with TestModel to avoid requiring API keys at import time
test_agent = Agent(
    model=TestModel(),  # Use TestModel for testing without API keys
    deps_type=AgentTestDependencies,
    output_type=AgentTestResponse,
    system_prompt="You are a helpful test assistant.",
)


@test_agent.tool
async def mock_database_query(
    ctx: RunContext[AgentTestDependencies], query: str
) -> str:
    """Mock database query tool for testing."""
    try:
        result = await ctx.deps.database.execute_query(query)
        return f"Database result: {result}"
    except Exception as e:
        return f"Database error: {str(e)}"


@test_agent.tool
def mock_api_call(
    ctx: RunContext[AgentTestDependencies], endpoint: str, data: Optional[dict] = None
) -> str:
    """Mock API call tool for testing."""
    try:
        response = ctx.deps.api_client.post(endpoint, json=data)
        return f"API response: {response}"
    except Exception as e:
        return f"API error: {str(e)}"


class TestAgentBasics:
    """Test basic agent functionality with TestModel."""

    @pytest.fixture
    def test_dependencies(self):
        """Create mock dependencies for testing."""
        return AgentTestDependencies(
            database=AsyncMock(), api_client=Mock(), user_id="test_user_123"
        )

    def test_agent_with_test_model(self, test_dependencies):
        """Test agent behavior with TestModel."""
        result = test_agent.run_sync(
            "Hello, please help me with a simple task.", deps=test_dependencies
        )

        # TestModel returns structured output matching output_type
        assert result.output.message is not None
        assert isinstance(result.output.confidence, float)
        assert isinstance(result.output.actions, list)

    @pytest.mark.asyncio
    async def test_agent_async_with_test_model(self, test_dependencies):
        """Test async agent behavior with TestModel."""
        result = await test_agent.run("Async test message", deps=test_dependencies)

        assert result.output.message is not None
        assert result.output.confidence >= 0.0


class TestAgentTools:
    """Test agent tool functionality."""

    @pytest.fixture
    def mock_dependencies(self):
        """Create mock dependencies with configured responses."""
        database_mock = AsyncMock()
        database_mock.execute_query.return_value = "Test data from database"

        api_mock = Mock()
        api_mock.post.return_value = {"status": "success", "data": "test_data"}

        return AgentTestDependencies(
            database=database_mock, api_client=api_mock, user_id="test_user_456"
        )

    @pytest.mark.asyncio
    async def test_database_tool_execution(self, mock_dependencies):
        """Test database tool gets executed when requested."""
        test_model = TestModel(call_tools=["mock_database_query"])

        with test_agent.override(model=test_model):
            result = await test_agent.run(
                "Please query the database for user data", deps=mock_dependencies
            )

            # Verify database was called
            mock_dependencies.database.execute_query.assert_called()
            # Verify we got a valid response
            assert result.output is not None

    @pytest.mark.asyncio
    async def test_database_tool_error_handling(self, mock_dependencies):
        """Test database tool handles errors gracefully."""
        mock_dependencies.database.execute_query.side_effect = Exception(
            "Connection failed"
        )

        test_model = TestModel(call_tools=["mock_database_query"])

        with test_agent.override(model=test_model):
            result = await test_agent.run("Query the database", deps=mock_dependencies)

            # Tool should handle the error and agent still returns valid response
            assert result.output is not None

    def test_api_tool_execution(self, mock_dependencies):
        """Test API tool gets executed when requested."""
        test_model = TestModel(call_tools=["mock_api_call"])

        with test_agent.override(model=test_model):
            result = test_agent.run_sync(
                "Make an API call to create a new record", deps=mock_dependencies
            )

            # Verify API was called
            mock_dependencies.api_client.post.assert_called()
            assert result.output is not None


class TestAgentIntegration:
    """Integration tests for complete agent workflows."""

    @pytest.fixture
    def full_mock_dependencies(self):
        """Create fully configured mock dependencies."""
        database_mock = AsyncMock()
        database_mock.execute_query.return_value = {
            "user_id": "123",
            "name": "Test User",
            "status": "active",
        }

        api_mock = Mock()
        api_mock.post.return_value = {
            "status": "success",
            "transaction_id": "txn_123456",
        }

        return AgentTestDependencies(
            database=database_mock, api_client=api_mock, user_id="test_integration_user"
        )

    @pytest.mark.asyncio
    async def test_complete_workflow(self, full_mock_dependencies):
        """Test complete agent workflow with multiple tools."""
        test_model = TestModel(call_tools="all")  # Call all available tools

        with test_agent.override(model=test_model):
            result = await test_agent.run(
                "Please look up user information and create a new transaction",
                deps=full_mock_dependencies,
            )

            # Verify response is valid
            assert result.output.message is not None
            assert isinstance(result.output.actions, list)

            # Verify mocks were called
            full_mock_dependencies.database.execute_query.assert_called()
            full_mock_dependencies.api_client.post.assert_called()


class TestAgentErrorRecovery:
    """Test agent error handling and recovery patterns."""

    @pytest.fixture
    def failing_dependencies(self):
        """Create dependencies that will fail for testing error handling."""
        database_mock = AsyncMock()
        database_mock.execute_query.side_effect = Exception(
            "Database connection failed"
        )

        api_mock = Mock()
        api_mock.post.side_effect = Exception("API service unavailable")

        return AgentTestDependencies(
            database=database_mock, api_client=api_mock, user_id="failing_test_user"
        )

    @pytest.mark.asyncio
    async def test_tool_error_recovery(self, failing_dependencies):
        """Test agent behavior when tools fail."""
        test_model = TestModel(call_tools="all")

        with test_agent.override(model=test_model):
            # Agent should handle tool failures gracefully
            result = await test_agent.run(
                "Try to access database and API", deps=failing_dependencies
            )

            # Even with tool failures, agent should return a valid response
            assert result.output.message is not None
            assert isinstance(result.output.confidence, float)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
