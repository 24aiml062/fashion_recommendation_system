"""
Gemini AI integration using direct HTTP calls (no SDK required).
Falls back gracefully if API key is not set.
"""
import httpx
from app.config import settings

GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

SYSTEM_PROMPT = """You are a professional personal stylist AI assistant.
Provide personalized fashion advice based on the user's style profile, wardrobe, weather, budget, and occasion.
Always explain your reasoning. Be concise, practical, and fashion-aware.
Keep responses under 200 words unless the user asks for detail."""


def _build_context(profile, wardrobe, weather) -> str:
    ctx = []
    if profile:
        dominant = profile.dominant_style or "eclectic"
        ctx.append(f"Style DNA: {dominant} | Budget: {profile.budget_range} | Fit: {profile.fit_preference}")
        if profile.favorite_colors:
            ctx.append(f"Favorite colors: {', '.join(profile.favorite_colors)}")
        if profile.fashion_goals:
            ctx.append(f"Fashion goals: {', '.join(profile.fashion_goals)}")

    if wardrobe:
        cats = {}
        for item in wardrobe:
            cats.setdefault(item.category, []).append(item.name)
        summary = " | ".join(f"{k}: {', '.join(v[:3])}" for k, v in cats.items())
        ctx.append(f"Wardrobe: {summary}")

    if weather:
        ctx.append(f"Weather: {weather.get('temperature', '?')}°C, {weather.get('condition', 'unknown')}")

    return "\n".join(ctx) if ctx else "No profile data available."


async def chat_with_stylist(
    user_message: str,
    history: list[dict],
    profile,
    wardrobe: list,
    weather: dict | None,
) -> str:
    if not settings.gemini_api_key:
        return (
            "I'm your AI stylist! Add a Gemini API key in your .env file to activate full AI responses. "
            "For now, use the Recommendations tab for outfit suggestions."
        )

    context = _build_context(profile, wardrobe, weather)
    full_prompt = f"{SYSTEM_PROMPT}\n\nUser Context:\n{context}\n\nUser: {user_message}"

    # Build contents array with history
    contents = []
    for msg in history[-8:]:  # last 8 messages
        role = "user" if msg["role"] == "user" else "model"
        contents.append({"role": role, "parts": [{"text": msg["content"]}]})
    contents.append({"role": "user", "parts": [{"text": full_prompt}]})

    payload = {"contents": contents}

    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(
                f"{GEMINI_URL}?key={settings.gemini_api_key}",
                json=payload,
            )
            if resp.status_code != 200:
                return f"Stylist is unavailable right now (status {resp.status_code}). Try again shortly."

            data = resp.json()
            return data["candidates"][0]["content"]["parts"][0]["text"]

    except httpx.TimeoutException:
        return "Request timed out. Please try again."
    except Exception as e:
        return f"Something went wrong: {str(e)[:80]}"
