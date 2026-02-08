"""
CRUD router for items.

Demonstrates standard REST endpoint patterns with FastAPI.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..shared.database import get_db
from .models import Item
from .schemas import ItemCreate, ItemResponse, ItemUpdate

router = APIRouter(prefix="/items", tags=["items"])


@router.get("/", response_model=list[ItemResponse])
async def list_items(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
):
    """
    List all items with pagination.

    Args:
        skip: Number of items to skip (offset).
        limit: Maximum number of items to return.
        db: Database session (injected).

    Returns:
        list[ItemResponse]: List of items.
    """
    return db.query(Item).offset(skip).limit(limit).all()


@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int, db: Session = Depends(get_db)):
    """
    Get a single item by ID.

    Args:
        item_id: The item's database ID.
        db: Database session (injected).

    Returns:
        ItemResponse: The requested item.

    Raises:
        HTTPException: 404 if item not found.
    """
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found",
        )
    return item


@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    """
    Create a new item.

    Args:
        item: Item data from request body.
        db: Database session (injected).

    Returns:
        ItemResponse: The created item with generated ID and timestamps.
    """
    db_item = Item(**item.model_dump())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item


@router.put("/{item_id}", response_model=ItemResponse)
async def update_item(item_id: int, item: ItemUpdate, db: Session = Depends(get_db)):
    """
    Update an existing item (partial update).

    Args:
        item_id: The item's database ID.
        item: Fields to update.
        db: Database session (injected).

    Returns:
        ItemResponse: The updated item.

    Raises:
        HTTPException: 404 if item not found.
    """
    db_item = db.query(Item).filter(Item.id == item_id).first()
    if not db_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found",
        )
    for field, value in item.model_dump(exclude_unset=True).items():
        setattr(db_item, field, value)
    db.commit()
    db.refresh(db_item)
    return db_item


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(item_id: int, db: Session = Depends(get_db)):
    """
    Delete an item.

    Args:
        item_id: The item's database ID.
        db: Database session (injected).

    Raises:
        HTTPException: 404 if item not found.
    """
    db_item = db.query(Item).filter(Item.id == item_id).first()
    if not db_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item {item_id} not found",
        )
    db.delete(db_item)
    db.commit()
