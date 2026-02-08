# FastAPI Backend - Context Engineering Rules

## Overview

This use-case template provides patterns and examples for building **production-grade FastAPI backends** using the context engineering workflow. It covers REST APIs, database integration, authentication, and testing.

## Project Awareness & Context

- **Always read `PLANNING.md`** at conversation start (if it exists)
- **Check `TASK.md`** before starting work
- **Use the virtual environment** for all Python commands: `uv run` or `source .venv/bin/activate`
- **Follow the PRP workflow**: `/generate-prd` → `/generate-prp` → `/execute-prp` → `/validate-project`

## Architecture Patterns

### Project Structure

```
my-fastapi-app/
├── src/
│   ├── __init__.py
│   ├── main.py              # FastAPI app factory, middleware, CORS
│   ├── config.py             # Settings with pydantic-settings
│   ├── database.py           # SQLAlchemy/SQLModel engine + session
│   ├── routers/              # Route handlers (one file per resource)
│   │   ├── __init__.py
│   │   ├── users.py
│   │   └── items.py
│   ├── models/               # SQLAlchemy/SQLModel ORM models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── item.py
│   ├── schemas/              # Pydantic request/response schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── item.py
│   └── dependencies/         # FastAPI dependency injection
│       ├── __init__.py
│       ├── auth.py           # Authentication dependencies
│       └── database.py       # DB session dependencies
├── tests/
│   ├── conftest.py           # Fixtures: TestClient, test DB
│   └── unit/
│       ├── test_users.py
│       └── test_items.py
├── pyproject.toml
├── .env.example
└── README.md
```

### Router Pattern

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from src.dependencies.database import get_db
from src.dependencies.auth import get_current_user
from src.schemas.item import ItemCreate, ItemResponse
from src.models.item import Item

router = APIRouter(prefix="/items", tags=["items"])

@router.get("/", response_model=list[ItemResponse])
async def list_items(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
):
    """List all items with pagination."""
    return db.query(Item).offset(skip).limit(limit).all()

@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(
    item: ItemCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    """Create a new item (authenticated)."""
    db_item = Item(**item.model_dump(), owner_id=current_user.id)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item
```

### Dependency Injection Pattern

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError

from src.config import settings

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    """Validate JWT and return current user."""
    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.secret_key,
            algorithms=[settings.jwt_algorithm],
        )
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )
```

### Testing Pattern

```python
import pytest
from fastapi.testclient import TestClient
from src.main import app

@pytest.fixture
def client():
    """Test client with overridden dependencies."""
    return TestClient(app)

def test_list_items(client):
    """Expected use: list returns 200."""
    response = client.get("/items/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_item_unauthenticated(client):
    """Failure case: create without auth returns 401/403."""
    response = client.post("/items/", json={"name": "test"})
    assert response.status_code in (401, 403)
```

## Code Standards

- **Max 500 lines per file** — split routers, models, schemas into separate files
- **Use `pydantic-settings`** for configuration (never hardcode secrets)
- **Use `python-dotenv`** with `.env` files for environment variables
- **Type hints on everything** — FastAPI uses them for validation and docs
- **Docstrings on every endpoint** — they become the auto-generated API docs
- **Tests in `/tests`** — at least: expected use, edge case, failure case per endpoint

## Anti-Patterns

- **Don't put business logic in routers** — extract to service functions or dependencies
- **Don't use `*` imports** — explicit imports only
- **Don't skip response models** — always define `response_model` for type safety and docs
- **Don't hardcode CORS origins** — use settings
- **Don't use synchronous DB calls in async endpoints** — use `async def` with async drivers, or `def` (sync) with sync drivers

## Development Commands

```bash
# Setup
uv venv && uv sync

# Run dev server
uv run uvicorn src.main:app --reload --port 8000

# Run tests
uv run pytest tests/ -v --tb=short

# Lint and format
uv run ruff check src/ tests/
uv run ruff format src/ tests/

# Type check
uv run mypy src/ --ignore-missing-imports
```
