# Basic CRUD Example

A minimal FastAPI CRUD API demonstrating the standard router + model + schema pattern.

## What This Shows
- Router with GET, POST, PUT, DELETE endpoints
- SQLAlchemy model with auto-incrementing ID and timestamps
- Pydantic schemas for request validation and response serialization
- Database session dependency injection
- Proper HTTP status codes (200, 201, 404)

## Key Files
- `main.py` — App factory with router registration
- `models.py` — SQLAlchemy ORM model
- `schemas.py` — Pydantic request/response schemas
- `router.py` — CRUD endpoint implementations
