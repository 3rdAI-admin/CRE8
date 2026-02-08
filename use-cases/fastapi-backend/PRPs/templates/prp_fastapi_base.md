# PRP: [Feature Name] — FastAPI Backend

## Context
- **Project**: [Project name]
- **Feature**: [What this PRP implements]
- **Dependencies**: FastAPI, SQLAlchemy, Pydantic, [others]

## Requirements
1. [Requirement 1 — specific endpoint or behavior]
2. [Requirement 2]
3. [Requirement 3]

## Architecture
- **Routers**: [Which routers to create/modify]
- **Models**: [Which database models]
- **Schemas**: [Which request/response schemas]
- **Dependencies**: [Auth, DB, custom dependencies]

## Implementation Steps

### Step 1: Database Models
- Create SQLAlchemy models in `src/models/`
- Define relationships and indexes
- **Validate**: Models import without errors

### Step 2: Pydantic Schemas
- Create request schemas (Create, Update) in `src/schemas/`
- Create response schemas
- **Validate**: Schemas validate sample data correctly

### Step 3: Router Endpoints
- Create router in `src/routers/`
- Implement CRUD endpoints with proper status codes
- Add dependency injection (auth, DB session)
- Register router in `src/main.py`
- **Validate**: `uv run uvicorn src.main:app` starts without errors

### Step 4: Tests
- Write tests in `tests/unit/`
- Cover: expected use, edge cases, auth failures
- **Validate**: `uv run pytest tests/ -v` all pass

### Step 5: Final Validation
```bash
uv run ruff check src/ tests/
uv run ruff format --check src/ tests/
uv run mypy src/ --ignore-missing-imports
uv run pytest tests/ -v --tb=short
```

## Success Criteria
- [ ] All endpoints return correct status codes and response schemas
- [ ] Authentication enforced on protected routes
- [ ] All tests pass
- [ ] Linting and type checking clean
- [ ] API docs accessible at `/docs`

## Confidence: [1-10]
