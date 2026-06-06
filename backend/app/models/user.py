from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    onboarding_complete = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    style_profile = relationship("StyleProfile", back_populates="user", uselist=False)
    wardrobe_items = relationship("WardrobeItem", back_populates="user")
    outfit_preferences = relationship("OutfitPreference", back_populates="user")
    saved_outfits = relationship("SavedOutfit", back_populates="user")
    events = relationship("Event", back_populates="user")
    chat_history = relationship("ChatHistory", back_populates="user")
    shopping_insights = relationship("ShoppingInsight", back_populates="user")
