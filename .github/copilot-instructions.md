# Context Engineering Template - AI Coding Instructions

## Project Overview

This is a **Context Engineering Template** - a framework for building AI-assisted development workflows using PRPs (Product Requirements Prompts) and slash commands. The codebase contains multiple use-case templates for different AI application types.

## Architecture

```
context-engineering-intro/
├── .claude/commands/           # Claude Code (same workflow as VS Code & Cursor)
├── .github/prompts/            # VS Code Copilot slash commands
├── .cursor/prompts/            # Cursor slash commands
├── PRPs/templates/             # PRP templates for feature requests
├── PRPs/prompts/               # Generated prompts from /generate-prompt
├── tutorials/                  # Learning resources and tutorials
├── examples/                   # Code examples for AI context
├── journal/                    # Daily validation journal (tracking and support)
├── use-cases/                  # Specialized templates:
│   ├── pydantic-ai/           # PydanticAI agent development
│   ├── mcp-server/            # Cloudflare Workers MCP servers
│   ├── agent-factory-with-subagents/  # Multi-agent orchestration
│   ├── template-generator/    # Creating new templates
│   └── ai-coding-workflows-foundation/  # Planning/Implementation/Validation workflow
├── validation/                 # Validation command resources
├── create-project.sh           # Create new project from template
└── CLAUDE.md                  # Global AI coding rules
```

**All three IDEs:** `/generate-validate` creates **`/validate-project`** in each (VS Code, Claude Code, Cursor). Use **`/validate-project`** (not `/validate`) for project validation.

## Core Workflow: The PRP Pattern

**Always follow this workflow for feature implementation (execution order):**

1. **`/new-project`** (optional) → Create new project from template
2. **INITIAL.md** → Define requirements in structured format
3. **`/generate-prp INITIAL.md`** → AI creates comprehensive implementation plan
4. **`/generate-validate`** → Once or after significant change; create **`/validate-project`** for your project (run after planning, before building)
5. **`/build-prp PRPs/feature-name.md`** (optional) → Finalize PRP (review/edit), then optionally build and run
6. **`/execute-prp PRPs/feature-name.md`** → AI implements from PRP with validation loops
7. **`/validate-project`** → Verify implementation completeness (uses checks from `/generate-validate`; use this, not `/validate`, to avoid injected commands)

Key insight: PRPs embed ALL necessary context (docs, examples, gotchas) so AI can self-validate and iterate.

## File Organization Patterns

### Agent Code Structure (PydanticAI)
```
agents/[agent_name]/
├── agent.py          # Main agent definition
├── tools.py          # @agent.tool decorated functions
├── models.py         # Pydantic output models
├── dependencies.py   # External service integrations
├── settings.py       # Environment config with pydantic-settings
├── prompts.py        # System prompts (static/dynamic)
└── tests/            # pytest tests with TestModel/FunctionModel
```

### MCP Server Structure (TypeScript/Cloudflare)
```
src/
├── index.ts          # Main MCP server entry
├── tools/            # Tool registration system
├── auth/             # OAuth handlers
└── database/         # Connection utilities
```

## Code Standards

- **Max 500 lines per file** - split into modules when approaching
- **Use `python-dotenv` + `pydantic-settings`** for environment config (see `use-cases/pydantic-ai/examples/main_agent_reference/settings.py`)
- **Never hardcode secrets** - always use `.env` files
- **Tests in `/tests` folder** - include expected use, edge case, and failure case

### Python Environment
```bash
# Always use virtual environment (.venv or create with uv)
uv venv && uv sync
uv add package-name   # NEVER edit pyproject.toml directly
```

### MCP Server (npm/Wrangler)
```bash
npm install           # Install dependencies
wrangler dev          # Local development
wrangler deploy       # Deploy to Cloudflare
```

## Key Patterns to Follow

### PydanticAI Agent Creation
```python
from pydantic_ai import Agent, RunContext
from .settings import get_llm_model

agent = Agent(
    get_llm_model(),
    deps_type=AgentDependencies,
    system_prompt="..."
)

@agent.tool
async def my_tool(ctx: RunContext[AgentDependencies], query: str) -> str:
    return await external_call(ctx.deps.api_key, query)
```

### Testing AI Agents
Use `TestModel` for fast validation without API calls, `Agent.override()` for test contexts.

## Design Principles

- **KISS** - Choose straightforward solutions over complex ones
- **YAGNI** - Implement features only when needed
- **Context is King** - Include ALL necessary documentation, examples, patterns in PRPs

## Before Starting Any Task

1. Read the relevant `CLAUDE.md` (root or use-case specific)
2. Check `PRPs/templates/` for the appropriate template
3. Study `examples/` for patterns to follow
4. Use web search extensively for library documentation

## VS Code Prompt Commands

Use these prompts in Copilot Chat as slash commands (run `./SETUP-VSCODE.sh` for automated setup):

| Order | Command | Purpose |
|-------|---------|---------|
| 1 | `/new-project` | Create a new project from the context-engineering template |
| 2 | `/generate-prp` | Create implementation plan from INITIAL.md |
| 3 | `/generate-validate` | Analyze codebase and create **`/validate-project`** from example-validate (once or after significant change) |
| 4 | `/build-prp` | Finalize PRP (review/edit), then optionally build and run (before implementing) |
| 5 | `/execute-prp` | Implement feature from PRP with validation |
| 6 | **`/validate-project`** | Run project-specific validation (generated by `/generate-validate`); use this, not `/validate`, to avoid injected commands |
| 6b | `/validate` | Run template 8-phase validation (this repo only) |
| 7 | `/generate-prompt` | Generate XML-structured prompt with ambiguity detection |

**Usage examples (in order):**
```
/new-project ~/projects/my-new-app
/generate-prp INITIAL.md
/generate-validate          # once or after significant change
/build-prp PRPs/my-feature.md   # optional: finalize then build
/execute-prp PRPs/my-feature.md
/validate-project           # project-specific (from /generate-validate); use this, not /validate
/generate-prompt Create a caching layer for API responses   # anytime
```

### /validate-project and /validate
- **`/validate-project`** (generated by `/generate-validate`): Run project-specific validation (lint, type check, style, unit tests, E2E). Use this in your projects to avoid conflicts with injected `/validate` commands.
- **`/validate`** (template repo only): Runs 8 phases for the context-engineering template:
1. Project Structure - Verify critical files exist
2. TypeScript (MCP Server) - Type checking, unit tests
3. Python (PydanticAI) - Syntax validation, pytest
4. Documentation - Markdown links, frontmatter
5. E2E Workflows - INITIAL.md, generate-prp, generate-validate, build-prp, execute-prp, validate-project
6. Use-Case Specific - Each use-case structure
7. Cross-Reference - Ensure consistency
8. Journal - Daily validation entries

## Validation Requirements

Every implementation must include executable validation:
```bash
# Python
ruff check --fix && mypy .
uv run pytest tests/ -v

# TypeScript
npm run type-check
wrangler dev
```
