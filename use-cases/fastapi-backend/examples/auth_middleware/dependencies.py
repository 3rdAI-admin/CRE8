"""
FastAPI authentication dependencies.

Use these with Depends() to protect routes.
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from .auth import verify_token

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    Validate JWT bearer token and return user payload.

    Usage:
        @router.get("/protected")
        async def protected_route(user = Depends(get_current_user)):
            return {"user": user["sub"]}

    Args:
        credentials: Bearer token from Authorization header.

    Returns:
        dict: Decoded token payload (contains 'sub', 'exp', etc.).

    Raises:
        HTTPException: 401 if token is missing, invalid, or expired.
    """
    payload = verify_token(credentials.credentials)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload
