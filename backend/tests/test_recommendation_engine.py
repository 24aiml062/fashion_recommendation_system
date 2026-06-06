"""Unit tests for the rule-based recommendation engine."""
import pytest
from unittest.mock import MagicMock
from app.services.recommendation_engine import (
    build_outfit, build_explanation, detect_wardrobe_gaps, _color_harmony, _score_item
)

def make_item(id, category, color, style_tags=None, season_tags=None, occasion_tags=None):
    item = MagicMock()
    item.id = id
    item.category = category
    item.primary_color = color
    item.style_tags = style_tags or []
    item.season_tags = season_tags or []
    item.occasion_tags = occasion_tags or []
    return item

def make_profile(**kwargs):
    profile = MagicMock()
    defaults = dict(
        minimalist_score=0.8, old_money_score=0.3, smart_casual_score=0.5,
        streetwear_score=0.1, formal_score=0.2, athleisure_score=0.1, vintage_score=0.1,
        favorite_colors=["white", "navy"], avoided_colors=[],
        fit_preference="regular", dominant_style="minimalist",
    )
    defaults.update(kwargs)
    for k, v in defaults.items():
        setattr(profile, k, v)
    return profile


def test_color_harmony_known_pair():
    assert _color_harmony("white", "navy") == 1.0

def test_color_harmony_same_color():
    assert _color_harmony("black", "black") == 0.5

def test_color_harmony_random_pair():
    assert _color_harmony("pink", "yellow") == 0.3

def test_score_item_occasion_match():
    item = make_item(1, "tops", "white", occasion_tags=["casual"])
    profile = make_profile()
    score = _score_item(item, "casual", "warm", profile)
    assert score >= 0.4

def test_score_item_weather_match():
    item = make_item(1, "tops", "white", season_tags=["summer"])
    profile = make_profile()
    score = _score_item(item, "casual", "hot", profile)
    assert score >= 0.3

def test_build_outfit_selects_categories():
    items = [
        make_item(1, "tops", "white", occasion_tags=["casual"], season_tags=["summer"]),
        make_item(2, "bottoms", "navy", occasion_tags=["casual"], season_tags=["summer"]),
        make_item(3, "footwear", "white", occasion_tags=["casual"]),
    ]
    profile = make_profile()
    outfit = build_outfit(items, "casual", "warm", profile)
    assert outfit["top"] is not None
    assert outfit["bottom"] is not None
    assert outfit["footwear"] is not None

def test_build_outfit_no_wardrobe():
    profile = make_profile()
    outfit = build_outfit([], "casual", "warm", profile)
    assert outfit["top"] is None
    assert outfit["confidence_score"] == 0.0

def test_build_outfit_cold_includes_outerwear():
    items = [
        make_item(1, "tops", "white", season_tags=["winter"]),
        make_item(2, "bottoms", "navy", season_tags=["winter"]),
        make_item(3, "outerwear", "black", season_tags=["winter"]),
    ]
    profile = make_profile()
    outfit = build_outfit(items, "casual", "cold", profile)
    assert outfit["outerwear"] is not None

def test_detect_gaps_missing_footwear():
    items = [make_item(1, "tops", "white"), make_item(2, "bottoms", "navy")]
    profile = make_profile()
    gaps = detect_wardrobe_gaps(items, profile)
    categories = [g["gap_category"] for g in gaps]
    assert "footwear" in categories

def test_detect_gaps_no_outerwear():
    items = [make_item(1, "tops", "white")]
    profile = make_profile()
    gaps = detect_wardrobe_gaps(items, profile)
    categories = [g["gap_category"] for g in gaps]
    assert "outerwear" in categories

def test_build_explanation_has_summary():
    top = make_item(1, "tops", "white")
    bottom = make_item(2, "bottoms", "navy")
    outfit = {"top": top, "bottom": bottom, "footwear": None, "accessory": None, "outerwear": None}
    profile = make_profile()
    weather = {"temperature": 22, "condition": "Clear"}
    result = build_explanation(outfit, profile, weather, "casual")
    assert "summary" in result
    assert len(result["reasons"]) > 0
