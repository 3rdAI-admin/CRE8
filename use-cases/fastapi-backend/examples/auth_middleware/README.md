# Authentication Middleware Example

JWT-based authentication using FastAPI dependency injection.

## What This Shows
- JWT token creation and validation
- FastAPI `Depends()` for route-level auth
- Password hashing with bcrypt
- Protected vs public endpoints
- Proper 401/403 error responses

## Key Files
- `auth.py` — JWT creation, validation, password hashing
- `dependencies.py` — `get_current_user` dependency for protected routes
