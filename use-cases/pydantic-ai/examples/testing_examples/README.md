# Testing Examples

Comprehensive testing patterns and best practices for PydanticAI agents.

## Features

- TestModel for fast development validation
- FunctionModel for custom behavior testing
- Agent.override() for test isolation
- Pytest fixtures and async testing
- Tool validation and error handling tests

## Files

| File | Description |
|------|-------------|
| `test_agent_patterns.py` | Comprehensive test examples |
| `conftest.py` | Pytest fixtures and configuration |
| `pytest.ini` | Pytest settings |

## Test Categories

### 1. TestModel Testing
Fast, deterministic tests without API calls:

```python
from pydantic_ai.models.test import TestModel

async def test_with_test_model():
    with agent.override(model=TestModel()):
        result = await agent.run("test input")
        assert result.data.message == "success"
```

### 2. Mock Dependencies
Test with mocked external services:

```python
from unittest.mock import Mock, AsyncMock

deps = TestDependencies(
    database=AsyncMock(return_value="mock data"),
    api_client=Mock()
)
result = await agent.run("query", deps=deps)
```

### 3. Tool Testing
Validate tool behavior in isolation:

```python
async def test_tool_error_handling():
    deps = TestDependencies(database=AsyncMock(side_effect=Exception("DB Error")))
    result = await mock_database_query(ctx, "SELECT *")
    assert "error" in result.lower()
```

## Running Tests

```bash
cd use-cases/pydantic-ai/examples/testing_examples

# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test
pytest test_agent_patterns.py::test_basic_agent_response
```

## Key Patterns Demonstrated

1. **Test Isolation**: `agent.override()` for deterministic behavior
2. **Async Testing**: `@pytest.mark.asyncio` for async agent tests
3. **Mock Dependencies**: Dataclass-based dependency injection
4. **Error Simulation**: `AsyncMock(side_effect=Exception(...))` for error paths
5. **Response Validation**: Pydantic model assertions on structured output
