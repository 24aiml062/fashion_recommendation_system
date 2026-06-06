from pydantic import BaseModel
from typing import Any

class QuizSubmission(BaseModel):
    # Visual style ratings: outfit_id -> rating (1=wear, 0=maybe, -1=not_my_style)
    outfit_ratings: dict[str, int] = {}

    # Lifestyle
    lifestyle: str = "student"
    social_frequency: str = "occasionally"
    daily_environment: str = "campus"
    fashion_importance: int = 3

    # Budget
    budget_range: str = "medium"

    # Colors
    favorite_colors: list[str] = []
    avoided_colors: list[str] = []

    # Fit
    fit_preference: str = "regular"

    # Goals
    fashion_goals: list[str] = []


class StyleProfileResponse(BaseModel):
    id: int
    user_id: int
    minimalist_score: float
    old_money_score: float
    smart_casual_score: float
    streetwear_score: float
    formal_score: float
    athleisure_score: float
    vintage_score: float
    lifestyle: str
    social_frequency: str
    daily_environment: str
    fashion_importance: int
    budget_range: str
    favorite_colors: list[str]
    avoided_colors: list[str]
    fit_preference: str
    fashion_goals: list[str]
    dominant_style: str

    class Config:
        from_attributes = True


class OutfitTinderItem(BaseModel):
    id: str
    style: str
    description: str
    colors: list[str]
    occasion: str
    season: list[str]
    image_placeholder: str  # emoji or color code for MVP


class TinderSwipe(BaseModel):
    outfit_id: str
    preference: str  # like, dislike, save
    outfit_data: dict[str, Any]


class StyleEvolution(BaseModel):
    style_changes: dict[str, float]
    top_colors: list[str]
    top_categories: list[str]
    monthly_insights: list[str]
