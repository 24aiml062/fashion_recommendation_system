from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class EventCreate(BaseModel):
    title: str
    event_type: str
    event_date: datetime
    location: str = ""
    notes: str = ""

class EventUpdate(BaseModel):
    title: Optional[str] = None
    event_type: Optional[str] = None
    event_date: Optional[datetime] = None
    location: Optional[str] = None
    notes: Optional[str] = None

class EventResponse(BaseModel):
    id: int
    title: str
    event_type: str
    event_date: datetime
    location: str
    notes: str
    outfit_generated: bool

    class Config:
        from_attributes = True
