from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.style import StyleProfile, StyleQuizResponse
from app.models.outfit import OutfitPreference
from app.schemas.style import QuizSubmission, TinderSwipe, OutfitTinderItem, StyleEvolution

# Curated outfit cards for Tinder feature
TINDER_OUTFITS = [
    OutfitTinderItem(id="t1", style="minimalist", description="White tee, tailored trousers, white sneakers",
                     colors=["white","black"], occasion="casual", season=["spring","summer"], image_placeholder="🤍"),
    OutfitTinderItem(id="t2", style="old_money", description="Polo shirt, chinos, loafers",
                     colors=["navy","beige"], occasion="smart_casual", season=["spring","fall"], image_placeholder="🎿"),
    OutfitTinderItem(id="t3", style="streetwear", description="Graphic hoodie, cargo pants, chunky sneakers",
                     colors=["black","grey"], occasion="casual", season=["fall","winter"], image_placeholder="🖤"),
    OutfitTinderItem(id="t4", style="formal", description="Slim suit, dress shirt, Oxford shoes",
                     colors=["charcoal","white"], occasion="formal", season=["all"], image_placeholder="🎩"),
    OutfitTinderItem(id="t5", style="athleisure", description="Track jacket, joggers, clean sneakers",
                     colors=["white","navy"], occasion="casual", season=["spring","summer"], image_placeholder="🏃"),
    OutfitTinderItem(id="t6", style="vintage", description="Denim jacket, mom jeans, retro sneakers",
                     colors=["blue","cream"], occasion="casual", season=["spring","fall"], image_placeholder="🌻"),
    OutfitTinderItem(id="t7", style="smart_casual", description="Oxford shirt, dark jeans, Chelsea boots",
                     colors=["blue","brown"], occasion="work", season=["fall","winter"], image_placeholder="👔"),
    OutfitTinderItem(id="t8", style="old_money", description="Cashmere sweater, pressed trousers, monk straps",
                     colors=["camel","navy"], occasion="smart_casual", season=["fall","winter"], image_placeholder="🧥"),
]

STYLE_OUTFIT_MAP = {
    "t1": "minimalist", "t2": "old_money", "t3": "streetwear",
    "t4": "formal", "t5": "athleisure", "t6": "vintage",
    "t7": "smart_casual", "t8": "old_money",
}

def get_tinder_outfits() -> list[OutfitTinderItem]:
    return TINDER_OUTFITS


async def process_quiz(db: AsyncSession, user_id: int, data: QuizSubmission) -> StyleProfile:
    # Compute style scores from outfit ratings
    style_votes: dict[str, list[int]] = {s: [] for s in [
        "minimalist","old_money","smart_casual","streetwear","formal","athleisure","vintage"
    ]}

    for outfit_id, rating in data.outfit_ratings.items():
        style = STYLE_OUTFIT_MAP.get(outfit_id)
        if style and style in style_votes:
            style_votes[style].append(rating)

    def avg_score(votes: list[int]) -> float:
        if not votes:
            return 0.0
        # normalize from [-1,1] to [0,1]
        return round((sum(votes) / len(votes) + 1) / 2, 2)

    scores = {k: avg_score(v) for k, v in style_votes.items()}
    dominant = max(scores, key=lambda k: scores[k])

    # Check existing profile
    result = await db.execute(select(StyleProfile).where(StyleProfile.user_id == user_id))
    profile = result.scalar_one_or_none()

    if not profile:
        profile = StyleProfile(user_id=user_id)
        db.add(profile)

    profile.minimalist_score = scores["minimalist"]
    profile.old_money_score = scores["old_money"]
    profile.smart_casual_score = scores["smart_casual"]
    profile.streetwear_score = scores["streetwear"]
    profile.formal_score = scores["formal"]
    profile.athleisure_score = scores["athleisure"]
    profile.vintage_score = scores["vintage"]
    profile.dominant_style = dominant

    profile.lifestyle = data.lifestyle
    profile.social_frequency = data.social_frequency
    profile.daily_environment = data.daily_environment
    profile.fashion_importance = data.fashion_importance
    profile.budget_range = data.budget_range
    profile.favorite_colors = data.favorite_colors
    profile.avoided_colors = data.avoided_colors
    profile.fit_preference = data.fit_preference
    profile.fashion_goals = data.fashion_goals

    await db.commit()
    await db.refresh(profile)
    return profile


async def update_scores_from_swipe(db: AsyncSession, user_id: int, swipe: TinderSwipe):
    """Nudge style scores based on tinder swipe."""
    style = STYLE_OUTFIT_MAP.get(swipe.outfit_id)
    if not style:
        return

    result = await db.execute(select(StyleProfile).where(StyleProfile.user_id == user_id))
    profile = result.scalar_one_or_none()
    if not profile:
        return

    delta = 0.05 if swipe.preference == "like" else -0.03 if swipe.preference == "dislike" else 0.02
    field = f"{style}_score"
    current = getattr(profile, field, 0.0)
    setattr(profile, field, round(max(0.0, min(1.0, current + delta)), 3))

    # Recompute dominant
    style_fields = ["minimalist","old_money","smart_casual","streetwear","formal","athleisure","vintage"]
    scores = {s: getattr(profile, f"{s}_score", 0.0) for s in style_fields}
    profile.dominant_style = max(scores, key=lambda k: scores[k])


async def get_evolution(db: AsyncSession, user_id: int) -> StyleEvolution:
    result = await db.execute(select(StyleProfile).where(StyleProfile.user_id == user_id))
    profile = result.scalar_one_or_none()

    prefs_result = await db.execute(
        select(OutfitPreference).where(OutfitPreference.user_id == user_id)
    )
    prefs = prefs_result.scalars().all()

    if not profile:
        return StyleEvolution(style_changes={}, top_colors=[], top_categories=[], monthly_insights=[])

    style_scores = {
        "Minimalist": profile.minimalist_score,
        "Old Money": profile.old_money_score,
        "Smart Casual": profile.smart_casual_score,
        "Streetwear": profile.streetwear_score,
        "Formal": profile.formal_score,
        "Athleisure": profile.athleisure_score,
        "Vintage": profile.vintage_score,
    }

    # Count liked outfit styles
    liked = [p for p in prefs if p.preference == "like"]
    insights = []
    if liked:
        insights.append(f"You've liked {len(liked)} outfits — your taste is developing nicely.")
    if profile.dominant_style:
        insights.append(f"Your dominant style is {profile.dominant_style.replace('_',' ').title()}.")
    if profile.favorite_colors:
        insights.append(f"You gravitate toward {', '.join(profile.favorite_colors[:2])} tones.")

    return StyleEvolution(
        style_changes=style_scores,
        top_colors=profile.favorite_colors or [],
        top_categories=[profile.dominant_style] if profile.dominant_style else [],
        monthly_insights=insights,
    )
