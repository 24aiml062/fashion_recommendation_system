from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models.user import User
from app.models.style import StyleProfile
from app.models.wardrobe import WardrobeItem
from app.models.outfit import OutfitRecommendation, SavedOutfit
from app.schemas.outfit import (
    RecommendationRequest, OutfitRecommendationResponse, SavedOutfitCreate, SavedOutfitResponse
)
from app.schemas.wardrobe import WardrobeItemResponse
from app.dependencies import get_current_user
from app.services.weather_service import get_weather, get_weather_category
from app.services.recommendation_engine import build_outfit, build_explanation

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])

async def _get_profile_and_wardrobe(db, user_id):
    profile_result = await db.execute(select(StyleProfile).where(StyleProfile.user_id == user_id))
    profile = profile_result.scalar_one_or_none()
    wardrobe_result = await db.execute(
        select(WardrobeItem).where(WardrobeItem.user_id == user_id, WardrobeItem.is_active == True)
    )
    wardrobe = wardrobe_result.scalars().all()
    return profile, wardrobe


@router.post("/", response_model=OutfitRecommendationResponse)
async def get_recommendation(
    data: RecommendationRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    profile, wardrobe = await _get_profile_and_wardrobe(db, current_user.id)
    if not profile:
        raise HTTPException(status_code=400, detail="Complete the style quiz first")
    if not wardrobe:
        raise HTTPException(status_code=400, detail="Add items to your wardrobe first")

    weather = await get_weather(data.location or "London")
    weather_cat = get_weather_category(weather)

    outfit = build_outfit(wardrobe, data.occasion, weather_cat, profile)
    explanation = build_explanation(outfit, profile, weather, data.occasion)

    rec = OutfitRecommendation(
        user_id=current_user.id,
        top_id=outfit["top"].id if outfit["top"] else None,
        bottom_id=outfit["bottom"].id if outfit["bottom"] else None,
        footwear_id=outfit["footwear"].id if outfit["footwear"] else None,
        accessory_id=outfit["accessory"].id if outfit["accessory"] else None,
        outerwear_id=outfit["outerwear"].id if outfit["outerwear"] else None,
        confidence_score=outfit["confidence_score"],
        explanation=explanation,
        occasion=data.occasion,
        weather_data=weather,
    )
    db.add(rec)
    await db.commit()
    await db.refresh(rec)

    def to_schema(item):
        return WardrobeItemResponse.model_validate(item) if item else None

    return OutfitRecommendationResponse(
        id=rec.id,
        top=to_schema(outfit["top"]),
        bottom=to_schema(outfit["bottom"]),
        footwear=to_schema(outfit["footwear"]),
        accessory=to_schema(outfit["accessory"]),
        outerwear=to_schema(outfit["outerwear"]),
        confidence_score=rec.confidence_score,
        explanation=rec.explanation,
        occasion=rec.occasion,
        weather_data=rec.weather_data,
    )

@router.get("/saved", response_model=list[SavedOutfitResponse])
async def get_saved_outfits(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(SavedOutfit).where(SavedOutfit.user_id == current_user.id)
    )
    return result.scalars().all()

@router.post("/saved", response_model=SavedOutfitResponse, status_code=201)
async def save_outfit(
    data: SavedOutfitCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    saved = SavedOutfit(user_id=current_user.id, **data.model_dump())
    db.add(saved)
    await db.commit()
    await db.refresh(saved)
    return saved
