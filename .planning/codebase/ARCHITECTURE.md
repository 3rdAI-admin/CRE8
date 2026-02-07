# Architecture

**Analysis Date:** 2026-02-07

## Pattern Overview

**Overall:** Context Engineering Workflow Template with Multi-IDE Support and Use-Case Reference Implementations

**Key Characteristics:**
- Command-driven workflow system for AI-assisted development (slash commands)
- Template-based project scaffolding with IDE-specific configurations
- Multi-use-case reference implementations (PydanticAI agents, MCP servers, Flask apps)
- Documentation-first approach with PRP (Product Requirements Prompt) patterns
- Validation and journal-based progress tracking

## Layers

**Presentation/CLI Layer:**
- Purpose: User interface for slash commands and workflow interaction
- Location: `.claude/commands/`, `.cursor/prompts/`, `.github/prompts/`
- Contains: Markdown-based command definitions and prompts
- Depends on: Configuration files, utility scripts
- Used by: IDE integrations (Claude Code, Cursor, VS Code Copilot)

**Command Infrastructure Layer:**
- Purpose: Execute CLI operations and manage project workflows
- Location: `bin/`, `.claude/skills/`, `.commands/`
- Contains: Bash/PowerShell setup scripts, skill definitions
- Depends on: Package managers (npm, pip), external tools (git, python)
- Used by: IDE extensions, users running terminal commands

**Use-Case Reference Layer:**
- Purpose: Provide working examples and templates for specific AI development patterns
- Location: `use-cases/pydantic-ai/`, `use-cases/mcp-server/`, `examples/`
- Contains: Complete working implementations with examples and documentation
- Depends on: Language-specific frameworks (PydanticAI, Cloudflare Workers, Flask)
- Used by: Developers learning patterns, copied in new projects via `/new-project`

**PRP/Planning Layer:**
- Purpose: Define and store project requirements and implementation plans
- Location: `PRPs/`, `.planning/codebase/`
- Contains: Templates for PRDs and PRPs, codebase analysis documents
- Depends on: Documentation standards from CLAUDE.md
- Used by: `/generate-prp`, `/execute-prp` commands for structured planning

**Documentation Layer:**
- Purpose: Provide learning resources and implementation guides
- Location: `docs/`, use-cases CLAUDE.md files, README files
- Contains: Tutorials, API references, conventions
- Depends on: Project documentation standards
- Used by: Developers during onboarding and development

## Data Flow

**Complete Workflow Flow:**

1. **Project Initialization**
   - User runs `/new-project` or opens existing project
   - Command copies appropriate IDE configs (.claude/, .cursor/, .github/) based on IDE selection
   - New project gets INITIAL.md template and all slash commands pre-installed

2. **Planning Phase**
   - User fills INITIAL.md with feature description
   - User runs `/generate-prd` to create Product Requirements Document in `PRDs/`
   - User runs `/generate-prp` with PRD as input
   - Command researches codebase patterns, external APIs, documentation
   - Generates comprehensive PRP in `PRPs/` with multi-agent task breakdown

3. **Validation Setup Phase**
   - User runs `/generate-validate` once (or after significant changes)
   - Command analyzes codebase structure, testing patterns, lint/type-check setup
   - Generates project-specific `/validate-project` command
   - Saves validation command to `.claude/commands/validate-project.md` (and IDE equivalents)

4. **Implementation Phase**
   - User runs `/build-prp` to review/finalize PRP, optionally build and test
   - User runs `/execute-prp` with PRP file path
   - Command loads full context from PRP, creates task breakdown
   - Implements code following patterns from PRP, runs validation loops
   - Updates `journal/YYYY-MM-DD.md` with progress

5. **Quality Assurance Phase**
   - User runs `/validate-project` after building
   - Command executes all project checks (linting, type-checking, tests, structure)
   - Reports pass/fail with details
   - User can re-run `/execute-prp` for iterative fixes

6. **Summary & Documentation**
   - User runs `/summarize` to get status
   - Command reports completed steps and next actions
   - Journal automatically updated with session progress

**State Management:**
- State persists in files: INITIAL.md, PRDs/, PRPs/, journal/
- Validation state tracked in journal/YYYY-MM-DD.md
- No session state needed; complete from any point by reading relevant files

## Key Abstractions

**PRP (Product Requirements Prompt):**
- Purpose: Complete implementation blueprint for AI assistants
- Examples: `PRPs/templates/prp_base.md`, generated PRP files in `PRPs/`
- Pattern: Markdown document with context, requirements, task breakdown, validation gates

**Slash Command:**
- Purpose: IDE-integrated workflow trigger with fixed interface
- Examples: `/generate-prp`, `/execute-prp`, `/validate-project`
- Pattern: Markdown files in command directories read by IDEs, define $ARGUMENTS handling

**Use-Case Template:**
- Purpose: Reference implementation showing patterns for specific domain
- Examples: `use-cases/pydantic-ai/examples/basic_chat_agent/`, `use-cases/mcp-server/src/`
- Pattern: Complete, working code with CLAUDE.md overrides and README.md guidance

**Project Scaffold:**
- Purpose: Pre-configured template for new projects
- Examples: Copy via `./bin/create-project.sh`, populated by `/new-project`
- Pattern: Includes CLAUDE.md, INITIAL.md, directory structure, IDE configs, journal/

## Entry Points

**For Users (End-to-End Workflows):**

1. **IDE Chat/Command Prompt** (`/` menu in Claude Code, Cursor, VS Code Copilot)
   - Location: Triggered in IDE chat windows
   - Triggers: User typing `/command-name`
   - Responsibilities: Route to appropriate markdown command file

2. **Terminal Scripts** (`bin/setup.sh`, `bin/create-project.sh`)
   - Location: `/Volumes/TH3RDAI/CRE8v1.1/bin/`
   - Triggers: Direct execution (`./bin/setup.sh`)
   - Responsibilities: Install dependencies, set up IDE integrations, create projects

3. **Main README** (`/Volumes/TH3RDAI/CRE8v1.1/README.md`)
   - Location: Root of repository
   - Triggers: User reading/following instructions
   - Responsibilities: Explain overall workflow, link to tutorials and commands

**For Developers (Code Entry Points):**

1. **PydanticAI Examples** (`use-cases/pydantic-ai/examples/*/agent.py`)
   - Location: `use-cases/pydantic-ai/examples/{basic_chat_agent,tool_enabled_agent,structured_output_agent,main_agent_reference}/agent.py`
   - Triggers: Import or direct execution (`python -m examples.basic_chat_agent.agent`)
   - Responsibilities: Define agent, system prompts, tools, dependencies

2. **MCP Server** (`use-cases/mcp-server/src/index.ts`)
   - Location: `use-cases/mcp-server/src/index.ts`
   - Triggers: `wrangler dev` (local) or deployment
   - Responsibilities: Initialize MCP server, register tools, handle auth

3. **Flask Example App** (`examples/daily-quote-app/app.py`)
   - Location: `examples/daily-quote-app/app.py`
   - Triggers: `python app.py`
   - Responsibilities: Start Flask server, serve routes, fetch external data

## Error Handling

**Strategy:** Graceful degradation with detailed logging and user-friendly messages

**Patterns:**

1. **Command Failures**
   - Pattern: Commands exit with error message + suggestion
   - Example: `/generate-prp` missing PRD file → suggest running `/generate-prd` first
   - Implementation: Shell scripts check prerequisites before proceeding

2. **API Failures**
   - Pattern: Fallback to defaults, continue with reduced functionality
   - Example: `examples/daily-quote-app` → fetch_unsplash_image() fails → use picsum.photos default
   - Implementation: Try/except with fallback return values in `app.py` line 46-62

3. **Validation Failures**
   - Pattern: Detailed report with failure location and fix guidance
   - Example: `/validate-project` reports specific linting errors, file paths, and remediation
   - Implementation: Generated validation command checks each phase, accumulates results

4. **Tool Failures in MCP Server**
   - Pattern: Standardized error response format with user-friendly messaging
   - Example: Database query tool → SQL validation fails → return `{ type: "text", text: "Error: ...", isError: true }`
   - Implementation: Try/catch in tool handlers, `formatDatabaseError()` sanitizes messages

5. **Agent Tool Failures in PydanticAI**
   - Pattern: Tool returns error string or wrapped Exception, agent decides retry
   - Example: Tool authentication fails → agent sees error and can retry or notify
   - Implementation: Tool decorated with `@agent.tool`, returns string or raises exception

## Cross-Cutting Concerns

**Logging:**
- Approach: IDE logs (Claude Code logs, Cursor logs, VS Code Copilot logs) + shell script echoing
- Pattern: Markdown commands output via stdout/stderr; MCP tools use console.log/console.error; Flask app uses print()
- Reference: `bin/setup.sh` uses `echo` for progress; `use-cases/mcp-server/src/index.ts` uses `console.log()`

**Validation:**
- Approach: Multi-phase validation via generated `/validate-project` command
- Pattern: Each phase checks specific aspect (linting, typing, tests, structure, docs)
- Reference: `.claude/commands/example-validate.md` template; generated validation inherits structure
- Implementation: `.planning/codebase/` documents guide future codebase analysis

**Authentication:**
- Approach: Environment-based configuration (`.env` files) + IDE-specific secrets management
- Pattern: Python uses `python-dotenv` + Pydantic settings; MCP uses `wrangler secret put` for Cloudflare
- Reference: `use-cases/pydantic-ai/examples/shared/settings.py` for Python; `use-cases/mcp-server/` Cloudflare secrets
- Implementation: `CLAUDE.md` files specify how to load env vars for each use-case

**Testing:**
- Approach: Use-case specific (pytest for Python, vitest/MCP Inspector for TypeScript)
- Pattern: Tests live in `tests/` or `testing_examples/`, use local fixtures
- Reference: `use-cases/pydantic-ai/examples/testing_examples/test_agent_patterns.py`
- Implementation: PRP includes test requirements; `/execute-prp` runs validation gates with tests

---

*Architecture analysis: 2026-02-07*
