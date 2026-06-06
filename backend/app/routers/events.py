from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models.user import User
from app.models.event import Event
from app.models.style import StyleProfile
from app.models.wardrobe import WardrobeItem
from app.models.outfit import OutfitRecommendation
from app.schemas.event import EventCreate, EventUpdate, EventResponse
from app.dependencies import get_current_user
from app.services.weather_service import get_weather, get_weather_category
from app.services.recommendation_engine import build_outfit, build_explanation

router = APIRouter(prefix="/events", tags=["Fashion Calendar"])

@router.get("/", response_model=list[EventResponse])
async def list_events(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Event).where(Event.user_id == current_user.id).order_by(Event.event_date)
    )
    return result.scalars().all()

@router.post("/", response_model=EventResponse, status_code=201)
async def create_event(
    data: EventCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    event = Event(user_id=current_user.id, **data.model_dump())
    db.add(event)
    await db.commit()
    await db.refresh(event)
    return event

@router.get("/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Event).where(Event.id == event_id, Event.user_id == current_user.id)
    )
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event

@router.patch("/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: int,
    data: EventUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Event).where(Event.id == event_id, Event.user_id == current_user.id)
    )
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(event, field, value)
    await db.commit()
    await db.refresh(event)
    return event

@router.delete("/{event_id}", status_code=204)
async def delete_event(
    event_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Event).where(Event.id == event_id, Event.user_id == current_user.id)
    )
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    await db.delete(event)
    await db.commit()

@router.post("/{event_id}/outfit")
async def generate_event_outfit(
    event_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Generate an outfit recommendation for a specific event."""
    event_result = await db.execute(
        select(Event).where(Event.id == event_id, Event.user_id == current_user.id)
    )
    event = event_result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    profile_result = await db.execute(select(StyleProfile).where(StyleProfile.user_id == current_user.id))
    profile = profile_result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=400, detail="Complete style quiz first")

    wardrobe_result = await db.execute(
        select(WardrobeItem).where(WardrobeItem.user_id == current_user.id, WardrobeItem.is_active == True)
    )
    wardrobe = wardrobe_result.scalars().all()

    weather = await get_weather(event.location or "London")
    weather_cat = get_weather_category(weather)
    outfit = build_outfit(wardrobe, event.event_type, weather_cat, profile)
    explanation = build_explanation(outfit, profile, weather, event.event_type)

    rec = OutfitRecommendation(
        user_id=current_user.id,
        event_id=event.id,
        top_id=outfit["top"].id if outfit["top"] else None,
        bottom_id=outfit["bottom"].id if outfit["bottom"] else None,
        footwear_id=outfit["footwear"].id if outfit["footwear"] else None,
        accessory_id=outfit["accessory"].id if outfit["accessory"] else None,
        outerwear_id=outfit["outerwear"].id if outfit["outerwear"] else None,
        confidence_score=outfit["confidence_score"],
        explanation=explanation,
        occasion=event.event_type,
        weather_data=weather,
    )
    db.add(rec)
    event.outfit_generated = True
    await db.commit()
    await db.refresh(rec)
    return {"recommendation_id": rec.id, "explanation": explanation}
