# Coding Conventions

**Analysis Date:** 2026-02-07

## Naming Patterns

**Files:**
- `snake_case.py` for Python modules (e.g., `research_agent.py`, `tools.py`, `models.py`)
- `camelCase.ts` for TypeScript files (e.g., `github-handler.ts`, `database-tools.ts`)
- Directories use `snake_case` (e.g., `use-cases/`, `pydantic-ai/`, `src/`)
- Test files: `test_*.py` or `*_test.py` for Python; `*.test.ts` for TypeScript
- Models and classes: `PascalCase` (e.g., `ResearchQuery`, `EmailDraft`, `SessionState`)

**Functions:**
- Python functions: `snake_case` (e.g., `search_web_tool()`, `validate_api_keys()`)
- Async Python functions: `async def snake_case(...)` (e.g., `async def search_web(...)`)
- TypeScript functions: `camelCase` for exported, `PascalCase` for constructors
- Tool registration functions: `register*Tools` pattern (e.g., `registerDatabaseTools`, `registerAllTools`)

**Variables:**
- Python: `snake_case` (e.g., `api_key`, `brave_api_key`, `conversation_history`)
- TypeScript: `camelCase` (e.g., `clientId`, `accessToken`, `databaseUrl`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `ALLOWED_USERNAMES`, `MAX_RESULTS`)
- Private members: prefix with underscore (Python pattern: `_private_var`)

**Types:**
- Pydantic models: `PascalCase` ending with intended suffix (e.g., `ResearchQuery`, `EmailDraft`, `BraveSearchResult`)
- TypeScript interfaces/types: `PascalCase` (e.g., `Props`, `Env`)
- Zod schemas: `PascalSchema` or inline objects with `z.object()`
- Dataclasses (Python): `PascalCase` (e.g., `AgentTestDependencies`)

## Code Style

**Formatting:**
- Python: Use `ruff` for formatting and linting
  - Line length: 88 characters (configured in `pyproject.toml`)
  - Quote style: double quotes (configured in `pyproject.toml`)
  - Python 3.11+ target version
- TypeScript: Use `prettier` for formatting
  - Semi-colons: included
  - Quote style: single quotes (Prettier default for TS)
  - Configured in `.pre-commit-config.yaml`

**Linting:**
- Python: `ruff` linter with auto-fix enabled
  - Runs on files matching `^use-cases/(pydantic-ai|agent-factory-with-subagents)/.*\.py$`
  - Configuration in `pyproject.toml` with line-length=88
- TypeScript: `prettier` for formatting and `eslint` where applicable
  - Runs on MCP server files matching `^use-cases/mcp-server/.*\.(ts|tsx|js|jsx|json)$`

**Pre-commit hooks:**
- Automatic formatting on commit via `.pre-commit-config.yaml`
- Python: ruff lint + ruff format
- TypeScript: prettier formatting
- Commit messages: conventional commits with required scope (`--force-scope`)

## Import Organization

**Order (Python):**
1. Standard library imports (e.g., `import os`, `import asyncio`)
2. Third-party imports (e.g., `from pydantic import BaseModel`, `import httpx`)
3. Local imports (e.g., `from .models import ResearchQuery`)

**Order (TypeScript):**
1. Node.js built-ins (e.g., `import fs from "fs"`)
2. Third-party packages (e.g., `import { McpServer } from "@modelcontextprotocol/sdk"`)
3. Local imports with relative paths (e.g., `import { Props } from "../types"`)

**Path Aliases:**
- Python: Uses relative imports within packages (e.g., `from .settings import settings`)
- TypeScript: Configured in `tsconfig.json`; common aliases include project-relative paths

**Barrel Files:**
- Python: `__init__.py` files used for package-level exports (e.g., `from agents import research_agent`)
- TypeScript: Index files used for re-exporting (e.g., `export * from "./tools"`)

## Error Handling

**Patterns:**

**Python:**
```python
# Validation errors - raise ValueError for invalid input
if not query or not query.strip():
    raise ValueError("Query cannot be empty")

# API errors - wrap external service errors
try:
    response = await client.get(url)
    if response.status_code == 429:
        raise Exception("Rate limit exceeded")
    if response.status_code != 200:
        raise Exception(f"API returned {response.status_code}")
except httpx.RequestError as e:
    logger.error(f"Request error: {e}")
    raise Exception(f"Request failed: {str(e)}")
```

**TypeScript/MCP:**
```typescript
// MCP tools return structured error responses
try {
  const result = await processData(input);
  return {
    content: [{
      type: "text",
      text: `**Success**\n\nResult: ${JSON.stringify(result)}`,
    }],
  };
} catch (error) {
  return {
    content: [{
      type: "text",
      text: `**Error**\n\n${error instanceof Error ? error.message : String(error)}`,
      isError: true,
    }],
  };
}
```

**Input Validation:**
- Python: Pydantic `BaseModel` with `Field()` validators
- TypeScript: Zod schemas with `.refine()` for custom validation (required in MCP server)

## Logging

**Framework:**
- Python: Built-in `logging` module with `logger = logging.getLogger(__name__)`
- TypeScript: Console logging with structured output, optional Sentry integration

**Patterns:**

**Python logging:**
```python
logger = logging.getLogger(__name__)
logger.info(f"Searching Brave for: {query}")
logger.error(f"Request error during search: {e}")
```

**TypeScript console output:**
```typescript
console.log("Database connections closed successfully");
console.error("Error during database cleanup:", error);
```

**Sentry integration (optional in MCP server):**
```typescript
Sentry.setUser({
  username: this.props.login,
  email: this.props.email,
});
Sentry.startSpan({
  name: `mcp.tool/${name}`,
  attributes: extractMcpParameters(args),
}, async (span) => {
  // tool execution
});
```

## Comments

**When to Comment:**
- Non-obvious business logic requiring explanation
- Complex async/await flows or race conditions
- Security-sensitive operations (validation, auth, permission checks)
- Workarounds or temporary solutions with explanation of why
- Important gotchas or known limitations

**JSDoc/TSDoc:**
- Python: Google-style docstrings for all public functions
- TypeScript: JSDoc comments for exported functions and classes
- Not required for trivial getters/setters

**Example patterns:**

**Python docstring:**
```python
def search_web_tool(
    api_key: str,
    query: str,
    count: int = 10,
) -> List[Dict[str, Any]]:
    """
    Pure function to search the web using Brave Search API.

    Args:
        api_key: Brave Search API key
        query: Search query
        count: Number of results to return (1-20)

    Returns:
        List of search results as dictionaries

    Raises:
        ValueError: If query is empty or API key missing
        Exception: If API request fails
    """
```

**TypeScript JSDoc:**
```typescript
/**
 * Cleanup database connections when Durable Object is shutting down
 */
async cleanup(): Promise<void> {
  // implementation
}
```

## Function Design

**Size:**
- Python: Keep functions under 50 lines where possible
- TypeScript: Keep functions under 40 lines (tools return structured responses)
- Tools in MCP server: Single tool per handler, return standardized response object

**Parameters:**
- Python: Use `Optional[]` for optional params, provide defaults
- TypeScript: Use `?: type` for optional, provide defaults
- Dependencies: Use dependency injection (Python `@dataclass`, TypeScript constructor or passed args)
- MCP tools: Use Zod schema for parameter validation, leverage automatic validation

**Return Values:**
- Python: Type hint all returns (e.g., `-> List[Dict[str, Any]]`)
- TypeScript: Type hint all returns (e.g., `Promise<void>`, MCP tools return response objects)
- Python agents: Return string output by default unless structured output needed (use `output_type` sparingly)
- MCP tools: Always return `{content: [{type: "text", text: string}]}` or with `isError: true`

## Module Design

**Exports:**
- Python: Use `from module import function` pattern, avoid `from module import *`
- TypeScript: Named exports preferred, barrel files re-export grouped functionality
- MCP tools: Export registration functions (e.g., `registerDatabaseTools`)

**Barrel Files:**
- Python: `__init__.py` with selective imports
- TypeScript: Index files combining related exports (e.g., `src/tools/index.ts`)

**Agent Structure (Python):**
- `agent.py` - Main agent definition with `@agent.tool` decorators
- `tools.py` - Pure tool functions without context dependency
- `models.py` - Pydantic data models and response types
- `settings.py` - Configuration with `pydantic-settings` and `load_dotenv()`

**MCP Server Structure (TypeScript):**
- `src/index.ts` - Main MCP server class extending `McpAgent`
- `src/types.ts` - TypeScript types and interfaces (e.g., `Props`, Zod schemas)
- `src/tools/register-tools.ts` - Centralized tool registration
- `src/tools/*.ts` - Individual tool modules with `registerXyzTools()` functions
- `src/database.ts` - Database connection and utilities
- `src/auth/` - Authentication handlers and utilities

## Pydantic Model Conventions

**Field Definition:**
```python
from pydantic import BaseModel, Field

class ResearchQuery(BaseModel):
    """Model for research query requests."""

    query: str = Field(..., description="Research topic to investigate")
    max_results: int = Field(10, ge=1, le=50, description="Maximum results")
    include_summary: bool = Field(True, description="Include AI summary")
```

**Config:**
- Use `class Config` with `json_schema_extra` for examples
- Include example JSON in schema for clarity

## TypeScript/Zod Conventions

**Input Validation:**
```typescript
import { z } from "zod";

const QuerySchema = z.object({
  sql: z.string().min(1, "SQL cannot be empty"),
  limit: z.number().int().positive().max(1000).optional(),
});

// Use schema in tool definition
server.tool("queryDb", "Query database", QuerySchema, async ({ sql, limit }) => {
  // sql and limit already validated and typed
});
```

**Error Responses:**
- Always return `{content: [...], isError: true}` for errors
- Include user-friendly error messages
- Sanitize sensitive information (passwords, tokens, URLs)

## Environment Variables

**Python:**
- Load with `from dotenv import load_dotenv` then `load_dotenv()`
- Use `pydantic-settings` with `BaseSettings` class
- Access via `settings.variable_name` (e.g., `settings.brave_api_key`)
- Never hardcode API keys or secrets

**TypeScript:**
- Load via Wrangler secrets: `wrangler secret put VARIABLE_NAME`
- Access via `env.VARIABLE_NAME` in Cloudflare Workers
- Use `.dev.vars` for local development (not committed)
- Sanitize errors to avoid exposing secret information

## Database Patterns

**Python/Async:**
```python
async def search_web_tool(...) -> List[Dict[str, Any]]:
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, headers=headers, timeout=30.0)
            if response.status_code != 200:
                raise Exception(f"API returned {response.status_code}")
            data = response.json()
            return data.get("results", [])
        except httpx.RequestError as e:
            logger.error(f"Request error: {e}")
            raise
```

**TypeScript/PostgreSQL:**
```typescript
export function getDb(databaseUrl: string): postgres.Sql {
  if (!dbInstance) {
    dbInstance = postgres(databaseUrl, {
      max: 5,
      idle_timeout: 20,
      connect_timeout: 10,
      prepare: true, // Use prepared statements
    });
  }
  return dbInstance;
}
```

## Security Conventions

**API Keys:**
- Never commit to repository
- Always load from environment variables
- Validate non-empty in settings/config validation
- Use `field_validator` in Pydantic for validation

**Input Validation:**
- All external inputs validated with Pydantic (Python) or Zod (TypeScript)
- SQL queries validated for dangerous patterns
- User permissions checked before sensitive operations

**Error Messages:**
- Never expose system paths, database details, or credentials
- Use generic messages for security-sensitive operations
- Log full details internally, return user-friendly messages

## Type Hints

**Python:**
- All function signatures include type hints
- Use `Optional[Type]` for nullable, `Union[Type1, Type2]` for multiple types
- Import from `typing` module

**TypeScript:**
- Strict mode enabled in `tsconfig.json`
- All parameters and return types explicitly typed
- Use `Promise<T>` for async, `void` for side effects only

---

*Convention analysis: 2026-02-07*
