---
description: Comprehensive validation for this codebase
---

# Validate Project (Context Engineering Template)

> **Generated for this codebase:** Context Engineering Template with 3 use-cases (pydantic-ai, mcp-server, fastapi-backend), shell scripts (root shims + bin/), pre-commit hooks, GitHub Actions CI, canonical commands (.commands/), and multi-IDE slash commands (11 commands across Claude Code, Cursor, VS Code). Python: uv + ruff, mypy, pytest. TypeScript: use-cases/mcp-server (tsc, vitest, prettier). Run from repo root.
>
> **Setup:** Run `uv sync --all-extras` once to install dev tools (ruff, mypy, pytest). For MCP server: `npm install` in use-cases/mcp-server. Optional: `brew install shellcheck` for shell validation.

**Execute ONLY the validation in this file.** Do not run another project's validation. Use **`/validate-project`** (not `/validate`) to avoid conflicts with team/global commands.

## Phase 1: Python Linting

Run ruff linter on all Python use-cases:

```bash
uv run ruff check use-cases/pydantic-ai/
```

```bash
uv run ruff check use-cases/fastapi-backend/
```

## Phase 2: Python Type Checking

Run mypy type checking (warnings acceptable, ensure no critical errors):

```bash
uv run mypy use-cases/pydantic-ai/ --ignore-missing-imports
```

```bash
uv run mypy use-cases/fastapi-backend/ --ignore-missing-imports
```

## Phase 3: Python Style Checking

Verify Python code formatting with ruff:

```bash
uv run ruff format --check use-cases/pydantic-ai/
```

```bash
uv run ruff format --check use-cases/fastapi-backend/
```

## Phase 4: Python Unit Testing

Run pytest on Python use-case tests:

```bash
uv run pytest use-cases/pydantic-ai/ -v --tb=short
```

Note: use-cases/fastapi-backend/ is a template and may not have tests yet. If a tests/ directory exists, run:

```bash
uv run pytest use-cases/fastapi-backend/ -v --tb=short
```

## Phase 5: TypeScript Validation (MCP Server)

Run each command separately for the use-cases/mcp-server directory:

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
npx prettier --check "use-cases/mcp-server/src/**/*.ts" --config use-cases/mcp-server/.prettierrc
```

## Phase 6: Shell Script Validation

Verify shell scripts have correct syntax. Try shellcheck first; fall back to bash -n if shellcheck is not installed.

### With shellcheck (preferred)

```bash
shellcheck setup.sh create-project.sh sync-commands.sh bin/setup.sh bin/setup-vscode.sh bin/setup-claude.sh bin/setup-cursor.sh bin/create-project.sh bin/sync-commands.sh bin/install-claude-commands.sh bin/install-dev-tools.sh
```

### Without shellcheck (fallback -- verify syntax only)

Run `bash -n` on each script individually:

```bash
bash -n setup.sh
```

```bash
bash -n create-project.sh
```

```bash
bash -n sync-commands.sh
```

```bash
bash -n bin/setup.sh
```

```bash
bash -n bin/setup-vscode.sh
```

```bash
bash -n bin/setup-claude.sh
```

```bash
bash -n bin/setup-cursor.sh
```

```bash
bash -n bin/create-project.sh
```

```bash
bash -n bin/sync-commands.sh
```

```bash
bash -n bin/install-claude-commands.sh
```

```bash
bash -n bin/install-dev-tools.sh
```

## Phase 7: Structure & Command Parity

Use file tools (Glob, Read, LS) to verify -- do NOT use compound shell commands with `&&` / `||` / `for`.

### Core Files

Verify these exist and are non-empty:

- CLAUDE.md
- README.md
- INITIAL.md
- INITIAL_EXAMPLE.md
- LICENSE
- pyproject.toml
- .pre-commit-config.yaml
- .cursorrules

### Setup Scripts

Verify these are executable:

- setup.sh (root shim)
- create-project.sh (root shim)
- sync-commands.sh (root shim)
- bin/setup.sh
- bin/setup-vscode.sh
- bin/setup-claude.sh
- bin/setup-cursor.sh
- bin/create-project.sh
- bin/sync-commands.sh
- bin/install-claude-commands.sh
- bin/install-dev-tools.sh

### Use-Cases

Verify each existing use-case has CLAUDE.md and README.md:

- use-cases/pydantic-ai/CLAUDE.md
- use-cases/pydantic-ai/README.md
- use-cases/mcp-server/CLAUDE.md
- use-cases/mcp-server/README.md
- use-cases/fastapi-backend/CLAUDE.md
- use-cases/fastapi-backend/README.md

### Canonical Commands

Verify the .commands/ directory exists and contains canonical command definitions. These are the source-of-truth used by sync-commands.sh to generate IDE-specific versions:

- .commands/generate-prd.md
- .commands/generate-prp.md
- .commands/execute-prp.md
- .commands/generate-prompt.md
- .commands/validate-project.md
- .commands/validate.md
- .commands/generate-validate.md
- .commands/new-project.md
- .commands/build-prp.md
- .commands/summarize.md
- .commands/revise-prp.md

### Command Parity Across IDEs

For each of these 11 commands, verify it exists in ALL THREE IDE locations:

- .claude/commands/{cmd}.md
- .cursor/prompts/{cmd}.md
- .github/prompts/{cmd}.prompt.md

Commands to check: generate-prd, generate-prp, execute-prp, generate-prompt, validate-project, validate, generate-validate, new-project, build-prp, summarize, revise-prp

### PRP Templates

Verify these exist:

- PRPs/templates/prp_base.md
- PRPs/templates/prd_base.md

### Journal Directory

Verify exists:

- journal/
- journal/README.md

## Phase 8: Documentation & Cross-References

### README Commands

Use Grep to verify README.md mentions all primary commands:

- generate-prd
- generate-prp
- execute-prp
- generate-prompt
- validate-project
- generate-validate
- new-project
- build-prp
- summarize
- revise-prp

### Skill Files

Verify skill files exist for Claude Code slash-menu discovery:

- .claude/skills/generate-prp/SKILL.md
- .claude/skills/execute-prp/SKILL.md
- .claude/skills/build-prp/SKILL.md
- .claude/skills/generate-prompt/SKILL.md
- .claude/skills/generate-validate/SKILL.md
- .claude/skills/new-project/SKILL.md
- .claude/skills/validate/SKILL.md
- .claude/skills/revise-prp/SKILL.md

### VS Code Prompt Frontmatter

Verify .github/prompts/*.prompt.md files have YAML frontmatter (lines starting with `---` and containing `description:`). Most files also use `agent:` for the mode field.

## Phase 9: E2E Workflow Validation

Test complete user workflows from documentation, not just internal checks.

### Workflow 1: Project Creation (Dry Run)

Create a temporary project from the template and verify its structure:

```bash
TMPDIR=$(mktemp -d)
bash create-project.sh "$TMPDIR/test-project" --all 2>&1 || true
```

After running, verify the created project has:

- CLAUDE.md or .cursorrules (at least one AI config file)
- INITIAL.md
- journal/ directory

Then clean up:

```bash
rm -rf "$TMPDIR"
```

### Workflow 2: Install to Existing Project (Dry Run)

Test the `--install` flag for non-interactive installation into an existing project:

```bash
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/existing-project"
echo "# My Project" > "$TMPDIR/existing-project/README.md"
bash setup.sh --install "$TMPDIR/existing-project" --all 2>&1 || true
```

After running, verify the target project received:

- CLAUDE.md
- INITIAL.md
- journal/ directory
- .claude/commands/ or .cursor/prompts/ or .github/prompts/ (at least one IDE)

Verify the original README.md was NOT overwritten (should still contain "# My Project").

Then clean up:

```bash
rm -rf "$TMPDIR"
```

### Workflow 3: Command Sync Verification

Verify sync-commands.sh runs without errors:

```bash
bash -n sync-commands.sh
```

Then use Glob/Grep to confirm at least 3 commands exist in each IDE folder:

- .claude/commands/ should contain .md files
- .cursor/prompts/ should contain .md files
- .github/prompts/ should contain .prompt.md files

### Workflow 4: Pre-commit Configuration

Verify pre-commit configuration is valid YAML and references expected hooks:

```bash
python3 -c "import yaml; yaml.safe_load(open('.pre-commit-config.yaml'))" 2>&1 || echo "WARN: PyYAML not available, skipping YAML parse check"
```

Use Grep to verify .pre-commit-config.yaml references these hooks:

- ruff
- shellcheck
- markdownlint
- prettier

### Workflow 5: JSON/YAML File Integrity

Validate JSON files (skip JSONC files like tsconfig.json and settings.json):

```bash
python3 -c "import json; json.load(open('use-cases/mcp-server/package.json'))"
```

Validate YAML files:

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/validate.yml'))" 2>&1 || echo "WARN: PyYAML not available"
```

```bash
python3 -c "import yaml; yaml.safe_load(open('.pre-commit-config.yaml'))" 2>&1 || echo "WARN: PyYAML not available"
```

### Workflow 6: Example Project Structure

Verify the examples/daily-quote-app/ tutorial project has essential files:

- examples/daily-quote-app/README.md
- examples/daily-quote-app/INITIAL.md

### Workflow 7: GitHub Actions CI

Verify .github/workflows/validate.yml exists and references expected jobs:

- Use Grep to check for job names: structure, typescript, python, shell, files, documentation

### Workflow 8: FastAPI Template Completeness

Verify the fastapi-backend use-case template has the expected structure:

- use-cases/fastapi-backend/pyproject.toml
- use-cases/fastapi-backend/.env.example
- use-cases/fastapi-backend/examples/ (directory with Python examples)
- use-cases/fastapi-backend/PRPs/INITIAL.md
- use-cases/fastapi-backend/PRPs/templates/prp_fastapi_base.md

## Summary

Report results for each phase:

- **P1 (Python Lint):** OK/FAIL
- **P2 (Python Types):** OK/WARN/FAIL
- **P3 (Python Style):** OK/FAIL
- **P4 (Python Tests):** OK/FAIL
- **P5 (TypeScript):** OK/FAIL (skip if node_modules not installed)
- **P6 (Shell):** OK/WARN/FAIL
- **P7 (Structure):** OK/FAIL
- **P8 (Docs):** OK/FAIL
- **P9 (E2E):** OK/FAIL

Count total errors (E) and warnings (W). Pass = 0 errors. Warn = 0 errors but warnings present.

## Journal Entry (Required)

After validation completes:

1. **Ensure journal/ exists:** `mkdir -p journal`
2. **Append one line to `journal/YYYY-MM-DD.md`** (today's date, ISO format):

   ```
   HH:MM | Pass/Fail | E:N W:M | P1:OK P2:OK ... P9:OK | optional note
   ```

3. **Update `journal/README.md`** with one line per date for that day's latest outcome, e.g.:

   ```
   YYYY-MM-DD: N runs, last Pass (E:0 W:1)
   ```

**Example entry:**

```
15:30 | Pass | E:0 W:2 | P1:OK P2:WARN P3:OK P4:OK P5:OK P6:OK P7:OK P8:OK P9:OK | Clean validation
```
