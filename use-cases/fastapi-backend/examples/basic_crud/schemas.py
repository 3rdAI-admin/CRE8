"""
Pydantic schemas for request validation and response serialization.
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict


class ItemCreate(BaseModel):
    """Schema for creating a new item."""

    name: str
    description: str | None = None


class ItemUpdate(BaseModel):
    """Schema for updating an existing item (all fields optional)."""

    name: str | None = None
    description: str | None = None


class ItemResponse(BaseModel):
    """Schema for item responses (includes DB-generated fields)."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: str | None
    created_at: datetime
    updated_at: datetime
