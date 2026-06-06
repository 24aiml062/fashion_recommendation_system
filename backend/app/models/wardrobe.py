from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, JSON, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class WardrobeItem(Base):
    __tablename__ = "wardrobe_items"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    name = Column(String, nullable=False)
    category = Column(String, nullable=False)  # tops, bottoms, footwear, accessories, outerwear
    primary_color = Column(String, nullable=False)
    style_tags = Column(JSON, default=list)     # ["minimalist", "formal"]
    season_tags = Column(JSON, default=list)    # ["summer", "spring"]
    occasion_tags = Column(JSON, default=list)  # ["casual", "work", "formal"]
    brand = Column(String, default="")
    notes = Column(String, default="")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="wardrobe_items")
