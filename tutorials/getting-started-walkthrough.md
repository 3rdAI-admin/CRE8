# User Tutorial: Getting Started with Context Engineering

> **Time:** 30–45 minutes  
> **Difficulty:** Beginner–Intermediate  
> **What you’ll build:** A "Daily Quote" web app with categories, favorites, and background images

This tutorial walks you through the **full context-engineering process**: the AI asks where to create your project and what to name it, you describe the feature, then you run the commands in order (PRD → PRP → validation → execute → validate → summarize). By the end, you’ll have a working quote app and a clear picture of the workflow.

---

## What Are These Commands?

Think of them as **ordered steps** so the AI has the right context at each stage:

| Order | Command | What it does | When to run |
|-------|---------|--------------|-------------|
| 1 | `/new-project` | Creates a new project folder (after you give location & name) | When starting a new project |
| 2 | — | You describe the feature in `INITIAL.md` or chat | Before planning |
| 3 | `/generate-prd` | Turns your idea into a **professional Product Requirements Document** in `PRDs/` | For each product/feature |
| 4 | `/generate-prp` | Turns the PRD (or INITIAL.md) into an **execution plan with small tasks** in `PRPs/` | After PRD |
| 5 | `/generate-validate` | Creates **`/validate-project`** for your project (from example-validate) | **Once, or after a big change** (after planning, before building) |
| 6 | `/build-prp` | Review/finalize the PRP (edit if needed), then optionally build and run | When you want to finalize before implementing |
| 7 | `/execute-prp` | Implements the feature from the PRP and runs checks | After you have a PRP (and optionally after `/build-prp`) |
| 8 | **`/validate-project`** | Runs your project’s checks (from `/generate-validate`) | After building; use this, not `/validate` |
| 9 | **`/summarize`** | Summarizes **completed steps** and **next actions** for you | After validate (or execute) |
| 10 | `/generate-prompt` | Creates a one-off, well-structured prompt for a small task | Anytime |

**Core idea:** A **PRD** gives you a stakeholder-ready requirements doc; the **PRP** breaks work into small tasks for accuracy; **validate** checks it works; **summarize** keeps you in the loop with clear next actions.

---

## The Workflow (all commands in order)

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  1. CREATE       │    │  2. DESCRIBE     │    │  3. PLAN          │
│  /new-project    │───▶│  INITIAL.md      │───▶│  /generate-prd   │
│  (location &     │    │  (your idea)     │    │  /generate-prp   │
│   name first)    │    │                  │    │  /generate-       │
└──────────────────┘    └──────────────────┘    │  validate (once) │
                                                └────────┬─────────┘
                                                         │
┌──────────────────┐    ┌──────────────────┐    ┌───────┴─────────┐
│  8. VALIDATE     │◀───│  7. EXECUTE      │◀───│  6. BUILD (opt) │
│  /validate-      │    │  /execute-prp    │    │  /build-prp      │
│  project         │    │  (implements)    │    │  (finalize plan) │
└────────┬─────────┘    └──────────────────┘    └──────────────────┘
         │
┌────────┴─────────┐
│  9. SUMMARIZE    │  → Completed steps + next actions for you
│  /summarize      │
└──────────────────┘
```

**Order in one line:** Ask location & name → Create project **outside** this template → Define in `INITIAL.md` → `/generate-prd` → `/generate-prp` → `/generate-validate` (once) → `/build-prp` (optional) → `/execute-prp` → `/validate-project` → `/summarize`.

---

## Prerequisites

1. **Python 3.8+** — [Download Python](https://www.python.org/downloads/)
2. **An IDE** with these commands (VS Code with Copilot, Claude Code, or Cursor)
3. **Context Engineering template** — Clone and set up (see [README](../README.md))
4. **Unsplash API key (optional)** — Free at [unsplash.com/developers](https://unsplash.com/developers). Without it, the app uses Picsum Photos for backgrounds.

---

## Step 0: Choose Location and Name (Ask First)

**Important:** The Daily Quote app must be created **outside** the context-engineering template folder—in a location and with a name **you** choose.

**Before creating anything, the AI should ask you:**

1. **Where** do you want the new project? (e.g. `~/projects`, `~/code`, `~/Desktop`)
2. **What** do you want to name it? (e.g. `daily-quote-app`, `my-quote-app`)

Only after you answer should the AI run `/new-project` with the full path (e.g. `~/projects/daily-quote-app`). **Never** create the project inside the context-engineering repo.

---

## Step 0b: Create Your Project

After you’ve given **location** and **name**, the project is created at that path.

### Option A: Use `/new-project` (recommended)

In AI chat (from the context-engineering folder), provide the path:

```
/new-project ~/projects/daily-quote-app
```

(Use the location and name you gave. Example: if you said `~/projects` and `daily-quote-app`, the path is `~/projects/daily-quote-app`.)

This will:

- Create the project folder
- Copy AI config (`.claude/`, `.github/`, `.vscode/`, `.cursor/`)
- Set up `PRPs/`, `examples/`, and a blank `INITIAL.md`
- Initialize git

### Option B: Shell script

From the context-engineering folder:

```bash
./create-project.sh ~/projects/daily-quote-app
```

### Open your new project

```bash
# VS Code
code ~/projects/daily-quote-app

# Cursor
cursor ~/projects/daily-quote-app

# Claude Code
cd ~/projects/daily-quote-app && claude
```

**You should now be working in the new project folder, not in context-engineering.**

**Next:** Step 1 (Unsplash key, optional), then Step 2 (fill out `INITIAL.md`), then `/generate-prd` → `/generate-prp` → etc.

---

## Step 1: Get an Unsplash API Key (Optional)

For custom background images from Unsplash:

1. Go to [unsplash.com/developers](https://unsplash.com/developers)
2. Register / sign in, create a new application, accept terms
3. Copy your **Access Key**

**Without a key:** The app still works and uses [Picsum Photos](https://picsum.photos/) for backgrounds.

---

## Step 2: Define Your Requirements (INITIAL.md)

In your **new project folder**, open `INITIAL.md` and describe what you want to build.

**Full example:** A complete `INITIAL.md` for the Daily Quote app is in [examples/daily-quote-app/INITIAL.md](../examples/daily-quote-app/INITIAL.md). Copy it into your project's `INITIAL.md`, or adapt it.

**Summary of what to include:**

- **FEATURE:** What the app does (e.g. Flask Daily Quote app with Unsplash backgrounds, categories, favorites, “New Quote” button)
- **Core user flows:** Open app → random quote; click category → filtered quotes; click heart → save; click Favorites → list; New Quote → new quote
- **EXAMPLES / DOCUMENTATION:** Links to Flask, Unsplash API, localStorage, etc.
- **OTHER CONSIDERATIONS:** Project structure, quote categories (e.g. Motivation, Success, Wisdom, Life—and optionally A.I.), UI/UX, technical notes (e.g. `/api/quote`, fallback image, localStorage)

The more specific you are, the better the AI can plan and implement.

---

## Step 3a: Generate a PRD (/generate-prd)

Turn your idea into a **professional Product Requirements Document** for review and planning.

In AI chat (in your **new project**):

```
/generate-prd INITIAL.md
```

This creates a PRD in `PRDs/` (goals, scope, success criteria, requirements). You can then use it as input to the next step.

---

## Step 3b: Generate the Execution Plan (/generate-prp)

Create an **execution plan with small, assignable tasks** from your PRD or from `INITIAL.md`.

```
/generate-prp INITIAL.md
```

(or point at your PRD file)

**What happens:**

1. The AI reads your requirements
2. It researches Flask, Unsplash (or Picsum), and patterns
3. It writes a plan in `PRPs/` (e.g. `PRPs/daily-quote-app.md`)

The PRP includes: goal, success criteria, file list, implementation steps, and validation. **Review it;** if something’s wrong, ask the AI to adjust before executing.

---

## Step 3c: Set Up Validation (Once) (/generate-validate)

Run this **once** (or after a significant project change) so **`/validate-project`** is tailored to your project.

```
/generate-validate
```

The AI creates **`/validate-project`** from the example-validate template. After building, use **`/validate-project`** (not `/validate`) to avoid injected commands.

---

## Step 4: Finalize the Plan (Optional) (/build-prp)

If you want to **review or edit the PRP** before implementation:

```
/build-prp PRPs/daily-quote-app.md
```

You can finalize the plan and optionally build and run. If you’re happy with the PRP as-is, skip to Step 5.

---

## Step 5: Execute the Plan (/execute-prp)

Implement the feature from the PRP.

```
/execute-prp PRPs/daily-quote-app.md
```

**What happens:**

1. The AI reads the PRP step by step
2. It creates the files (e.g. `app.py`, `quotes.py`, `templates/`, `static/`, `requirements.txt`, `.env.example`)
3. It writes the code and runs checks
4. It fixes issues as needed

When it’s done, you’ll have a runnable Daily Quote app.

---

## Step 6: Configure Your Environment

Before running the app:

**1. Create `.env` (if you use Unsplash):**

```bash
cp .env.example .env
```

Edit `.env` and add:

```
UNSPLASH_ACCESS_KEY=your_key_here
```

(If you skip this, the app uses Picsum for backgrounds.)

**2. Install dependencies:**

```bash
pip install -r requirements.txt
```

Or with a virtual environment:

```bash
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

---

## Step 7: Validate Everything (/validate-project)

Run the project’s checks (from `/generate-validate`):

```
/validate-project
```

The AI runs structure, lint, and test checks and reports pass/fail. Fix any reported issues.

---

## Step 8: Run Your App

Start the Flask app:

```bash
python app.py
```

Check the terminal for the URL (e.g. `http://127.0.0.1:5001` or `5002`). **On macOS,** port 5000 is often used by AirPlay, so the app may use 5001 or 5002.

**Open that URL in your browser.** You should see:

- Full-screen background image (Unsplash or Picsum)
- A quote and author
- Category buttons (All, Motivation, Success, Wisdom, Life, and optionally A.I.)
- Heart to save favorites, “New Quote” button, “Favorites” view

**Try:** New Quote, category filter, heart to save, Favorites list.

---

## Step 9: Summarize (/summarize)

Get a short summary of what’s done and what to do next:

```
/summarize
```

The AI returns **completed steps** and **next actions** (e.g. ship, iterate, or run another command). Use this to stay in the loop after validate or execute.

---

## What You Learned

| Step | What you did |
|------|----------------|
| 0 | Chose location and name; AI created project **outside** the template |
| 1 | (Optional) Got Unsplash API key |
| 2 | Filled out `INITIAL.md` with requirements |
| 3a | Generated a PRD with `/generate-prd` |
| 3b | Generated an execution plan (PRP) with `/generate-prp` |
| 3c | Set up validation once with `/generate-validate` |
| 4 | (Optional) Finalized the plan with `/build-prp` |
| 5 | Built the app with `/execute-prp` |
| 6 | Configured environment (`.env`, dependencies) |
| 7 | Ran checks with `/validate-project` |
| 8 | Ran and tested the app |
| 9 | Got next actions with `/summarize` |

**Technologies:** Python Flask, Unsplash API (or Picsum), JavaScript, localStorage, CSS.

---

## Tips for Better Results

- **Be specific in INITIAL.md** — Include user flows, project structure, and technical notes.
- **Review the PRP** — Use `/build-prp` to edit before `/execute-prp`.
- **Use `/validate-project`** — Not `/validate`; use the project-specific checks from `/generate-validate`.
- **Use `/summarize`** — After validate or execute to see completed steps and next actions.

---

## Quick Tasks: /generate-prompt

For small, one-off tasks (not a full feature):

```
/generate-prompt Add a "share quote" button that copies to clipboard
```

The AI may ask a few questions, then produce a focused prompt.

---

## Next Steps

- **Add more quotes or categories** — Edit `quotes.py` (e.g. A.I. category with label “A.I.” in the UI).
- **Change styling** — Edit `static/style.css`.
- **Deploy** — Use Heroku, Railway, or another host.

For each new feature, repeat: update `INITIAL.md` (or PRD) → `/generate-prp` → `/generate-validate` if needed → `/build-prp` (optional) → `/execute-prp` → `/validate-project` → `/summarize`.

---

## More Resources

- [OVERVIEW](../OVERVIEW.md) — One-page workflow summary
- [README](../README.md) — Full template and setup
- [Tutorials README](README.md) — Tutorial index and command order
- [PRPs/templates/](../PRPs/templates/) — PRD and PRP templates

Happy building.
