from pydantic import BaseModel
from typing import Optional

class WardrobeItemCreate(BaseModel):
    name: str
    category: str
    primary_color: str
    style_tags: list[str] = []
    season_tags: list[str] = []
    occasion_tags: list[str] = []
    brand: str = ""
    notes: str = ""

class WardrobeItemUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    primary_color: Optional[str] = None
    style_tags: Optional[list[str]] = None
    season_tags: Optional[list[str]] = None
    occasion_tags: Optional[list[str]] = None
    brand: Optional[str] = None
    notes: Optional[str] = None

class WardrobeItemResponse(BaseModel):
    id: int
    user_id: int
    name: str
    category: str
    primary_color: str
    style_tags: list[str]
    season_tags: list[str]
    occasion_tags: list[str]
    brand: str
    notes: str

    class Config:
        from_attributes = True

class WardrobeFilter(BaseModel):
    category: Optional[str] = None
    primary_color: Optional[str] = None
    season: Optional[str] = None
    occasion: Optional[str] = None
    search: Optional[str] = None
