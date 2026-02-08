"""
Basic CRUD API — App factory.

Demonstrates minimal FastAPI setup with a single router.
"""

from fastapi import FastAPI

from .router import router as items_router


def create_app() -> FastAPI:
    """
    Create and configure the FastAPI application.

    Returns:
        FastAPI: Configured application instance.
    """
    app = FastAPI(
        title="Basic CRUD API",
        description="A minimal CRUD example using FastAPI",
        version="0.1.0",
    )

    app.include_router(items_router)

    @app.get("/health")
    async def health_check():
        """Health check endpoint."""
        return {"status": "ok"}

    return app


app = create_app()
