from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models.user import User
from app.models.style import StyleProfile
from app.models.wardrobe import WardrobeItem
from app.models.shopping import ShoppingInsight
from app.dependencies import get_current_user
from app.services.recommendation_engine import detect_wardrobe_gaps

router = APIRouter(prefix="/shopping", tags=["Shopping Insights"])

@router.get("/insights")
async def get_shopping_insights(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Analyze wardrobe and return gap-based shopping recommendations."""
    profile_result = await db.execute(select(StyleProfile).where(StyleProfile.user_id == current_user.id))
    profile = profile_result.scalar_one_or_none()

    wardrobe_result = await db.execute(
        select(WardrobeItem).where(WardrobeItem.user_id == current_user.id, WardrobeItem.is_active == True)
    )
    wardrobe = wardrobe_result.scalars().all()

    if not profile:
        return []

    gaps = detect_wardrobe_gaps(wardrobe, profile)

    # Persist new insights (avoid duplicates)
    existing_result = await db.execute(
        select(ShoppingInsight).where(ShoppingInsight.user_id == current_user.id)
    )
    existing_cats = {i.gap_category for i in existing_result.scalars().all()}

    for gap in gaps:
        if gap["gap_category"] not in existing_cats:
            insight = ShoppingInsight(user_id=current_user.id, **gap)
            db.add(insight)

    await db.commit()
    return gaps
