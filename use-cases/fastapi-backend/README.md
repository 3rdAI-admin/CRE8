# FastAPI Backend — Context Engineering Use Case

Build production-grade REST APIs with FastAPI using the context engineering PRP workflow.

## What You'll Learn

- How to use PRPs to plan and implement a FastAPI backend
- Router, dependency injection, and schema patterns
- Database integration with SQLAlchemy/SQLModel
- Authentication middleware
- Testing with pytest and TestClient

## Quick Start

### Prerequisites

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) (recommended) or pip

### Setup

```bash
# From the context-engineering template root
cd use-cases/fastapi-backend

# Install dependencies
uv venv && uv sync

# Copy .env.example to .env and fill in values
cp .env.example .env

# Run the dev server
uv run uvicorn src.main:app --reload --port 8000

# Open API docs
open http://localhost:8000/docs
```

### Using the PRP Workflow

```bash
# 1. Describe your feature
#    Edit PRPs/INITIAL.md with what you want to build

# 2. Generate a professional requirements doc
/generate-prd PRPs/INITIAL.md

# 3. Generate an execution plan
/generate-prp PRDs/my-api.md

# 4. Implement it
/execute-prp PRPs/my-api-feature.md

# 5. Validate
/validate-project

# 6. If validation fails, revise the plan
/revise-prp PRPs/my-api-feature.md
```

## Template Architecture

```
fastapi-backend/
├── CLAUDE.md                    # FastAPI-specific AI rules
├── README.md                    # This file
├── .env.example                 # Environment variable template
├── pyproject.toml               # Dependencies and tooling config
├── .claude/commands/            # FastAPI-specific slash commands
│   ├── generate-fastapi-prp.md  # PRP generation for FastAPI
│   └── execute-fastapi-prp.md   # PRP execution for FastAPI
├── examples/                    # Reference implementations
│   ├── basic_crud/              # Simple CRUD API pattern
│   ├── auth_middleware/         # JWT authentication pattern
│   └── shared/                  # Shared utilities (settings, DB)
├── PRPs/                        # Plans and templates
│   ├── INITIAL.md               # Feature request template
│   └── templates/
│       └── prp_fastapi_base.md  # FastAPI PRP template
├── src/                         # Source code
│   ├── main.py                  # App factory
│   ├── config.py                # Settings
│   ├── routers/                 # Route handlers
│   ├── models/                  # ORM models
│   ├── schemas/                 # Pydantic schemas
│   └── dependencies/            # DI (auth, DB sessions)
└── tests/                       # Test suite
    └── unit/
```

## Key Patterns

### Routers

One file per resource (`users.py`, `items.py`). Each router uses:
- `APIRouter` with prefix and tags
- Dependency injection for auth and DB sessions
- Pydantic `response_model` for type-safe responses
- HTTP status codes from `fastapi.status`

### Schemas vs Models

- **Schemas** (`src/schemas/`): Pydantic models for request/response validation
- **Models** (`src/models/`): SQLAlchemy/SQLModel ORM models for database

### Dependencies

- `get_db`: Yields a database session, auto-closes after request
- `get_current_user`: Validates JWT bearer token, returns user payload

### Testing

- Use `TestClient` for endpoint testing (no real server needed)
- Override dependencies in tests (e.g., use in-memory SQLite)
- Test happy path, edge cases, and auth failures

## Success Metrics

After using this template, your FastAPI project should have:
- Auto-generated OpenAPI docs at `/docs`
- All endpoints with type-validated request/response schemas
- Authentication on protected routes
- Database integration with migrations
- Test coverage for all endpoints
- Lint-clean code (ruff + mypy)
