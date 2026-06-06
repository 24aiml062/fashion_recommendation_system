"""
Rule-based outfit recommendation engine.
Scores wardrobe items and builds complete outfit combinations.
"""
from typing import Optional
from app.models.wardrobe import WardrobeItem
from app.models.style import StyleProfile

# Season suitability by weather category
WEATHER_SEASON_MAP = {
    "hot":   ["summer", "spring"],
    "warm":  ["spring", "summer", "fall"],
    "cool":  ["fall", "spring"],
    "cold":  ["winter", "fall"],
    "rainy": ["fall", "winter", "spring"],
}

# Occasion season allowance
OCCASION_FORMALITY = {
    "casual":        0,
    "college":       0,
    "date":          1,
    "work":          2,
    "smart_casual":  2,
    "formal":        3,
    "interview":     3,
    "wedding":       4,
    "party":         2,
    "vacation":      0,
}

# Complementary color pairs for color harmony scoring
COLOR_PAIRS = [
    {"white", "black"}, {"white", "navy"}, {"white", "beige"},
    {"black", "grey"}, {"navy", "beige"}, {"navy", "white"},
    {"beige", "brown"}, {"grey", "black"}, {"olive", "beige"},
    {"cream", "brown"}, {"blue", "white"}, {"burgundy", "beige"},
]

def _color_harmony(c1: str, c2: str) -> float:
    c1, c2 = c1.lower(), c2.lower()
    if c1 == c2:
        return 0.5  # monochrome is ok
    pair = {c1, c2}
    return 1.0 if pair in COLOR_PAIRS else 0.3

def _score_item(
    item: WardrobeItem,
    occasion: str,
    weather_category: str,
    profile: StyleProfile,
) -> float:
    score = 0.0

    # 1. Occasion match (0-0.4)
    item_occasions = [o.lower() for o in (item.occasion_tags or [])]
    occ_lower = occasion.lower()
    if occ_lower in item_occasions:
        score += 0.4
    elif any(occ_lower in o or o in occ_lower for o in item_occasions):
        score += 0.2

    # 2. Season / weather match (0-0.3)
    allowed_seasons = WEATHER_SEASON_MAP.get(weather_category, [])
    item_seasons = [s.lower() for s in (item.season_tags or [])]
    if any(s in item_seasons for s in allowed_seasons):
        score += 0.3
    elif not item_seasons:
        score += 0.15  # untagged = neutral

    # 3. Style DNA match (0-0.3)
    style_scores = {
        "minimalist":   profile.minimalist_score,
        "old_money":    profile.old_money_score,
        "smart_casual": profile.smart_casual_score,
        "streetwear":   profile.streetwear_score,
        "formal":       profile.formal_score,
        "athleisure":   profile.athleisure_score,
        "vintage":      profile.vintage_score,
    }
    item_styles = [s.lower().replace(" ", "_") for s in (item.style_tags or [])]
    style_bonus = sum(style_scores.get(s, 0) for s in item_styles)
    score += min(style_bonus * 0.3, 0.3)

    return round(score, 3)


def build_outfit(
    wardrobe: list[WardrobeItem],
    occasion: str,
    weather_category: str,
    profile: StyleProfile,
    liked_colors: list[str] | None = None,
) -> dict:
    """
    Select best top, bottom, footwear, accessory, outerwear from wardrobe.
    Returns outfit dict with item ids and confidence score.
    """
    by_category: dict[str, list] = {
        "tops": [], "bottoms": [], "footwear": [],
        "accessories": [], "outerwear": []
    }
    for item in wardrobe:
        cat = item.category.lower()
        if cat in by_category:
            item_score = _score_item(item, occasion, weather_category, profile)
            by_category[cat].append((item, item_score))

    def best(cat: str) -> Optional[WardrobeItem]:
        items = sorted(by_category[cat], key=lambda x: x[1], reverse=True)
        return items[0][0] if items else None

    top = best("tops")
    bottom = best("bottoms")
    footwear = best("footwear")
    accessory = best("accessories")
    outerwear = best("outerwear") if weather_category in ("cold", "cool", "rainy") else None

    # Confidence: average of top scores
    scores = [
        _score_item(i, occasion, weather_category, profile)
        for i in [top, bottom, footwear] if i
    ]
    confidence = round(sum(scores) / len(scores), 2) if scores else 0.0

    return {
        "top": top,
        "bottom": bottom,
        "footwear": footwear,
        "accessory": accessory,
        "outerwear": outerwear,
        "confidence_score": confidence,
    }


def build_explanation(
    outfit: dict,
    profile: StyleProfile,
    weather: dict,
    occasion: str,
) -> dict:
    """Generate human-readable explanation for the outfit recommendation."""
    reasons = []
    top: Optional[WardrobeItem] = outfit.get("top")
    bottom: Optional[WardrobeItem] = outfit.get("bottom")

    # Style DNA reason
    dominant = profile.dominant_style or "your personal style"
    reasons.append(f"Your Style DNA is strongly {dominant.replace('_', ' ').title()}.")

    # Color preferences
    if profile.favorite_colors:
        fav = ", ".join(profile.favorite_colors[:3])
        reasons.append(f"You prefer {fav} tones — this outfit aligns with that.")

    # Weather reason
    temp = weather.get("temperature", 22)
    condition = weather.get("condition", "Clear")
    reasons.append(f"Today it's {temp:.0f}°C and {condition.lower()} — the outfit is weather-appropriate.")

    # Occasion reason
    reasons.append(f"This combination suits a {occasion} setting.")

    # Color harmony
    if top and bottom:
        harmony = _color_harmony(top.primary_color, bottom.primary_color)
        if harmony >= 0.8:
            reasons.append(
                f"{top.primary_color.title()} and {bottom.primary_color.title()} "
                "are a strong color combination."
            )

    summary = (
        f"You frequently prefer {profile.favorite_colors[0] if profile.favorite_colors else 'neutral'} colors. "
        f"Your Style DNA is {dominant.replace('_', ' ').title()}. "
        f"Today is {condition.lower()} at {temp:.0f}°C, making this outfit ideal for {occasion}."
    )

    return {"reasons": reasons, "summary": summary}


def detect_wardrobe_gaps(
    wardrobe: list[WardrobeItem],
    profile: StyleProfile,
) -> list[dict]:
    """Identify missing wardrobe items and generate shopping insights."""
    gaps = []
    categories = {i.category.lower() for i in wardrobe}
    occasions = set()
    for item in wardrobe:
        occasions.update(o.lower() for o in (item.occasion_tags or []))

    if "footwear" not in categories:
        gaps.append({
            "gap_category": "footwear",
            "gap_description": "No footwear found in wardrobe",
            "recommendation": "White Sneakers or Clean Leather Shoes",
            "reason": "Footwear is essential for completing any outfit.",
            "priority": "high",
        })

    if "formal" not in occasions and profile.formal_score > 0.4:
        gaps.append({
            "gap_category": "formal",
            "gap_description": "No formal wear detected",
            "recommendation": "Navy Blazer",
            "reason": "Your style profile has strong formal preferences but no formal items.",
            "priority": "high",
        })

    if "outerwear" not in categories:
        gaps.append({
            "gap_category": "outerwear",
            "gap_description": "No outerwear in wardrobe",
            "recommendation": "Classic Trench Coat or Denim Jacket",
            "reason": "Outerwear adds versatility across seasons.",
            "priority": "medium",
        })

    if "accessories" not in categories:
        gaps.append({
            "gap_category": "accessories",
            "gap_description": "No accessories in wardrobe",
            "recommendation": "Minimalist Watch or Simple Belt",
            "reason": "Accessories elevate any look with minimal effort.",
            "priority": "low",
        })

    return gaps
