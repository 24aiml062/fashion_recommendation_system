from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    title = Column(String, nullable=False)
    event_type = Column(String, nullable=False)  # interview, wedding, party, vacation, etc.
    event_date = Column(DateTime(timezone=True), nullable=False)
    location = Column(String, default="")
    notes = Column(String, default="")
    outfit_generated = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="events")
    recommendations = relationship("OutfitRecommendation", backref="event")
