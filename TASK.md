# Task Tracker

## Completed

### Tech Debt Remediation (2026-02-07)

Addressed items from `.planning/codebase/CONCERNS.md`:

- [x] Fix unsafe `env as any` type casts — Created `WorkerEnv` interface in `src/types.ts`, replaced all `(env as any)` and `(c.env as any)` casts across `database-tools.ts`, `database-tools-sentry.ts`, `github-handler.ts`
- [x] Split `oauth-utils.ts` (622 lines) into 4 focused modules — `state-encoding.ts`, `cookie-signing.ts`, `html-rendering.ts`, `oauth-helpers.ts` + barrel re-export
- [x] Fix loose `any` type annotations — Replaced with `unknown`, typed `OAuthState` interface, constrained generics
- [x] Add security documentation — SECURITY NOTE docstrings on `validateSqlQuery()`, `formatDatabaseError()`; inline comments per regex pattern
- [x] Add COOKIE_SECRET minimum length validation (32 chars) in `cookie-signing.ts`
- [x] Make database connection pool configurable — `poolMax` parameter with default 5, documented Workers 6-connection limit
- [x] Document singleton thread safety — THREAD SAFETY NOTE for Workers V8 isolate model
- [x] Expand test coverage — 39 → 62 TypeScript tests (8 state-encoding, 15 SQL validation edge cases, 4 error formatting)
- [x] Update codebase mapping docs — CONCERNS.md, ARCHITECTURE.md, TESTING.md, INTEGRATIONS.md

### Shellcheck Fixes (2026-02-07)

- [x] Fix SC2162, SC2181, SC2034, SC2155 warnings across shell scripts
- [x] Full validation pass: E:0 W:0, all 9 phases clean

## Discovered During Work

- Parameterized queries: Migrate from `db.unsafe(sql)` to `db(sql, [params])` where possible (from CONCERNS.md — still open)
- HTML sanitization: Replace entity-escaping `sanitizeHtml()` with DOMPurify or equivalent (from CONCERNS.md — still open)
- Error message whitelist: Switch `formatDatabaseError()` from blocklist to whitelist approach (from CONCERNS.md — still open)
- Query timeout: Add per-query timeout handling for `db.unsafe(sql)` calls (from CONCERNS.md — still open)
- Integration tests: HTML rendering with various client metadata combinations (from CONCERNS.md — still open)
- Pool exhaustion tests: Behavior under high concurrent load (from CONCERNS.md — still open)
