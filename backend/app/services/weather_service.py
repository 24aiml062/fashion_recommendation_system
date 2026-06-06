import httpx
from app.config import settings

WEATHER_BASE = "https://api.openweathermap.org/data/2.5/weather"

async def get_weather(city: str) -> dict:
    """Fetch current weather for a city. Returns simplified weather dict."""
    if not settings.openweather_api_key:
        return _mock_weather()

    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(WEATHER_BASE, params={
                "q": city,
                "appid": settings.openweather_api_key,
                "units": "metric"
            }, timeout=5.0)
            if resp.status_code != 200:
                return _mock_weather()
            data = resp.json()
            return {
                "city": city,
                "temperature": data["main"]["temp"],
                "feels_like": data["main"]["feels_like"],
                "humidity": data["main"]["humidity"],
                "condition": data["weather"][0]["main"],
                "description": data["weather"][0]["description"],
                "rain_probability": data.get("rain", {}).get("1h", 0),
                "wind_speed": data["wind"]["speed"],
            }
        except Exception:
            return _mock_weather()

def _mock_weather() -> dict:
    return {
        "city": "Unknown",
        "temperature": 22.0,
        "feels_like": 21.0,
        "humidity": 60,
        "condition": "Clear",
        "description": "clear sky",
        "rain_probability": 0,
        "wind_speed": 3.0,
    }

def get_weather_category(weather: dict) -> str:
    """Convert weather to clothing category: hot, warm, cool, cold, rainy."""
    temp = weather.get("temperature", 22)
    condition = weather.get("condition", "Clear").lower()
    if "rain" in condition or "drizzle" in condition:
        return "rainy"
    if temp >= 28:
        return "hot"
    if temp >= 18:
        return "warm"
    if temp >= 10:
        return "cool"
    return "cold"
