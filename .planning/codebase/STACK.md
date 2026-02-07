# Technology Stack

**Analysis Date:** 2026-02-07

## Languages

**Primary:**
- TypeScript 5.8.3 - Used for Cloudflare Workers MCP server implementations and web development
- Python 3.11+ - Used for PydanticAI agent examples and utility scripts

**Secondary:**
- JavaScript (ES2022) - Node.js runtime, npm packages
- SQL - PostgreSQL database queries and schema management

## Runtime

**Environment:**
- Node.js (ES2022 module system) - Cloudflare Workers runtime with nodejs_compat flag
- Python 3.11+ - Agent development runtime with virtual environment support
- Cloudflare Workers - V8 isolate serverless runtime for MCP servers

**Package Manager:**
- npm - Primary for Node.js/TypeScript projects
- uv/pip - For Python dependency management (project uses both)

## Frameworks

**Core:**
- Hono 4.8.3 - Lightweight HTTP framework for Cloudflare Workers
- Model Context Protocol (MCP) SDK 1.26.0 - `@modelcontextprotocol/sdk` - MCP server implementation
- Agents (Cloudflare) 0.3.7 - `agents` package - MCP agent framework and McpAgent base class
- Workers-MCP 0.0.13 - MCP transport layer for Cloudflare Workers
- PydanticAI - Python framework for building AI agents with tool integration

**OAuth & Authentication:**
- @cloudflare/workers-oauth-provider 0.0.5 - OAuth 2.1 server implementation for Cloudflare Workers
- Octokit 5.0.3 - GitHub API client for OAuth flow and user data retrieval

**Database:**
- Postgres 3.4.5 - PostgreSQL client library for Node.js with connection pooling
- SQLAlchemy/SQLModel - Python ORM for database access (mentioned in conventions)

**Testing:**
- Vitest 3.2.4 - Fast unit testing framework for TypeScript/JavaScript
- @cloudflare/vitest-pool-workers 0.8.53 - Vitest integration for Cloudflare Workers testing
- pytest - Python testing framework
- pytest-asyncio - Async test support for Python
- pytest-cov - Code coverage reporting

**Build/Dev:**
- Wrangler 4.59.1 - Cloudflare Workers CLI for development, deployment, and configuration
- TypeScript 5.8.3 - Static type checking and compilation
- Ruff 0.3.0+ - Python linter and formatter
- mypy 1.19.1+ - Python static type checker
- Prettier 3.6.2 - Code formatter for TypeScript/JavaScript
- Zod 3.25.67 - Runtime TypeScript schema validation

## Key Dependencies

**Critical:**
- @modelcontextprotocol/sdk 1.26.0 - Essential for MCP server functionality
- agents 0.3.7 - Required for McpAgent implementation and Durable Objects integration
- @cloudflare/workers-oauth-provider 0.0.5 - OAuth provider for authentication
- Hono 4.8.3 - HTTP request routing
- postgres 3.4.5 - PostgreSQL database connection pooling

**Infrastructure:**
- @sentry/cloudflare 9.16.0 - Optional error tracking and monitoring for production
- zod 3.25.67 - Input validation schemas
- just-pick 4.2.0 - Utility for object property selection
- query-string - URL query parsing
- pydantic-ai - Python AI agent framework

## Configuration

**Environment:**
- `.dev.vars` file for local development (Cloudflare Workers)
- `.env` files for Python environments
- Environment variables required:
  - `GITHUB_CLIENT_ID` - GitHub OAuth application ID
  - `GITHUB_CLIENT_SECRET` - GitHub OAuth application secret
  - `COOKIE_ENCRYPTION_KEY` - HMAC key for cookie signing
  - `DATABASE_URL` - PostgreSQL connection string (format: `postgresql://user:pass@host:port/db`)
  - `SENTRY_DSN` - Optional Sentry project DSN for error tracking
  - `NODE_ENV` - Environment (development/production)

**Build:**
- `tsconfig.json` - TypeScript compiler configuration with ES2021 target and isolatedModules
- `wrangler.jsonc` - Cloudflare Workers configuration with Durable Objects, KV, AI bindings
- `package.json` - npm dependencies and scripts
- `pyproject.toml` - Python project configuration with optional dev dependencies

## Platform Requirements

**Development:**
- Cloudflare account (free tier works) with Workers enabled
- GitHub account for OAuth testing
- PostgreSQL database (local or cloud-hosted)
- Node.js runtime with npm
- Python 3.11+
- Wrangler CLI for local development: `npm install -g wrangler`

**Production:**
- Cloudflare Workers deployment platform
- Cloudflare Durable Objects for stateful MCP agent instances
- Cloudflare KV for OAuth session storage
- PostgreSQL database access (via Hyperdrive or direct connection)
- Optional: Sentry for error monitoring

## Database Configuration

**Connection Type:** PostgreSQL with connection pooling via `postgres` npm package

**Pool Settings:**
- Maximum 5 concurrent connections (respects Cloudflare Workers 6-connection limit)
- Idle timeout: 20 seconds
- Connect timeout: 10 seconds
- Prepared statements enabled for performance

**Authentication:** Connection string format
```
postgresql://username:password@hostname:port/database_name
```

**For Production:** Use Cloudflare Hyperdrive for managed PostgreSQL connections

## Version Control

**Git Configuration:**
- Target version: Python 3.11
- TypeScript target: ES2021
- Npm lockfile: Present (`package-lock.json`)

## Special Build Flags

**TypeScript Compiler Options:**
- Strict mode enabled
- Module resolution: bundler (Cloudflare Workers compatible)
- Emit disabled (Wrangler handles compilation)
- Isolated modules enabled

**Cloudflare Workers:**
- Compatibility date: 2025-03-10
- Compatibility flags: nodejs_compat (enables Node.js built-ins)

**Wrangler Features Enabled:**
- Durable Objects (stateful agents)
- KV Storage (OAuth sessions)
- AI Binding (Cloudflare AI models)
- Observability (performance monitoring)
- Dev server port: 8792

---

*Stack analysis: 2026-02-07*
