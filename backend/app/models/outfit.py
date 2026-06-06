from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, JSON, Float, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class OutfitPreference(Base):
    __tablename__ = "outfit_preferences"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    outfit_data = Column(JSON, nullable=False)   # outfit item ids + metadata
    preference = Column(String, nullable=False)  # like, dislike, save
    source = Column(String, default="tinder")    # tinder, recommendation
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="outfit_preferences")


class SavedOutfit(Base):
    __tablename__ = "saved_outfits"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    name = Column(String, default="")
    outfit_data = Column(JSON, nullable=False)
    occasion = Column(String, default="")
    notes = Column(String, default="")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="saved_outfits")


class OutfitRecommendation(Base):
    __tablename__ = "outfit_recommendations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=True)
    top_id = Column(Integer, ForeignKey("wardrobe_items.id"), nullable=True)
    bottom_id = Column(Integer, ForeignKey("wardrobe_items.id"), nullable=True)
    footwear_id = Column(Integer, ForeignKey("wardrobe_items.id"), nullable=True)
    accessory_id = Column(Integer, ForeignKey("wardrobe_items.id"), nullable=True)
    outerwear_id = Column(Integer, ForeignKey("wardrobe_items.id"), nullable=True)
    confidence_score = Column(Float, default=0.0)
    explanation = Column(JSON, default=dict)     # {reasons: [], summary: ""}
    occasion = Column(String, default="")
    weather_data = Column(JSON, default=dict)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
