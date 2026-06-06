from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.database import get_db
from app.models.user import User
from app.models.style import StyleProfile, StyleQuizResponse
from app.models.outfit import OutfitPreference
from app.schemas.style import (
    QuizSubmission, StyleProfileResponse, TinderSwipe, StyleEvolution,
    OutfitTinderItem
)
from app.dependencies import get_current_user
from app.services import style_service

router = APIRouter(prefix="/style", tags=["Style DNA"])

@router.post("/quiz", response_model=StyleProfileResponse)
async def submit_quiz(
    data: QuizSubmission,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    profile = await style_service.process_quiz(db, current_user.id, data)
    current_user.onboarding_complete = True
    await db.commit()
    return profile

@router.get("/profile", response_model=StyleProfileResponse)
async def get_style_profile(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(StyleProfile).where(StyleProfile.user_id == current_user.id)
    )
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Style profile not found. Complete the quiz first.")
    return profile

@router.get("/tinder/outfits", response_model=list[OutfitTinderItem])
async def get_tinder_outfits(
    current_user: User = Depends(get_current_user),
):
    """Return curated outfit cards for the Outfit Tinder feature."""
    return style_service.get_tinder_outfits()

@router.post("/tinder/swipe")
async def swipe_outfit(
    data: TinderSwipe,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    pref = OutfitPreference(
        user_id=current_user.id,
        outfit_data={"outfit_id": data.outfit_id, **data.outfit_data},
        preference=data.preference,
        source="tinder",
    )
    db.add(pref)

    # Update style scores dynamically
    await style_service.update_scores_from_swipe(db, current_user.id, data)
    await db.commit()
    return {"status": "recorded"}

@router.get("/evolution", response_model=StyleEvolution)
async def get_style_evolution(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await style_service.get_evolution(db, current_user.id)
