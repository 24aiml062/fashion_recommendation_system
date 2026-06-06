from pydantic import BaseModel
from typing import Optional, Any
from app.schemas.wardrobe import WardrobeItemResponse

class RecommendationRequest(BaseModel):
    occasion: str = "casual"
    location: Optional[str] = None  # for weather lookup

class ExplanationData(BaseModel):
    reasons: list[str]
    summary: str
    style_match: float
    weather_match: float
    occasion_match: float

class OutfitRecommendationResponse(BaseModel):
    id: int
    top: Optional[WardrobeItemResponse]
    bottom: Optional[WardrobeItemResponse]
    footwear: Optional[WardrobeItemResponse]
    accessory: Optional[WardrobeItemResponse]
    outerwear: Optional[WardrobeItemResponse]
    confidence_score: float
    explanation: dict[str, Any]
    occasion: str
    weather_data: dict[str, Any]

    class Config:
        from_attributes = True

class SavedOutfitCreate(BaseModel):
    name: str = ""
    outfit_data: dict[str, Any]
    occasion: str = ""
    notes: str = ""

class SavedOutfitResponse(BaseModel):
    id: int
    name: str
    outfit_data: dict[str, Any]
    occasion: str
    notes: str

    class Config:
        from_attributes = True
