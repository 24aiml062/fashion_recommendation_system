from fastapi import APIRouter, Query
from app.services.weather_service import get_weather

router = APIRouter(prefix="/weather", tags=["Weather"])

@router.get("/")
async def current_weather(city: str = Query(default="London")):
    return await get_weather(city)
