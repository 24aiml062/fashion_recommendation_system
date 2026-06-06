from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class StyleProfile(Base):
    __tablename__ = "style_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)

    # Style scores (0.0 - 1.0)
    minimalist_score = Column(Float, default=0.0)
    old_money_score = Column(Float, default=0.0)
    smart_casual_score = Column(Float, default=0.0)
    streetwear_score = Column(Float, default=0.0)
    formal_score = Column(Float, default=0.0)
    athleisure_score = Column(Float, default=0.0)
    indo_western_score = Column(Float, default=0.0)
    ethnic_score = Column(Float, default=0.0)

    # Lifestyle
    lifestyle = Column(String, default="student")  # student, professional
    social_frequency = Column(String, default="occasionally")
    daily_environment = Column(String, default="campus")
    fashion_importance = Column(Integer, default=3)  # 1-5

    # Budget
    budget_range = Column(String, default="medium")  # low, medium, high

    # Color preferences
    favorite_colors = Column(JSON, default=list)
    avoided_colors = Column(JSON, default=list)

    # Fit
    fit_preference = Column(String, default="regular")  # slim, regular, relaxed, oversized

    # Goals
    fashion_goals = Column(JSON, default=list)

    # Dominant style (computed)
    dominant_style = Column(String, default="")

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    user = relationship("User", back_populates="style_profile")


class StyleQuizResponse(Base):
    __tablename__ = "style_quiz_responses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    quiz_section = Column(String, nullable=False)
    question_key = Column(String, nullable=False)
    answer = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
