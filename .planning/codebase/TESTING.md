# Testing Patterns

**Analysis Date:** 2026-02-07

## Test Framework

**Runner:**
- pytest (Python) configured in `pyproject.toml`
  - Config: `testpaths = ["use-cases/pydantic-ai"]`
  - asyncio_mode = "auto" for async test support
  - Options: `-v --tb=short` for verbose output with short tracebacks
- vitest (TypeScript) for MCP server and Cloudflare Workers
  - Config: `vitest.config.ts` in respective projects
  - Used in `use-cases/mcp-server/tests/`

**Assertion Library:**
- Python: pytest built-in assertions (e.g., `assert result.output.message is not None`)
- TypeScript: vitest expect API (e.g., `expect(result.isValid).toBe(true)`)

**Run Commands:**
```bash
# Python - Run all tests in use-cases/pydantic-ai
pytest                          # Run all tests
pytest -v                       # Verbose output
pytest --tb=short              # Short traceback format
pytest -k "test_name"          # Run specific test by name
pytest --lf                    # Run last failed tests
pytest use-cases/pydantic-ai   # Run specific directory

# TypeScript - Run MCP server tests
cd use-cases/mcp-server
npm test                       # Run vitest
npm run test:watch            # Watch mode
npm run type-check            # TypeScript checking
```

## Test File Organization

**Location:**

**Python:**
- Tests co-located with source in same directory structure
- Pattern: `test_*.py` or `*_test.py` files alongside module files
- Example: `use-cases/pydantic-ai/examples/testing_examples/test_agent_patterns.py`

**TypeScript:**
- Tests in parallel `tests/` directory structure
- Pattern: `tests/unit/`, `tests/fixtures/`, `tests/mocks/`
- Example: `use-cases/mcp-server/tests/unit/database/security.test.ts`
- Fixtures in: `tests/fixtures/` (e.g., `database.fixtures.ts`, `auth.fixtures.ts`)
- Mocks in: `tests/mocks/` (e.g., `database.mock.ts`, `oauth.mock.ts`)

**Naming:**
- Python: `test_<feature>.py` or `<feature>_test.py` (e.g., `test_agent_patterns.py`)
- TypeScript: `<module>.test.ts` (e.g., `security.test.ts`, `response-helpers.test.ts`)

**Directory Structure:**
```
use-cases/pydantic-ai/
├── examples/
│   ├── testing_examples/
│   │   └── test_agent_patterns.py
│   └── main_agent_reference/
│       ├── models.py
│       ├── tools.py
│       └── settings.py

use-cases/mcp-server/
├── src/
│   ├── index.ts
│   ├── database.ts
│   └── tools/
├── tests/
│   ├── setup.ts
│   ├── fixtures/
│   │   ├── auth.fixtures.ts
│   │   └── database.fixtures.ts
│   ├── mocks/
│   │   ├── database.mock.ts
│   │   └── oauth.mock.ts
│   └── unit/
│       ├── database/
│       │   ├── security.test.ts
│       │   └── utils.test.ts
│       └── utils/
│           └── response-helpers.test.ts
```

## Test Structure

**Suite Organization (Python):**

```python
"""
Comprehensive PydanticAI Testing Examples

Demonstrates testing patterns and best practices for PydanticAI agents:
- TestModel for fast development validation
- Agent.override() for test isolation
- Pytest fixtures and async testing
- Tool validation and error handling tests
"""

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
        assert result.output.message is not None
        assert isinstance(result.output.confidence, float)


class TestAgentTools:
    """Test agent tool functionality."""

    @pytest.mark.asyncio
    async def test_database_tool_execution(self, mock_dependencies):
        """Test database tool gets executed when requested."""
        test_model = TestModel(call_tools=["mock_database_query"])

        with test_agent.override(model=test_model):
            result = await test_agent.run(
                "Please query the database for user data", deps=mock_dependencies
            )

            mock_dependencies.database.execute_query.assert_called()
            assert result.output is not None
```

**Suite Organization (TypeScript):**

```typescript
describe('Database Security', () => {
  describe('validateSqlQuery', () => {
    it('should validate safe SELECT queries', () => {
      const result = validateSqlQuery(validSelectQuery)
      expect(result.isValid).toBe(true)
      expect(result.error).toBeUndefined()
    })

    it('should reject dangerous DROP queries', () => {
      const result = validateSqlQuery(dangerousDropQuery)
      expect(result.isValid).toBe(false)
      expect(result.error).toBe('Query contains potentially dangerous SQL patterns')
    })
  })
})
```

**Patterns:**

**Python Setup/Teardown:**
```python
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
```

**TypeScript Setup/Teardown:**
```typescript
describe('Feature', () => {
  let dependencies: MockDependencies

  beforeEach(() => {
    dependencies = createMockDependencies()
  })

  afterEach(() => {
    // Cleanup if needed
  })

  it('should do something', () => {
    // test body
  })
})
```

**Assertion patterns:**

**Python:**
```python
assert result.output.message is not None
assert isinstance(result.output.confidence, float)
assert isinstance(result.output.actions, list)
```

**TypeScript:**
```typescript
expect(result.isValid).toBe(true)
expect(result.error).toBeUndefined()
expect(result.data).toEqual(expectedData)
expect(callSpy).toHaveBeenCalled()
```

## Mocking

**Framework:**
- Python: `unittest.mock` (built-in) and `pytest-mock` plugin
- TypeScript: vitest built-in mocking capabilities

**Patterns:**

**Python mocking:**
```python
from unittest.mock import Mock, AsyncMock

# Synchronous mock
api_mock = Mock()
api_mock.post.return_value = {"status": "success"}

# Asynchronous mock
database_mock = AsyncMock()
database_mock.execute_query.return_value = "Test data"
database_mock.execute_query.side_effect = Exception("Connection failed")

# Verify calls
mock_dependencies.database.execute_query.assert_called()
mock_dependencies.api_client.post.assert_called_with(endpoint, json=data)
```

**TypeScript mocking:**
```typescript
import { vi } from 'vitest'

const mockDatabase = {
  query: vi.fn().mockResolvedValue([{ id: 1, name: 'Test' }]),
  execute: vi.fn().mockRejectedValue(new Error('DB Error')),
}

// Verify calls
expect(mockDatabase.query).toHaveBeenCalledWith(expectedQuery)
```

**What to Mock:**
- External API calls (Brave Search, GitHub OAuth)
- Database operations
- File system operations
- Network requests
- Time-dependent operations (use time mocking)

**What NOT to Mock:**
- Core business logic
- Pydantic validation
- Type validation (Zod in TS)
- Agent model selection (use TestModel instead)
- Error handling that's part of the contract

## Fixtures and Factories

**Test Data (Python):**

```python
@dataclass
class AgentTestDependencies:
    """Dependencies for agent testing."""
    database: Mock
    api_client: Mock
    user_id: str = "test_user_123"


class AgentTestResponse(BaseModel):
    """Response model for validation."""
    message: str
    confidence: float = 0.8
    actions: List[str] = []


@pytest.fixture
def test_dependencies():
    """Create mock dependencies for testing."""
    return AgentTestDependencies(
        database=AsyncMock(), api_client=Mock(), user_id="test_user_123"
    )
```

**Test Data (TypeScript):**

```typescript
// tests/fixtures/database.fixtures.ts
export const validSelectQuery = 'SELECT * FROM users WHERE id = $1'
export const validInsertQuery = 'INSERT INTO users (name) VALUES ($1)'
export const dangerousDropQuery = 'SELECT * FROM users; DROP TABLE users;'
export const maliciousInjectionQuery = "SELECT * FROM users WHERE id = '1'; DELETE FROM users;"

// tests/fixtures/auth.fixtures.ts
export const createMockAuthContext = (overrides?: Partial<AuthContext>) => ({
  login: 'testuser',
  email: 'test@example.com',
  accessToken: 'mock-token',
  ...overrides,
})
```

**Location:**
- Python: In the test file itself using `@pytest.fixture` decorator
- TypeScript: `tests/fixtures/` directory with named exports

## Coverage

**Requirements:**
- No enforced minimum coverage threshold in config
- Aim for 70%+ coverage for critical paths
- Focus on edge cases and error handling rather than line coverage

**View Coverage:**
```bash
# Python - Generate coverage report
pytest --cov=use-cases/pydantic-ai --cov-report=html --cov-report=term

# TypeScript - If configured
npm run test:coverage
```

**Coverage targets:**
- Critical business logic: 90%+
- Helper functions and utilities: 70%+
- Configuration and initialization: 50%+
- Error handling and recovery: 80%+

## Test Types

**Unit Tests:**

**Scope and Approach (Python):**
```python
class TestAgentTools:
    """Test individual tool functions in isolation."""

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
```

**Scope and Approach (TypeScript):**
```typescript
describe('Database Security', () => {
  it('should reject empty queries', () => {
    const result = validateSqlQuery('')
    expect(result.isValid).toBe(false)
    expect(result.error).toBe('SQL query cannot be empty')
  })

  it('should identify INSERT as write operation', () => {
    expect(isWriteOperation('INSERT INTO users (name) VALUES ($1)')).toBe(true)
  })
})
```

**Integration Tests:**

**Scope and Approach (Python):**
```python
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
```

**E2E Tests:**
- Not present in codebase currently
- Would use local `wrangler dev` for TypeScript/MCP servers
- Would use actual deployed endpoints for Python services if needed

## Common Patterns

**Async Testing (Python):**

```python
@pytest.mark.asyncio
async def test_async_operation(self, mock_dependencies):
    """Test asynchronous operations."""
    test_model = TestModel(call_tools=["mock_database_query"])

    with test_agent.override(model=test_model):
        result = await test_agent.run(
            "Please query the database", deps=mock_dependencies
        )

        assert result.output is not None
        mock_dependencies.database.execute_query.assert_called()
```

**Async Testing (TypeScript):**

```typescript
it('should execute async query', async () => {
  const result = await queryDatabase('SELECT * FROM users')
  expect(result).toEqual(expectedData)
})
```

**Error Testing (Python):**

```python
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
```

**Error Testing (TypeScript):**

```typescript
describe('Error Handling', () => {
  it('should handle database connection errors', async () => {
    const mockDb = {
      query: vi.fn().mockRejectedValue(new Error('Connection timeout')),
    }

    const result = await withDatabase(mockDb, async (db) => {
      return await db.query('SELECT *')
    })

    expect(result.error).toContain('Connection timeout')
    expect(result.success).toBe(false)
  })

  it('should validate SQL injection attempts', () => {
    const result = validateSqlQuery("SELECT * FROM users; DROP TABLE users;")
    expect(result.isValid).toBe(false)
    expect(result.error).toBe('Query contains potentially dangerous SQL patterns')
  })
})
```

## PydanticAI Testing Specifics

**Using TestModel:**
```python
# TestModel enables fast testing without API keys
test_agent = Agent(
    model=TestModel(),  # Use TestModel for testing without API keys
    deps_type=AgentTestDependencies,
    output_type=AgentTestResponse,
    system_prompt="You are a helpful test assistant.",
)

# TestModel returns structured output matching output_type
result = test_agent.run_sync("Test message", deps=test_dependencies)
assert result.output.message is not None
```

**Agent.override() for Test Isolation:**
```python
# Override model for specific test
test_model = TestModel(call_tools=["mock_database_query"])

with test_agent.override(model=test_model):
    result = await test_agent.run("Query the database", deps=mock_dependencies)
    # Only specified tools will be called in this block
```

**Tool Testing Pattern:**
```python
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

# Test the tool
def test_api_tool_execution(self, mock_dependencies):
    """Test API tool gets executed when requested."""
    test_model = TestModel(call_tools=["mock_api_call"])

    with test_agent.override(model=test_model):
        result = test_agent.run_sync(
            "Make an API call to create a new record", deps=mock_dependencies
        )

        mock_dependencies.api_client.post.assert_called()
        assert result.output is not None
```

## TypeScript/MCP Testing Patterns

**Setup File:**
```typescript
// tests/setup.ts
import { beforeAll, afterAll } from 'vitest'

beforeAll(() => {
  // Setup test environment
})

afterEach(() => {
  // Clear mocks between tests
})
```

**Mocking MCP Tools:**
```typescript
const mockMcpServer = {
  tool: vi.fn(),
  resource: vi.fn(),
}

// Verify tool was registered correctly
expect(mockMcpServer.tool).toHaveBeenCalledWith(
  'queryDatabase',
  expect.any(String),
  expect.any(Object),
  expect.any(Function)
)
```

---

*Testing analysis: 2026-02-07*
