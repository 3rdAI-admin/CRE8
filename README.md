# Context Engineering Template

**For non-technical folks and vibe coders:** This intro explains *why* this workflow exists, *what* it is, and *how* to use it—in plain language.

---

## Why

**“Vibe coding”** means asking the AI for something and hoping it works. Sometimes it does; often it doesn’t, because the AI is guessing—it doesn’t have your full picture (your project style, your rules, what “done” looks like).

**Context engineering** means giving the AI that full picture *up front*: your goals, examples, rules, and how to check that things work. Then the AI can build what you actually want, fix its own mistakes, and stay consistent with your project.

**In short:** Better context → fewer surprises, less rework, and code that fits your project instead of random snippets.

> **Context Engineering is 10x better than prompt engineering and 100x better than vibe coding.**

---

## What

This repo is a **workflow + a set of slash commands** that run inside your AI coding tool (VS Code with Copilot, Claude Code, or Cursor).

- **Workflow:** You describe what you want → the AI turns it into a detailed plan → the AI implements the plan and checks that it works.
- **Slash commands:** Short instructions you type in chat that tell the AI exactly what to do next. No need to write long prompts yourself.

**All 9 commands** (type `/` in chat to see them), in execution order:

| Order | Command | What it does | When to run |
|-------|---------|--------------|-------------|
| 1 | `/new-project` | Create a new project folder with this workflow preconfigured; copies slash commands for **selected IDE(s)** (`.github/`+`.vscode/` for VS Code, `.claude/` for Claude, `.cursor/`+`.cursorrules` for Cursor) so you can open it and continue with `/generate-prp`, `/execute-prp`, etc. | When starting a new project |
| 2 | **`/generate-prd`** | Turn your idea (e.g. from `INITIAL.md`) into a **professional Product Requirements Document (PRD)** | For each product/feature; output in `PRDs/` for review and planning |
| 3 | `/generate-prp` | Turn the PRD (or `INITIAL.md`) into a detailed **execution plan with multi-agent task breakdown** (PRP) | After PRD; for each feature or when you change requirements |
| 4 | `/generate-validate` | Have the AI create **`/validate-project`** from [.claude/commands/example-validate.md](.claude/commands/example-validate.md) | **Once, or after a significant project change** (run after planning, before building) |
| 5 | `/build-prp` | Review/finalize the PRP (edit if needed), then optionally build and run the project | After you have a PRP; when you want to finalize the plan before implementing |
| 6 | `/execute-prp` | Implement a feature by following the PRP and running checks | After `/build-prp` (or after `/generate-prp` if you skip review); main implementation path |
| 6 | **`/validate-project`** | Run the project’s checks (structure, lint, tests) and report pass/fail | After building; use this (not `/validate`) to avoid injected commands |
| 8 | **`/summarize`** | Summarize **completed steps and next actions** for user response | After validate (or execute); gives what's done and what to do next |
| 9 | `/generate-prompt` | Create a one-off, well-structured prompt for a small task | Anytime (for quick tasks, not full features) |
> **💡 Selective Installation:** The setup wizard (`./bin/setup.sh`) and `/new-project` command support selective IDE installation. When you select a specific IDE (e.g., VS Code), only that IDE's configuration files are copied to new projects. This keeps projects clean and focused on your chosen tool. Use `--all` to copy all IDE configurations.
The main idea is the **PRP** (Product Requirements Prompt): a single document that holds everything the AI needs—goal, steps, examples, and how to validate—so it can implement and self-correct instead of guessing.

---

## How (all 7 commands, in execution order)

1. **Create or open a project**  
   If you’re starting fresh, type **`/new-project`** and give it a path (e.g. `~/projects/my-app`). Otherwise open an existing project that already has this workflow.

2. **Describe your idea**  
   Fill in a simple template file (`INITIAL.md`) with what you want to build, any examples, and links or notes that matter.

3. **Get a plan**  
   In chat, type **`/generate-prp`** (and point it at your file). The AI researches your project and the topic, then writes a full implementation plan (the PRP) into a file in the `PRPs/` folder.

4. **Set up validation (once or after a big change)**  
   Type **`/generate-validate`**. The AI uses [.claude/commands/example-validate.md](.claude/commands/example-validate.md) to create **`/validate-project`** for your project. Run this **once**, or again after a significant project change; then use **`/validate-project`** (not `/validate`) to avoid conflicts with injected commands.

5. **Finalize the plan (optional)**  
   Type **`/build-prp`** when you want to review or edit the PRP before implementing, then optionally build and run. After that, use **`/execute-prp`** to implement the PRP and run checks.

6. **Confirm it works**  
   Type **`/validate-project`**. The AI runs the project’s checks (the ones set up by `/generate-validate`) and reports what passed or failed.

7. **Quick tasks (anytime)**  
   For a small, one-off task (not a full feature), type **`/generate-prompt`** and describe the task. The AI creates a focused prompt for it.

---

## Summary

| Step | Command | You do this | The AI does this |
|------|---------|-------------|------------------|
| 1 | `/new-project` | Create project (or open existing) | Sets up folder, workflow files, and slash commands for selected IDE(s)—new project is ready to use |
| 2 | — | Describe the feature in `INITIAL.md` | — |
| 3 | `/generate-prd` | Run for each product/feature | Creates a **professional PRD** in `PRDs/` (goals, scope, success criteria) |
| 4 | `/generate-prp` | Run after PRD (or from INITIAL.md) | Creates **execution plan** with multi-agent task breakdown |
| 5 | `/generate-validate` | Run **once or after significant change** | Creates **`/validate-project`** from example-validate template |
| 6 | `/build-prp` | Run when you want to finalize the plan before implementing | Finalizes PRP, then optionally builds and runs |
| 7 | `/execute-prp` | Implement from PRP | Implements the plan and runs checks |
| 8 | **`/validate-project`** | Run after building | Runs the generated validation (use this, not `/validate`, to avoid injected commands) |
| 9 | **`/summarize`** | Run after validate or execute | Summarizes completed steps and next actions |
| 10 | `/generate-prompt` | Use anytime for small tasks | Creates a one-off prompt for the task |

You stay in the driver’s seat: you describe *what* you want; the workflow and commands make sure the AI has *enough context* to build it the way you want and to verify that it works.

*A one-page standalone version of this intro is in [OVERVIEW.md](OVERVIEW.md).*

---

## 🚀 Quick Start

> **New to Context Engineering?** See the [User Tutorial: Getting Started](tutorials/getting-started-walkthrough.md) for a hands-on walkthrough (create project → PRD → PRP → validate → execute → summarize). More tutorial material is in [tutorials/README.md](tutorials/README.md).

### Unified Setup (Recommended)

**macOS/Linux:**
```bash
# 1. Clone this template
git clone https://github.com/coleam00/Context-Engineering-Intro.git
cd Context-Engineering-Intro

# 2. Run the interactive setup wizard
./setup.sh
```

**Windows (PowerShell):**
```powershell
# 1. Clone this template
git clone https://github.com/coleam00/Context-Engineering-Intro.git
cd Context-Engineering-Intro

# 2. Run the interactive setup wizard
.\setup.ps1
```
git clone https://github.com/coleam00/Context-Engineering-Intro.git
cd Context-Engineering-Intro

# 2. Run the interactive setup wizard
.\SETUP.ps1

# 3. Choose your IDE(s) from the menu
```

**Command-line flags (macOS/Linux):**
```bash
./bin/setup.sh --vscode   # VS Code only
./bin/setup.sh --claude   # Claude Code only
./bin/setup.sh --cursor   # Cursor only
./bin/setup.sh --all      # All IDEs
```

**Command-line flags (Windows):**
```powershell
.\setup.ps1 -VSCode   # VS Code only
.\setup.ps1 -Claude   # Claude Code only
.\setup.ps1 -Cursor   # Cursor only
.\setup.ps1 -All      # All IDEs
```

### Create a New Project

Once set up, create new projects from this template:

```bash
# Create a new project with all AI configuration
./create-project.sh ~/projects/my-new-app

# Or create with only specific IDE(s)
./create-project.sh ~/projects/my-new-app --vscode  # VS Code only
./create-project.sh ~/projects/my-new-app --claude  # Claude Code only
./create-project.sh ~/projects/my-new-app --cursor  # Cursor only
./create-project.sh ~/projects/my-new-app --all     # All IDEs (default)

# Open in your IDE and start building!
code ~/projects/my-new-app   # or: cursor .  or  claude .
```

**Note:** Without flags, `create-project.sh` copies **all slash-command config** (`.cursor/`, `.claude/`, `.github/`, `.vscode/`) into the new project. With IDE-specific flags (e.g., `--vscode`), only the selected IDE's configuration is copied. The setup wizard (`./setup.sh`) automatically uses these flags based on your IDE selection.

The new project also includes a **`journal/`** folder (with a starter index). When you run `/validate-project`, `/execute-prp`, or `/build-prp`, the AI appends progress to `journal/YYYY-MM-DD.md` and updates `journal/README.md`. Use the journal to see where you left off and resume after a computer restart or unexpected IDE shutdown.

### Option A: VS Code with GitHub Copilot

```bash
# 1. Clone this template
git clone https://github.com/coleam00/Context-Engineering-Intro.git
cd Context-Engineering-Intro

# 2. Run the setup script (installs extensions & configures settings)
./bin/setup-vscode.sh

# 3. Open in VS Code
code .

# 4. Open Copilot Chat (Cmd+Shift+I) and use commands:
/generate-prp INITIAL.md
/generate-validate          # once or after significant change
/build-prp PRPs/your-feature-name.md   # optional: finalize then build
/execute-prp PRPs/your-feature-name.md
/validate
```

### Option B: Claude Code

```bash
# 1. Clone this template
git clone https://github.com/coleam00/Context-Engineering-Intro.git
cd Context-Engineering-Intro

# 2. Run the setup script (verifies installation & configures permissions)
./bin/setup-claude.sh

# 3. Open this repo in Claude Code (slash commands come from .claude/skills/ in the open project)
claude .

# 4. In chat, type / to see all 7 commands; then use:
/generate-prp INITIAL.md
/generate-validate          # once or after significant change
/build-prp PRPs/your-feature-name.md   # optional: finalize then build
/execute-prp PRPs/your-feature-name.md
/validate
```

**Using a different project?** Projects **created with `/new-project`** already have all slash commands copied in—just open that project in Claude Code and use `/generate-prp`, `/execute-prp`, etc. For an **existing** project that was *not* created from this template, run from the template repo: `./install-claude-commands.sh` and enter the project path (or `./install-claude-commands.sh /path/to/project`). Then open that project in Claude Code and restart.

### Option C: Cursor

```bash
# 1. Clone this template
git clone https://github.com/coleam00/Context-Engineering-Intro.git
cd Context-Engineering-Intro

# 2. Run the setup script (creates AI rules & settings)
./bin/setup-cursor.sh

# 3. Open in Cursor
cursor .

# 4. Use slash commands in chat:
/generate-prp INITIAL.md
/generate-validate          # once or after significant change
/build-prp PRPs/your-feature-name.md   # optional: finalize then build
/execute-prp PRPs/your-feature-name.md
/validate
# For quick tasks (not full features):
/generate-prompt Create a caching layer
```

## 📚 Table of Contents

- [Why](#why) – Why context engineering beats vibe coding
- [What](#what) – Workflow and slash commands
- [How (all 7 commands)](#how-all-7-commands-in-execution-order) – Execution order with “once or after significant change” notes
- [Summary](#summary) – You do / AI does table
- [Overview (standalone)](OVERVIEW.md) – One-page version of the intro above
- [What is Context Engineering?](#what-is-context-engineering)
- [IDE Support](#ide-support)
- [Template Structure](#template-structure)
- [Available Commands](#available-commands)
- [Tutorials](#tutorials)
- [Validation & Quality](#validation--quality)
- [Additional Resources](#additional-resources)
- [Step-by-Step Guide](#step-by-step-guide)
- [Writing Effective INITIAL.md Files](#writing-effective-initialmd-files)
- [The PRP Workflow](#the-prp-workflow)
- [Using Examples Effectively](#using-examples-effectively)
- [Use Cases](#use-cases)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## What is Context Engineering?

Context Engineering represents a paradigm shift from traditional prompt engineering:

### Prompt Engineering vs Context Engineering

**Prompt Engineering:**
- Focuses on clever wording and specific phrasing
- Limited to how you phrase a task
- Like giving someone a sticky note

**Context Engineering:**
- A complete system for providing comprehensive context
- Includes documentation, examples, rules, patterns, and validation
- Like writing a full screenplay with all the details

### Why Context Engineering Matters

1. **Reduces AI Failures**: Most agent failures aren't model failures - they're context failures
2. **Ensures Consistency**: AI follows your project patterns and conventions
3. **Enables Complex Features**: AI can handle multi-step implementations with proper context
4. **Self-Correcting**: Validation loops allow AI to fix its own mistakes

## IDE Support

This template supports **VS Code (GitHub Copilot), Claude Code, and Cursor** with equivalent functionality:

| Feature | VS Code | Claude Code | Cursor |
|---------|---------|-------------|--------|
| Setup | `./bin/setup-vscode.sh` | `./bin/setup-claude.sh` | `./bin/setup-cursor.sh` |
| Instructions | `.github/copilot-instructions.md` | `CLAUDE.md` | `.cursorrules` |
| Slash Commands | `.github/prompts/*.prompt.md` | `.claude/commands/*.md` | `.cursor/prompts/*.md` |
| Settings | `.vscode/settings.json` | `.claude/settings.local.json` | `.cursor/settings.json` |

## Template Structure

```
context-engineering-intro/
├── .claude/                   # Claude Code configuration
│   ├── commands/
│   │   ├── new-project.md     # Creates new project from template
│   │   ├── generate-prp.md    # Generates comprehensive PRPs
│   │   ├── execute-prp.md     # Executes PRPs to implement features
│   │   ├── build-prp.md       # Launch build from finalized PRP
│   │   ├── generate-prompt.md # Generates XML-structured prompts
│   │   ├── validate-project.md # Project validation (generated by /generate-validate)
│   │   ├── validate.md        # Template validation (this repo only)
│   │   └── generate-validate.md # Creates /validate-project from example-validate
│   ├── skills/                 # Skills (invoke commands/; needed for slash-menu discovery)
│   │   ├── new-project/SKILL.md
│   │   ├── generate-prp/SKILL.md
│   │   ├── execute-prp/SKILL.md
│   │   ├── build-prp/SKILL.md
│   │   ├── generate-prompt/SKILL.md
│   │   ├── validate/SKILL.md
│   │   └── generate-validate/SKILL.md
│   └── settings.local.json    # Claude Code permissions
├── .github/                   # VS Code Copilot configuration
│   ├── copilot-instructions.md  # Global AI instructions
│   └── prompts/               # Slash command definitions
│       ├── new-project.prompt.md
│       ├── generate-prp.prompt.md
│       ├── execute-prp.prompt.md
│       ├── build-prp.prompt.md
│       ├── generate-prompt.prompt.md
│       ├── validate-project.prompt.md  # Project validation (generated by /generate-validate)
│       ├── validate.prompt.md          # Template validation (this repo only)
│       └── generate-validate.prompt.md
├── .vscode/
│   ├── settings.json          # Workspace settings (auto-applied)
│   └── README.md              # VS Code setup documentation
├── .cursor/                   # Cursor IDE configuration
│   ├── prompts/               # Slash command definitions
│   │   ├── new-project.md
│   │   ├── generate-prp.md
│   │   ├── execute-prp.md
│   │   ├── build-prp.md        # Launch build from finalized PRP
│   │   ├── generate-prompt.md
│   │   ├── validate-project.md # Project validation (generated by /generate-validate)
│   │   ├── validate.md        # Template validation (this repo only; 8 phases + journal)
│   │   └── generate-validate.md
│   ├── settings.json          # Cursor workspace settings
│   └── README.md              # Cursor setup documentation
├── .cursorrules               # Cursor AI rules file
├── bin/                       # All setup and utility scripts
│   ├── setup.sh               # Unified interactive setup
│   ├── setup-vscode.sh        # VS Code setup
│   ├── setup-claude.sh        # Claude Code setup
│   ├── setup-cursor.sh        # Cursor setup
│   ├── create-project.sh      # Create new project from template
│   ├── sync-commands.sh       # Sync commands across IDEs
│   └── install-dev-tools.sh   # Install dev dependencies
├── docs/                      # Documentation
│   ├── overview.md            # One-page workflow summary
│   ├── tutorials/             # Learning resources
│   └── validation/            # Validation command resources
├── examples/                  # Example projects
│   └── daily-quote-app/       # Tutorial sample project
├── PRPs/                      # Project plans
│   └── templates/             # PRD and PRP templates
├── use-cases/                 # Reference implementations
│   ├── pydantic-ai/           # PydanticAI agent development
│   └── mcp-server/            # MCP server template
├── journal/                   # Validation journal (progress tracking; resume after restart or IDE shutdown)
├── CLAUDE.md                  # AI assistant rules
├── INITIAL.md                 # Feature request template
└── README.md                  # This file
```

This template doesn't focus on RAG and tools with context engineering because I have a LOT more in store for that soon. ;)

## Available Commands

VS Code, Claude Code, and Cursor all support these slash commands:

| Order | Command | Description | When to run |
|-------|---------|-------------|-------------|
| 1 | `/new-project` | Create a new project from the template; **copies all slash commands** into the new project so you can open it and finish the workflow | When starting a new project |
| 2 | **`/generate-prd`** | Create **professional Product Requirements Document (PRD)** from INITIAL.md or input | For each product/feature; output in `PRDs/` for review and planning |
| 3 | `/generate-prp` | Generate a comprehensive PRP from PRD or INITIAL.md file | After PRD; for each feature or when requirements change |
| 4 | `/generate-validate` | Analyze codebase and create **`/validate-project`** from [.claude/commands/example-validate.md](.claude/commands/example-validate.md) | **Once, or after a significant project change** (run after planning, before building) |
| 5 | `/build-prp` | **Review/finalize** the PRP (edit if needed), then optionally **build** and **run** the project | After you have a PRP; when you want to finalize the plan before implementing |
| 6 | `/execute-prp` | Implement a feature from a PRP with validation loops | After `/build-prp` (or after `/generate-prp` if you skip review); main implementation path |
| 7 | **`/validate-project`** | Run project-specific validation (generated by `/generate-validate`) | After building; use this (not `/validate`) to avoid injected commands |
| 7b | `/validate` | Run template validation (8 phases + journal) in this repo only | When validating the context-engineering template itself |
| 8 | **`/summarize`** | Summarize **completed steps and next actions** for user response | After validate (or execute); gives what's done and what to do next |
| 9 | `/generate-prompt` | Generate an XML-structured prompt with ambiguity detection | Anytime (for quick tasks, not full features) |

### The Complete Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  /new-project   │────▶│   INITIAL.md    │────▶│  /generate-prp  │
│  (scaffold new  │     │  (define your   │     │   (research &   │
│   project)      │     │   requirements) │     │    planning)    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
         ┌───────────────────────────────────────────────┘
         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ /generate-      │────▶│   /build-prp     │────▶│  /execute-prp    │
│  validate       │     │  (finalize PRP,  │     │  (implement      │
│  (once/change)  │     │   optionally     │     │   from PRP)      │
└─────────────────┘     │   build & run)  │     └────────┬────────┘
                        └─────────────────┘              │
                                                         ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │    Complete!    │◀────│ /validate-project│
                        │                 │     │  (verify all    │
                        │                 │     │   passes)       │
                        └─────────────────┘     └─────────────────┘
```

Run **`/generate-validate`** once (or after a significant project change) to create **`/validate-project`** from [.claude/commands/example-validate.md](.claude/commands/example-validate.md). Use **`/validate-project`** (not `/validate`) for project-specific validation to avoid conflicts with injected commands. Use **`/build-prp`** to (1) **finalize** the PRP (review, edit if needed), (2) optionally **build** and **run**; then use **`/execute-prp`** to implement from the PRP. PRP path is optional—the AI can list PRPs if none is given.

### The /validate-project and /validate Commands

**Project-specific validation (recommended):** Run **`/validate-project`** after building. This uses the validation generated by **`/generate-validate`** (from [.claude/commands/example-validate.md](.claude/commands/example-validate.md)) and avoids conflicts with team/global **`/validate`** commands.

**Template validation (this repo only):** In the context-engineering template repo, **`/validate`** runs the 8-phase template check (structure, use-cases, TypeScript, Python, shell, JSON/YAML, Markdown, docs + journal).

**What it validates:**
- ✅ Project structure (core files, setup scripts, command parity)
- ✅ Use-case structure (all 5 templates with documentation)
- ✅ TypeScript (type checking, tests, formatting for MCP server)
- ✅ Python (syntax, linting with ruff, type checking with mypy, tests)
- ✅ Shell scripts (shebangs, executability, shellcheck)
- ✅ JSON/YAML (syntax validation with JSONC support)
- ✅ Markdown (link checking, linting)
- ✅ Documentation (README references, PRP templates)

**Quick validation tips:**
- Run after making changes to verify everything works
- Use `--thorough` flag for complete validation including tests
- Install optional tools for better validation: `pip install ruff mypy pytest`
- For MCP server: `cd use-cases/mcp-server && npm install`

### The /generate-prompt Command

For standalone prompts (not full PRPs), use `/generate-prompt` to create well-engineered XML-structured prompts:

**Features:**
- **Ambiguity Detection**: Automatically identifies vague or unclear requests
- **Clarifying Questions**: Asks targeted questions before generating
- **Adaptive Reasoning**: Selects appropriate complexity based on task analysis
- **WHY Explanations**: Every constraint includes reasoning

**Usage:**
```
/generate-prompt Create a caching layer for API responses
```

**Example interaction:**
1. AI detects ambiguity: "Cache for what? TTL or event-based invalidation?"
2. You provide details: "Redis cache, 5-minute TTL, for product catalog"
3. AI generates structured prompt saved to `PRPs/prompts/001-caching-layer.md`

**Generated prompts include:**
- `<objective>` - Clear task statement
- `<context>` - Background and purpose
- `<requirements>` - Numbered, actionable items
- `<constraints>` - Rules WITH why explanations
- `<output>` - Expected deliverables
- `<verification>` - Validation checklist
- `<success_criteria>` - Measurable completion criteria

## Validation & Quality

### Automated Validation

This template includes comprehensive validation tools to ensure quality:

#### 1. `/validate-project` Command (all three IDEs)
**`/generate-validate`** creates **`/validate-project`** in VS Code (Copilot), Claude Code, and Cursor. Run it after building:

```bash
/validate-project           # Standard validation
/validate-project --thorough   # Includes all tests
```

Use **`/validate-project`** (not `/validate`) so project-specific validation is not overridden by team or global commands. In this template repo only, **`/validate`** runs the 8-phase template check.

**What it validates (project-specific, from /generate-validate):**
- ✅ Linting, type checking, style checking
- ✅ Unit tests
- ✅ Structure & documentation (and E2E when generated)
- ✅ (Template repo: project structure, TypeScript, Python, shell, JSON/YAML, Markdown, docs, journal)

#### 2. Pre-commit Hooks
Automatically validate before each commit:

```bash
# Install pre-commit
pip install pre-commit

# Setup hooks
pre-commit install
pre-commit install --hook-type commit-msg

# Run manually
pre-commit run --all-files
```

**What it checks:**
- Python: ruff (linting + formatting), file quality
- Shell: shellcheck
- Markdown: markdownlint
- JSON/YAML: syntax validation
- Custom: README completeness, executable scripts

See [.pre-commit-README.md](.pre-commit-README.md) for details.

#### 3. GitHub Actions CI/CD
Automatic validation on every push and PR:

- Runs all validation phases in parallel
- Fast feedback on issues
- Ensures consistent quality across contributions
- See [.github/workflows/validate.yml](.github/workflows/validate.yml)

### Optional Development Tools

Install for enhanced validation:

```bash
# Using pip
pip install -r requirements-dev.txt

# Using uv (recommended)
uv pip install -r requirements-dev.txt

# Just the essentials
pip install ruff mypy pytest pre-commit
```

**Included tools:**
- `ruff`: Fast Python linter and formatter
- `mypy`: Static type checking
- `pytest`: Test framework with plugins
- `pre-commit`: Git hooks framework
- `ipython`: Enhanced Python REPL
- `rich`: Beautiful terminal output

## Tutorials

Learn by doing with hands-on tutorials:

| Tutorial | Description | Difficulty | Time |
|----------|-------------|------------|------|
| [Part 1: Daily Quote Web App](tutorials/getting-started-walkthrough.md) | Build a Flask web app for humans | Beginner | 30-45 min |
| [Part 2: MCP Quote Server](tutorials/mcp-quote-server.md) | Build an MCP server for AI assistants | Intermediate | 45-60 min |

### Two-Part Series

These tutorials work together to show the same domain (quotes) served two ways:

```
        QUOTE DATA
            │
    ┌───────┴───────┐
    ▼               ▼
Part 1: Flask   Part 2: MCP
(Python)        (TypeScript)
    │               │
    ▼               ▼
👤 Humans       🤖 AI Assistants
via browser     via natural language
```

**Part 1** teaches the PRP workflow with Python/Flask.  
**Part 2** applies the same workflow to TypeScript/Cloudflare Workers.

Complete them independently or as a series!

## Additional Resources

| Resource | Description |
|----------|-------------|
| [Claude Code Full Guide](claude-code-full-guide/README.md) | Comprehensive 500+ line guide to Claude Code with advanced techniques |
| [Validation Resources](validation/README.md) | How to create and customize validation commands |
| [PRP Template](PRPs/templates/prp_base.md) | Base template for creating PRPs |

## Step-by-Step Guide

### 1. Set Up Global Rules (CLAUDE.md)

The `CLAUDE.md` file contains project-wide rules that the AI assistant will follow in every conversation. The template includes:

- **Project awareness**: Reading planning docs, checking tasks
- **Code structure**: File size limits, module organization
- **Testing requirements**: Unit test patterns, coverage expectations
- **Style conventions**: Language preferences, formatting rules
- **Documentation standards**: Docstring formats, commenting practices

**You can use the provided template as-is or customize it for your project.**

### 2. Create Your Initial Feature Request

Edit `INITIAL.md` to describe what you want to build:

```markdown
## FEATURE:
[Describe what you want to build - be specific about functionality and requirements]

## EXAMPLES:
[List any example files in the examples/ folder and explain how they should be used]

## DOCUMENTATION:
[Include links to relevant documentation, APIs, or MCP server resources]

## OTHER CONSIDERATIONS:
[Mention any gotchas, specific requirements, or things AI assistants commonly miss]
```

**See `INITIAL_EXAMPLE.md` for a complete example.**

### 3. Generate the PRP

PRPs (Product Requirements Prompts) are comprehensive implementation blueprints that include:

- Complete context and documentation
- Implementation steps with validation
- Error handling patterns
- Test requirements

They are similar to PRDs (Product Requirements Documents) but are crafted more specifically to instruct an AI coding assistant.

Run in Claude Code:
```bash
/generate-prp INITIAL.md
```

**Note:** Slash commands appear in Claude Code via `.claude/skills/` (skills are discovered for the `/` menu). Each skill invokes the full instructions in `.claude/commands/`. You can view implementation in `.claude/commands/`:
- `.claude/commands/generate-prp.md` - See how it researches and creates PRPs
- `.claude/commands/execute-prp.md` - See how it implements features from PRPs

The `$ARGUMENTS` variable in these commands receives whatever you pass after the command name (e.g., `INITIAL.md` or `PRPs/your-feature.md`).

This command will:
1. Read your feature request
2. Research the codebase for patterns
3. Search for relevant documentation
4. Create a comprehensive PRP in `PRPs/your-feature-name.md`

### 4. Execute the PRP

Once generated, execute the PRP to implement your feature:

```bash
/execute-prp PRPs/your-feature-name.md
```

The AI coding assistant will:
1. Read all context from the PRP
2. Create a detailed implementation plan
3. Execute each step with validation
4. Run tests and fix any issues
5. Ensure all success criteria are met

## Writing Effective INITIAL.md Files

### Key Sections Explained

**FEATURE**: Be specific and comprehensive
- ❌ "Build a web scraper"
- ✅ "Build an async web scraper using BeautifulSoup that extracts product data from e-commerce sites, handles rate limiting, and stores results in PostgreSQL"

**EXAMPLES**: Leverage the examples/ folder
- Place relevant code patterns in `examples/`
- Reference specific files and patterns to follow
- Explain what aspects should be mimicked

**DOCUMENTATION**: Include all relevant resources
- API documentation URLs
- Library guides
- MCP server documentation
- Database schemas

**OTHER CONSIDERATIONS**: Capture important details
- Authentication requirements
- Rate limits or quotas
- Common pitfalls
- Performance requirements

## The PRP Workflow

### How /generate-prp Works

The command follows this process:

1. **Research Phase**
   - Analyzes your codebase for patterns
   - Searches for similar implementations
   - Identifies conventions to follow

2. **Documentation Gathering**
   - Fetches relevant API docs
   - Includes library documentation
   - Adds gotchas and quirks

3. **Blueprint Creation**
   - Creates step-by-step implementation plan
   - Includes validation gates
   - Adds test requirements

4. **Quality Check**
   - Scores confidence level (1-10)
   - Ensures all context is included

### How /execute-prp Works

1. **Load Context**: Reads the entire PRP
2. **Plan**: Creates detailed task list using TodoWrite
3. **Execute**: Implements each component
4. **Validate**: Runs tests and linting
5. **Iterate**: Fixes any issues found
6. **Complete**: Ensures all requirements met

See `PRPs/EXAMPLE_multi_agent_prp.md` for a complete example of what gets generated.

## Using Examples Effectively

The `examples/` folder is **critical** for success. AI coding assistants perform much better when they can see patterns to follow.

### What to Include in Examples

1. **Code Structure Patterns**
   - How you organize modules
   - Import conventions
   - Class/function patterns

2. **Testing Patterns**
   - Test file structure
   - Mocking approaches
   - Assertion styles

3. **Integration Patterns**
   - API client implementations
   - Database connections
   - Authentication flows

4. **CLI Patterns**
   - Argument parsing
   - Output formatting
   - Error handling

### Example Structure

When creating your own project, organize examples like this:

```
your-project/
├── examples/           # Your reference examples
├── journal/            # Daily validation journal (progress tracking; populated by /validate-project, /execute-prp, /build-prp—resume after restart or IDE shutdown)
│   ├── README.md       # Explains what each example demonstrates
│   ├── cli.py          # CLI implementation pattern
│   ├── agent/          # Agent architecture patterns
│   │   ├── agent.py    # Agent creation pattern
│   │   ├── tools.py    # Tool implementation pattern
│   │   └── providers.py # Multi-provider pattern
│   └── tests/          # Testing patterns
│       ├── test_agent.py # Unit test patterns
│       └── conftest.py   # Pytest configuration
```

> **Note:** See `use-cases/pydantic-ai/examples/` for ready-to-use PydanticAI examples.

## Use Cases

This template includes specialized configurations for different AI development scenarios:

### PydanticAI Agents (`use-cases/pydantic-ai/`)
Build production-grade AI agents with tools, memory, and structured outputs.
- Agent creation patterns with dependency injection
- Tool integration using `@agent.tool` decorators
- Testing with `TestModel` and `FunctionModel`
- Multi-provider support (OpenAI, Anthropic, Gemini)

### MCP Servers (`use-cases/mcp-server/`)
Build Model Context Protocol servers on Cloudflare Workers.
- TypeScript/Node.js with Wrangler CLI
- GitHub OAuth authentication
- PostgreSQL database integration
- Tool registration patterns

### Agent Factory (`use-cases/agent-factory-with-subagents/`)
Multi-agent orchestration system with specialized subagents.
- Phase-based workflow (0-5)
- Subagent coordination and handoffs
- RAG pipeline integration

### Template Generator (`use-cases/template-generator/`)
Create new use-case templates for this framework.

Each use-case has its own `CLAUDE.md` with specialized rules and `README.md` with setup instructions.

## Best Practices

### 1. Be Explicit in INITIAL.md
- Don't assume the AI knows your preferences
- Include specific requirements and constraints
- Reference examples liberally

### 2. Provide Comprehensive Examples
- More examples = better implementations
- Show both what to do AND what not to do
- Include error handling patterns

### 3. Use Validation Gates
- PRPs include test commands that must pass
- AI will iterate until all validations succeed
- This ensures working code on first try

### 4. Leverage Documentation
- Include official API docs
- Add MCP server resources
- Reference specific documentation sections

### 5. Customize CLAUDE.md
- Add your conventions
- Include project-specific rules
- Define coding standards

## Troubleshooting

### Validation Issues

**"tsconfig.json invalid JSON" or ".vscode/settings.json invalid JSON"**
- These are JSONC files (JSON with Comments) - this is expected and not an error
- The validation command now properly handles JSONC files

**"npm install" or dependencies missing**
```bash
# Install MCP server dependencies
cd use-cases/mcp-server && npm install

# Install Python tooling (optional but recommended)
pip install ruff mypy pytest
# or with uv:
uv add ruff mypy pytest
```

**"Command not found" errors**
- Some validation checks are optional (shellcheck, markdownlint, yamllint)
- Install them if needed, or validation will skip gracefully:
```bash
# macOS
brew install shellcheck markdownlint-cli yamllint

# Linux
sudo apt-get install shellcheck ruby-mdl yamllint
```

### Daily Quote Tutorial (Flask App)

**"Address already in use" or port 5000 refused on macOS**
- macOS Monterey and later use port 5000 for AirPlay Receiver
- The Daily Quote app is built to use **port 5001** by default on macOS
- Open [http://localhost:5001](http://localhost:5001) after running `python app.py`
- On Linux/Windows, the app may use 5000—check the terminal output for the URL

**Flask app not loading / "Module not found"**
```bash
# Use a virtual environment (recommended)
cd your-daily-quote-project
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

### Setup Script Issues

**"Permission denied" when running scripts**
```bash
chmod +x SETUP*.sh bin/create-project.sh install-claude-commands.sh
```

**Scripts fail with "command not found"**
- Ensure you have the required tools: git, node, npm, python3
- Run the appropriate setup script for your IDE first

### IDE-Specific Issues

**VS Code: Slash commands not working**
- Ensure GitHub Copilot extension is installed and activated
- Check `.github/prompts/*.prompt.md` files exist
- Restart VS Code after installation

**Claude Code: Commands not appearing in the `/` menu**
- Slash commands come from **`.claude/skills/`** in the **project you have open**. Projects **created with `/new-project`** already have the commands—just open that project. For an **existing** project not created from this template:
- **To install the 7 commands into that existing project**, run from the template repo:
  ```bash
  cd /path/to/context-engineering
  ./install-claude-commands.sh
  ```
  The script will prompt for the install path (or run `./install-claude-commands.sh /path/to/your/project` to pass the path directly).
- Then open that project in Claude Code and **restart Claude Code** (Cmd+Q, reopen) so it rescans `.claude/skills/`.
- Ensure scripts are executable: `chmod +x install-claude-commands.sh` if you get "permission denied".

**Cursor: Prompts not available**
- Ensure `.cursor/prompts/*.md` files exist
- Check Cursor AI features are enabled in settings
- Run `./bin/setup-cursor.sh` to verify configuration

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

## Acknowledgements

This project was created by **[Cole Medin](https://github.com/coleam00)**.

- 🐦 Twitter/X: [@coleam00](https://twitter.com/coleam00)
- 📺 YouTube: [Cole Medin](https://www.youtube.com/@ColeMedin)
- 💻 GitHub: [coleam00](https://github.com/coleam00)

### Contributors

- **[James Avila](https://th3rdai.com)** - Multi-IDE support (VS Code, Claude Code, Cursor), validation framework, documentation improvements

If you find this template helpful, consider:
- ⭐ Starring the repository
- 🔀 Contributing improvements via PRs
- 📢 Sharing with others who might benefit

## License

MIT License - see [LICENSE](LICENSE) for details.