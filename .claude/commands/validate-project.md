---
description: Validate Context Engineering Template (project-specific)
---

# Validate Project (Context Engineering Template)

> **Generated for this codebase:** Template repo with 5 use-cases (pydantic-ai, mcp-server, agent-factory-with-subagents, template-generator, ai-coding-workflows-foundation). Python: ruff, mypy, pytest. TypeScript: use-cases/mcp-server (tsc, vitest, prettier). Run from repo root. Use **`/validate-project`** (not `/validate`) to avoid conflicts with team/global commands.
>
> **Setup:** For full validation, activate `.venv` and run `./install-dev-tools.sh` or `uv sync --extra dev` first. For MCP server: `npm install` in use-cases/mcp-server.

## Phase 1: Python Linting

Run ruff linter on Python use-cases:

```bash
ruff check use-cases/pydantic-ai use-cases/agent-factory-with-subagents
```

## Phase 2: Python Type Checking

Run mypy type checking (warnings acceptable, ensure no critical errors):

```bash
mypy use-cases/pydantic-ai use-cases/agent-factory-with-subagents --ignore-missing-imports
```

## Phase 3: Python Style Checking

Verify Python code formatting with ruff:

```bash
ruff format --check use-cases/pydantic-ai use-cases/agent-factory-with-subagents
```

## Phase 4: Python Unit Testing

Run pytest on Python use-cases:

```bash
pytest use-cases/pydantic-ai use-cases/agent-factory-with-subagents -v --tb=short
```

## Phase 5: TypeScript Validation (MCP Server)

Run each command separately from the use-cases/mcp-server directory:

### Type Checking
```bash
npm run type-check --prefix use-cases/mcp-server
```

### Unit Tests
```bash
npm run test:run --prefix use-cases/mcp-server
```

### Style Checking
```bash
npx prettier --check "use-cases/mcp-server/src/**/*.ts"
```

## Phase 6: Shell Script Validation

Verify shell scripts with shellcheck:

```bash
shellcheck SETUP.sh SETUP-VSCODE.sh SETUP-CLAUDE.sh SETUP-CURSOR.sh create-project.sh install-claude-commands.sh
```

## Phase 7: Structure Validation

Use file tools (Glob, Read) to verify - do NOT use compound shell commands with `&&` / `||` / `for`.

### Core Files
Verify these exist:
- CLAUDE.md
- README.md
- create-project.sh
- INITIAL.md or INITIAL_EXAMPLE.md

### Setup Scripts
Verify these are executable:
- SETUP.sh
- SETUP-VSCODE.sh
- SETUP-CLAUDE.sh
- SETUP-CURSOR.sh
- create-project.sh

### Use-Cases
Verify each has CLAUDE.md:
- use-cases/pydantic-ai/CLAUDE.md
- use-cases/mcp-server/CLAUDE.md
- use-cases/agent-factory-with-subagents/CLAUDE.md
- use-cases/template-generator/CLAUDE.md
- use-cases/ai-coding-workflows-foundation/CLAUDE.md

### Command Parity
For each command (generate-prp, execute-prp, generate-prompt, validate-project, generate-validate, new-project, build-prp), verify at least one exists:
- .claude/commands/{cmd}.md
- .cursor/prompts/{cmd}.md
- .github/prompts/{cmd}.prompt.md

### PRP Templates
Verify these exist:
- PRPs/templates/prp_base.md
- PRPs/templates/prd_base.md
- PRPs/prompts/ directory

## Phase 8: Documentation Validation

### README Commands
Use Grep to verify README.md mentions these commands:
- generate-prp
- execute-prp
- generate-prompt
- validate-project
- generate-validate
- new-project
- build-prp

### Skill Files
Verify skill files exist for slash-menu discovery:
- .claude/skills/generate-prp/SKILL.md
- .claude/skills/execute-prp/SKILL.md
- .claude/skills/validate/SKILL.md

## Phase 9: E2E Workflow Validation

### Workflow 1: Setup Script Syntax
Verify shell scripts have valid syntax:

```bash
bash -n SETUP.sh
```

```bash
bash -n create-project.sh
```

### Workflow 2: Journal Directory
Ensure journal directory exists:

```bash
mkdir -p journal
```

### Workflow 3: Pre-commit Config
Verify pre-commit is configured:

```bash
ls .pre-commit-config.yaml
```

## Summary

Report results for each phase:
- **P1 (Python Lint):** OK/FAIL
- **P2 (Python Types):** OK/WARN/FAIL
- **P3 (Python Style):** OK/FAIL
- **P4 (Python Tests):** OK/FAIL
- **P5 (TypeScript):** OK/FAIL
- **P6 (Shell):** OK/FAIL
- **P7 (Structure):** OK/FAIL
- **P8 (Docs):** OK/FAIL
- **P9 (E2E):** OK/FAIL

Count errors (E) and warnings (W).

## Journal Entry (Required)

After validation completes:

1. **Ensure journal/ exists:** `mkdir -p journal`
2. **Append one line to `journal/YYYY-MM-DD.md`** (today, ISO format):
   ```
   HH:MM | Pass/Fail | E:N W:M | P1:OK P2:OK ... P9:OK | optional note
   ```
3. **Update `journal/README.md`** with the day's latest outcome.

**Example entry:**
```
15:30 | Pass | E:0 W:1 | P1:OK P2:WARN P3:OK P4:OK P5:OK P6:OK P7:OK P8:OK P9:OK | Clean validation
```
