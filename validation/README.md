# Ultimate Validation Command

**One command to analyze your codebase and generate a comprehensive validation workflow.**

The template's **generate-validate** commands use **[.claude/commands/example-validate.md](../.claude/commands/example-validate.md)** as the template and create a **`/validate-project`** command (not `/validate`) so project-specific validation is not overridden by team or global commands. They also use **ultimate_validate_command.md** for philosophy. Users run **`/validate-project`** to run the generated validation.

## Quick Start

### 1. Generate Your Validation Command
```bash
/generate-validate
```

This analyzes your codebase and, using [.claude/commands/example-validate.md](../.claude/commands/example-validate.md) as the template, creates **`/validate-project`** in all IDEs (`.claude/commands/validate-project.md`, `.cursor/prompts/validate-project.md`, `.cursor/commands/validate-project.md`, `.github/prompts/validate-project.prompt.md`).

### 2. Run Complete Validation
```bash
/validate-project
```

This runs the generated validation (linting, type checking, style checking, unit tests, E2E). Use **`/validate-project`** (not `/validate`) to avoid conflicts with injected commands.

### 3. Full thorough run (this template repo)
For **`/validate-project --thorough`** to run all phases (ruff, mypy, pytest, pydantic-ai use-cases), install Python dev tooling from the repo root:

```bash
./install-dev-tools.sh        # creates .venv if missing, installs ruff, mypy, pytest, pydantic-ai, etc.
source .venv/bin/activate    # then run /validate-project --thorough
```

Or with **uv**: `uv venv && uv sync --extra dev` (or `uv pip install -r requirements-dev.txt`), then `source .venv/bin/activate` and run **`/validate-project`** or **`/validate-project --thorough`**. If Phase 2 (mypy) or Phase 4 (pytest) are skipped, ensure mypy and pytest are in the active environment.

**Troubleshooting:** If **`/validate-project`** skips Phase 2 or 4, run `./install-dev-tools.sh` or `uv sync --extra dev` (may take 1–2 min on slow volumes). If pytest fails with `ModuleNotFoundError: pygments.formatters`, run `uv pip install pygments --python .venv/bin/python` (or `pip install pygments` in the activated venv).

## What It Does

### Analyzes Your Codebase
- Detects what validation tools you already have (ESLint, ruff, mypy, prettier, etc.)
- Finds your test setup (pytest, jest, Playwright, etc.)
- Understands your application architecture (routes, endpoints, database schema)
- Examines existing test patterns and CI/CD configs

### Generates /validate-project (all three IDEs)
**`/generate-validate`** creates **`/validate-project`** in VS Code (`.github/prompts/validate-project.prompt.md`), Claude Code (`.claude/commands/validate-project.md`), and Cursor (`.cursor/prompts/validate-project.md`). The generated command has phases:

1. **Linting** - Using your configured linter
2. **Type Checking** - Using your configured type checker
3. **Style Checking** - Using your configured formatter
4. **Unit Testing** - Running your existing unit tests
5. **End-to-End Testing** - THIS IS THE KEY PART

## The E2E Testing Magic

The generated E2E tests are designed to be SO comprehensive that you don't need to manually test.

### For Frontend Apps
Uses Playwright to:
- Test every user flow (registration, login, CRUD operations)
- Interact with forms, buttons, navigation
- Verify data persistence and UI updates
- Test error states and validation
- Cover all routes and features

### For Backend Apps
Uses Docker and custom scripts to:
- Spin up full stack in containers
- Test all API endpoints with real requests
- Interact directly with database to verify data
- Test complete workflows (auth → data operations → verification)
- Create test utilities or API endpoints if needed

### For Full-Stack Apps
- Tests complete flows from UI through API to database
- Verifies data consistency across all layers
- Simulates real user behavior end-to-end

## Key Philosophy

**If `/validate-project` passes, your app works.**

The E2E testing is creative and thorough enough that manual testing becomes unnecessary. It tests the application exactly how a real user would interact with it.

## Example

For a React + FastAPI app, the generated command might:

1. Run ESLint, TypeScript check, Prettier
2. Run pytest and Jest
3. **E2E:**
   - Use Playwright to test user registration → login → creating items → editing → deleting
   - Spin up Docker containers for backend
   - Use curl to test all API endpoints
   - Query database directly to verify data integrity
   - Test error handling, permissions, validation

**Result:** Complete confidence that everything works.

## How It's Different

Traditional testing:
- ❌ Unit tests in isolation
- ❌ Manual E2E testing
- ❌ Gaps in coverage
- ❌ Time-consuming

This approach:
- ✅ Automated everything
- ✅ Tests like a real user
- ✅ Comprehensive E2E coverage
- ✅ One command to validate all

## Get Started

Run **`/generate-validate`** to generate your **`/validate-project`** workflow, then use **`/validate-project`** whenever you need complete confidence in your code (use this, not `/validate`, to avoid injected commands).

The generated command adapts to YOUR codebase and tests it thoroughly.
