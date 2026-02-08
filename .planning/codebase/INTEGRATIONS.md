# External Integrations

**Analysis Date:** 2026-02-07

## APIs & External Services

**GitHub OAuth:**
- Service: GitHub OAuth 2.0 for authentication
- What it's used for: User authentication and authorization, role-based access control
- SDK/Client: `octokit` (5.0.3)
- Auth: Environment variables `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET`
- Endpoints used:
  - Authorization: `https://github.com/login/oauth/authorize`
  - Token exchange: `https://github.com/login/oauth/access_token`
  - User API: `https://api.github.com/user` (via Octokit)
- Scope: `read:user` (read-only access to authenticated user profile)
- Implementation: `src/auth/github-handler.ts` handles full OAuth 2.0 flow

**Model Context Protocol (MCP):**
- Service: Claude/AI tool integration protocol
- What it's used for: Standardized interface for AI agents to call database tools and other resources
- SDK/Client: `@modelcontextprotocol/sdk` (1.26.0)
- Transport protocols: HTTP (`/mcp` endpoint) and Server-Sent Events (`/sse` endpoint)
- Implementation: `src/index.ts` and `src/index_sentry.ts` expose MCP servers via Cloudflare Workers

**Cloudflare AI:**
- Service: Cloudflare Workers AI models
- What it's used for: Optional AI inference within Workers (configured in wrangler.jsonc)
- Binding: `AI` binding in Cloudflare Workers environment
- Configuration: `wrangler.jsonc` includes AI binding

**External LLM Providers (PydanticAI use case):**
- OpenAI - Default provider, requires `OPENAI_API_KEY`
- Anthropic - Claude models support
- Gemini - Google's LLM support
- Custom endpoints (Ollama, etc.)
- Configuration: `LLM_PROVIDER`, `LLM_API_KEY`, `LLM_CHOICE`, `LLM_BASE_URL` environment variables

## Data Storage

**Databases:**
- PostgreSQL
  - Connection: `DATABASE_URL` environment variable
  - Client: `postgres` npm package (3.4.5) with connection pooling
  - Features: Prepared statements enabled, connection pooling (configurable via `poolMax` parameter, default 5; Cloudflare Workers 6-connection limit)
  - Security: SQL injection validation in `src/database/security.ts`

**File Storage:**
- Local filesystem only - No cloud storage integrations detected

**Caching:**
- Cloudflare KV Storage - Used for OAuth session and state management
  - Binding: `OAUTH_KV` in wrangler.jsonc
  - Purpose: Store temporary OAuth request state during authorization flow

## Authentication & Identity

**Auth Provider:**
- GitHub OAuth 2.0 (custom implementation)
- Implementation files:
  - `src/auth/github-handler.ts` — OAuth flow orchestration (uses `WorkerEnv` typed bindings)
  - `src/auth/oauth-utils.ts` — Barrel re-export (delegates to focused modules below)
  - `src/auth/state-encoding.ts` — `encodeState()` / `decodeState()` with typed `OAuthState` interface
  - `src/auth/cookie-signing.ts` — HMAC-SHA256 cookie signing, `clientIdAlreadyApproved()`, `parseRedirectApproval()`, 32-char minimum secret validation
  - `src/auth/html-rendering.ts` — `renderApprovalDialog()`, `sanitizeHtml()` (entity-escaping only)
  - `src/auth/oauth-helpers.ts` — `getUpstreamAuthorizeUrl()`, `fetchUpstreamAuthToken()`
  - `src/auth/workers-oauth-utils.ts` — Low-level HMAC-signed cookie approval system

**User Context:**
- Authenticated user props stored in OAuth token:
  - `login` - GitHub username
  - `name` - User's display name
  - `email` - Email address
  - `accessToken` - GitHub personal access token (never exposed to client)

**Session Management:**
- Cookie-based approval system using HMAC-SHA256 signatures (`src/auth/cookie-signing.ts`)
- `COOKIE_ENCRYPTION_KEY` minimum length: 32 characters (enforced at import time)
- Clients can skip approval dialog on subsequent logins
- Cookie encryption key: `COOKIE_ENCRYPTION_KEY` environment variable

**Role-Based Access Control:**
- Privileged operations reserved for specific GitHub usernames
- Allowlist: `src/examples/database-tools.ts` hardcodes `ALLOWED_USERNAMES` (e.g., 'coleam00')
- Write operations only available to allowlisted users

## Monitoring & Observability

**Error Tracking:**
- Sentry (optional, not required)
  - SDK: `@sentry/cloudflare` (9.16.0)
  - DSN: `SENTRY_DSN` environment variable
  - Implementation: `src/index_sentry.ts` provides instrumented version with tracing
  - Features: Distributed tracing, error context capture, user context binding, tool call tracing

**Logs:**
- Console logging (stdout) for both standard and Sentry versions
- Log patterns:
  - Database operations: timing and error messages
  - Authentication events: user login/logout
  - Tool execution: tool name and user context
  - Error logs include sanitized error messages (no credentials leaked)

**Built-in Error Handling:**
- `src/database/security.ts` - SQL validation and error formatting
- Error messages sanitized to prevent credential exposure
- Timing information included for performance debugging

## CI/CD & Deployment

**Hosting:**
- Cloudflare Workers (primary deployment platform)
- Deployment via Wrangler CLI: `wrangler deploy`
- Local development server: `wrangler dev` (port 8792)

**CI Pipeline:**
- Not detected in codebase (no GitHub Actions workflows, GitLab CI, etc.)
- Manual deployment via Wrangler CLI
- Type checking available: `npm run type-check` and `wrangler types`

**Build & Configuration:**
- Wrangler configuration: `wrangler.jsonc` in MCP server use case
- Dev environment: `.dev.vars` and `.dev.vars.example` for local configuration
- Compatibility date: 2025-03-10

## Environment Configuration

**Required env vars for MCP Server:**
- `GITHUB_CLIENT_ID` - GitHub OAuth app ID
- `GITHUB_CLIENT_SECRET` - GitHub OAuth app secret
- `COOKIE_ENCRYPTION_KEY` - Encryption key for approval cookies
- `DATABASE_URL` - PostgreSQL connection string

**Optional env vars:**
- `SENTRY_DSN` - Sentry error tracking (if using Sentry-enabled version)
- `NODE_ENV` - Environment (development/production)
- `ANTHROPIC_API_KEY` - For PRP parsing in MCP server (optional)
- `ANTHROPIC_MODEL` - Anthropic model choice (defaults to claude-3-5-haiku-latest)

**Required env vars for PydanticAI use case:**
- `LLM_PROVIDER` - LLM provider (openai, anthropic, gemini, ollama, etc.)
- `LLM_API_KEY` - API key for selected provider
- `LLM_CHOICE` - Model name (e.g., gpt-4-mini, claude-4-sonnet)
- `LLM_BASE_URL` - Base URL for LLM API (defaults to provider's official URL)

**Secrets location:**
- Development: `.dev.vars` file (Cloudflare Workers) or `.env` file (Python)
- Production: Wrangler CLI secrets (`wrangler secret put KEY`)

## Webhooks & Callbacks

**Incoming:**
- `/authorize` - OAuth authorization request handler
- `/callback` - GitHub OAuth callback receiver
- `/token` - OAuth token endpoint (handled by OAuth provider)
- `/register` - OAuth client registration endpoint
- `/mcp` - MCP HTTP transport endpoint
- `/sse` - MCP Server-Sent Events endpoint

**Outgoing:**
- GitHub API calls via Octokit for user data retrieval
- External API calls via agent tools (configurable per use case)

## Database Access Patterns

**Connection Management:**
- Singleton pattern: `src/database/connection.ts` maintains single connection pool instance
- Pool size configurable via `poolMax` parameter (default: 5); documented Cloudflare Workers 6-connection limit
- Thread safety: Safe under Workers single-threaded V8 isolate model (documented)
- Automatic cleanup: Durable Objects alarm handler calls `closeDb()` on shutdown
- Prepared statements enabled for performance and security

**SQL Query Validation:**
- `validateSqlQuery()` in `src/database/security.ts` checks for dangerous SQL patterns
- `isWriteOperation()` determines if SQL is a write command (INSERT, UPDATE, DELETE, CREATE, DROP, ALTER)
- Pattern-based validation prevents common SQL injection attacks

**Query Execution:**
- `withDatabase()` wrapper in `src/database/utils.ts` handles query execution with timing
- All queries executed via `db.unsafe()` with manual validation
- Error messages sanitized before returning to client

## MCP Tool Definitions

**Database Tools (available in examples/database-tools.ts):**
1. `listTables` - Get schema information (all authenticated users)
2. `queryDatabase` - Execute SELECT queries (all authenticated users)
3. `executeDatabase` - Execute write operations (privileged users only)

**Tool Registration:**
- Centralized in `src/tools/register-tools.ts`
- Each tool module exports a registration function
- Permission checking happens during tool registration (tools not registered for unprivileged users)

**Tool Input Validation:**
- Zod schemas for all inputs defined in `src/types.ts`
- `ListTablesSchema` - Empty (no parameters)
- `QueryDatabaseSchema` - `sql: string` (required, min 1 char)
- `ExecuteDatabaseSchema` - `sql: string` (required, min 1 char)

---

*Integration audit: 2026-02-07*
