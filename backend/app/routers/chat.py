from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models.user import User
from app.models.style import StyleProfile
from app.models.wardrobe import WardrobeItem
from app.models.chat import ChatHistory
from app.schemas.chat import ChatMessage, ChatMessageResponse, ChatResponse
from app.dependencies import get_current_user
from app.services.gemini_service import chat_with_stylist
from app.services.weather_service import get_weather

router = APIRouter(prefix="/chat", tags=["AI Stylist"])

@router.post("/", response_model=ChatResponse)
async def send_message(
    data: ChatMessage,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Load context
    profile_result = await db.execute(
        select(StyleProfile).where(StyleProfile.user_id == current_user.id)
    )
    profile = profile_result.scalar_one_or_none()

    wardrobe_result = await db.execute(
        select(WardrobeItem).where(WardrobeItem.user_id == current_user.id, WardrobeItem.is_active == True)
    )
    wardrobe = wardrobe_result.scalars().all()

    # Load recent chat history
    history_result = await db.execute(
        select(ChatHistory)
        .where(ChatHistory.user_id == current_user.id)
        .order_by(ChatHistory.created_at.desc())
        .limit(20)
    )
    history_rows = history_result.scalars().all()
    history = [{"role": h.role, "content": h.content} for h in reversed(history_rows)]

    weather = await get_weather("London")  # default; extend with user location

    # Save user message
    user_msg = ChatHistory(user_id=current_user.id, role="user", content=data.content)
    db.add(user_msg)
    await db.flush()

    # Get AI response
    ai_text = await chat_with_stylist(data.content, history, profile, wardrobe, weather)

    # Save assistant message
    assistant_msg = ChatHistory(user_id=current_user.id, role="assistant", content=ai_text)
    db.add(assistant_msg)
    await db.commit()
    await db.refresh(user_msg)
    await db.refresh(assistant_msg)

    return ChatResponse(
        user_message=ChatMessageResponse.model_validate(user_msg),
        assistant_message=ChatMessageResponse.model_validate(assistant_msg),
    )

@router.get("/history", response_model=list[ChatMessageResponse])
async def get_chat_history(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(ChatHistory)
        .where(ChatHistory.user_id == current_user.id)
        .order_by(ChatHistory.created_at.asc())
        .limit(100)
    )
    return result.scalars().all()

@router.delete("/history", status_code=204)
async def clear_history(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(ChatHistory).where(ChatHistory.user_id == current_user.id)
    )
    for msg in result.scalars().all():
        await db.delete(msg)
    await db.commit()
