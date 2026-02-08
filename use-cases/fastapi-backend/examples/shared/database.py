"""
Database session management with SQLAlchemy.

Provides engine creation and session dependency for FastAPI.
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .settings import settings


engine = create_engine(
    settings.database_url,
    # SQLite needs check_same_thread=False for FastAPI
    connect_args={"check_same_thread": False}
    if settings.database_url.startswith("sqlite")
    else {},
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    """Base class for all ORM models."""

    pass


def get_db():
    """
    FastAPI dependency that yields a database session.

    Automatically closes the session after the request completes.

    Yields:
        Session: SQLAlchemy database session.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
