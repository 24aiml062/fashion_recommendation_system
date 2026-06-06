from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class ShoppingInsight(Base):
    __tablename__ = "shopping_insights"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    gap_category = Column(String, nullable=False)
    gap_description = Column(String, nullable=False)
    recommendation = Column(String, nullable=False)
    reason = Column(Text, nullable=False)
    priority = Column(String, default="medium")  # low, medium, high
    is_dismissed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="shopping_insights")
