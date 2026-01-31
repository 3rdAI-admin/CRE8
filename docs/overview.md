# Context Engineering: One-Page Overview

**For semi-technical folks and vibe coders:** This page explains *why* this workflow exists, *what* it is, and *how* to use it—in plain language.

---

## Why

**“Vibe coding”** means asking the AI for something and hoping it works. Sometimes it does; often it doesn’t, because the AI is guessing—it doesn’t have your full picture (your project style, your rules, what “done” looks like).

**Context engineering** means giving the AI that full picture *up front*: a **professional PRD**, a **plan with small tasks** (multi-agent–friendly for accuracy), **validation**, and a **summary of what’s done and what’s next**. Then the AI can build what you actually want, fix its own mistakes, and you stay in the loop with clear next actions.

**In short:** Better context → fewer surprises, less rework, and code that fits your project instead of random snippets.

---

## What

This repo is a **workflow + a set of slash commands** that run inside your AI coding tool (VS Code with Copilot, Claude Code, or Cursor).

- **Workflow:** Create project → **Professional PRD** → **Plan with multi-agent tasks** → Generate validation → Execute plan → Validate → **Summarize (completed + next actions)**.
- **Slash commands:** Short instructions you type in chat so you don’t have to write long prompts yourself.

**Commands** (type `/` in chat), in execution order:

| Order | Command                | What it does                                                                        | When to run                                                                                                                     |
| ----- | ---------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 1     | `/new-project`       | Create a new project folder with this workflow preconfigured; **copies all slash commands** into the new project so you can open it and finish the workflow | When starting a new project                                                                                                     |
| 2     | `/generate-prd`      | Turn your idea (e.g. from `INITIAL.md`) into a **professional Product Requirements Document (PRD)** | For each product/feature; creates a stakeholder-ready PRD in `PRDs/` |
| 3     | `/generate-prp`      | Turn the PRD (or INITIAL.md) into an **execution plan with multi-agent task breakdown** (small tasks for accuracy) | After PRD; creates plan in `PRPs/` |
| 4     | `/generate-validate` | Have the AI create **`/validate-project`** for your project (from example-validate template) | **Once, or after a significant project change** (run after planning, before building) |
| 5     | `/build-prp`         | Review/finalize the plan (edit if needed), then optionally build and run            | After you have a PRP; when you want to finalize before implementing                                                             |
| 6     | `/execute-prp`       | Implement by following the PRP (multi-agent tasks) and running checks              | After `/build-prp` (or after `/generate-prp` if you skip review); main implementation path                                      |
| 7     | **`/validate-project`** | Run the project’s checks (structure, lint, tests) and report pass/fail              | After building; use checks from `/generate-validate` (use this, not `/validate`, to avoid injected commands) |
| 8     | **`/summarize`**     | **Summarize completed steps and next actions** for your response                     | After validate (or after execute); gives you what’s done and what to do next |
| 9     | `/generate-prompt`   | Create a one-off, well-structured prompt for a small task                             | Anytime (for quick tasks, not full features) |

The main idea: a **PRD** gives you a professional requirements doc; the **PRP** (execution plan) breaks the work into **small, assignable tasks** for accuracy; **validation** checks it works; **summarize** tells you what’s completed and what to do next so you can respond.

---

## How (commands in execution order)

1. **Create or open a project** If you’re starting fresh, type **`/new-project`** and give it a path (e.g. `~/projects/my-app`). Otherwise open an existing project that already has this workflow.
2. **Describe your idea** Fill in `INITIAL.md` (or describe in chat) with what you want to build, examples, and links that matter.
3. **Get a professional PRD** Type **`/generate-prd`** (and point at `INITIAL.md` if you use it). The AI creates a **Product Requirements Document** in `PRDs/` (goals, scope, success criteria, requirements) for review and for the next step.
4. **Get an execution plan with multi-agent tasks** Type **`/generate-prp`** (point at your PRD or INITIAL.md). The AI researches and writes an **execution plan (PRP)** in `PRPs/` with **small, assignable tasks** for accuracy (multi-agent–friendly).
5. **Set up validation (once or after a big change)** Type **`/generate-validate`**. The AI creates **`/validate-project`** for your project. Run this **once**, or again after a significant change; then use **`/validate-project`** (not `/validate`) to avoid injected commands.
6. **Finalize the plan (optional)** Type **`/build-prp`** when you want to review or edit the PRP before implementing, then optionally build and run. After that, use **`/execute-prp`** to implement.
7. **Execute the plan** Type **`/execute-prp PRPs/your-feature.md`**. The AI implements following the PRP (and its multi-agent task breakdown) and runs checks.
8. **Confirm it works** Type **`/validate-project`**. The AI runs the project’s checks and reports what passed or failed.
9. **Get a summary and next actions** Type **`/summarize`**. The AI summarizes **completed steps** and **next actions** so you can respond (e.g. ship, iterate, or run another command).
10. **Quick tasks (anytime)** For a small, one-off task, type **`/generate-prompt`** and describe the task. The AI creates a focused prompt for it.

---

## Summary

| Step | Command                | You do this                                                                                                    | The AI does this                                |
| ---- | ---------------------- | -------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| 1    | `/new-project`       | Create project (or open existing)                                                                              | Sets up folder, workflow files, and **all slash commands**—new project ready to use |
| 2    | —                     | Describe the feature in `INITIAL.md` or chat                                                                   | —                                               |
| 3    | `/generate-prd`      | Run for each product/feature                                                                                    | Writes a professional PRD in `PRDs/`           |
| 4    | `/generate-prp`      | Run after PRD                                                                                                   | Researches and writes execution plan (PRP) with **multi-agent task breakdown** |
| 5    | `/generate-validate` | Run **once or after significant change**                                                                       | Creates **`/validate-project`** for your project |
| 6    | `/build-prp`         | Run when you want to finalize the plan before implementing                                                     | Finalizes PRP, then optionally builds and runs  |
| 7    | `/execute-prp`       | Implement from PRP                                                                                             | Implements the plan and runs checks             |
| 8    | **`/validate-project`** | Run after building                                                                                             | Runs the full check suite and reports results   |
| 9    | **`/summarize`**     | Run after validate (or execute)                                                                                | **Completed steps + next actions** for your response |
| 10   | `/generate-prompt`   | Use anytime for small tasks                                                                                     | Creates a one-off prompt for the task           |

You stay in the driver’s seat: you describe *what* you want; the workflow gives you a **PRD**, a **plan with small tasks**, **validation**, and a **summary** so you know what’s done and what to do next.

For setup and technical details, see [README.md](README.md). For a hands-on walkthrough, see [Getting Started](tutorials/getting-started-walkthrough.md).
