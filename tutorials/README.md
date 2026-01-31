# Tutorials

Learn the Context Engineering process through a hands-on User Tutorial.

## User Tutorial: Getting Started

**One tutorial, full workflow.** Build a "Daily Quote" web app while learning every command in order.

| Tutorial | Description | Time | Difficulty |
|----------|-------------|------|------------|
| [**Getting Started: Build Your First App**](getting-started-walkthrough.md) | Create a project (location & name asked first), PRD → PRP → validate → execute → validate → summarize. Daily Quote app with Flask, categories, favorites. | 30–45 min | Beginner–Intermediate |

### What You’ll Learn

- **Ask first:** The AI asks where to create the project and what to name it (outside this template).
- **Full workflow:** `/new-project` → describe in `INITIAL.md` → `/generate-prd` → `/generate-prp` → `/generate-validate` → `/build-prp` (optional) → `/execute-prp` → `/validate-project` → `/summarize`.
- **Commands in order:** All 9 commands (PRD, PRP, generate-validate, build-prp, execute-prp, validate-project, summarize, plus generate-prompt for quick tasks).

### Command Order (from [OVERVIEW](../OVERVIEW.md))

| Order | Command | When to run |
|-------|---------|-------------|
| 1 | `/new-project` | When starting a new project (after answering location & name) |
| 2 | — | Describe the feature in `INITIAL.md` or chat |
| 3 | `/generate-prd` | For each product/feature → PRD in `PRDs/` |
| 4 | `/generate-prp` | After PRD → execution plan in `PRPs/` |
| 5 | `/generate-validate` | Once or after a big change → creates `/validate-project` |
| 6 | `/build-prp` | Optional: finalize plan, then optionally build and run |
| 7 | `/execute-prp` | Implement from PRP |
| 8 | **`/validate-project`** | After building (use this, not `/validate`) |
| 9 | **`/summarize`** | After validate → completed steps + next actions |
| 10 | `/generate-prompt` | Anytime for small tasks |

## Sample INITIAL.md

The tutorial references a full `INITIAL.md` for the Daily Quote app. A copy you can paste from is in [examples/daily-quote-app/INITIAL.md](../examples/daily-quote-app/INITIAL.md).

## More Resources

- [OVERVIEW.md](../OVERVIEW.md) — One-page summary of the workflow
- [README.md](../README.md) — Full template documentation and setup
- [PRPs/templates/](../PRPs/templates/) — PRD and PRP templates
