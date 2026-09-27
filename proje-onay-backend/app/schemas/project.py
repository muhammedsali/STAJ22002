from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ProjectCreate(BaseModel):
    title: str
    project_type: Optional[str] = None
    location: Optional[str] = None
    power_capacity: Optional[float] = None
    description: Optional[str] = None

class ProjectUpdate(BaseModel):
    title: Optional[str] = None
    project_type: Optional[str] = None
    location: Optional[str] = None
    power_capacity: Optional[float] = None
    description: Optional[str] = None

class ProjectResponse(BaseModel):
    id: int
    user_id: int
    title: str
    project_type: Optional[str]
    location: Optional[str]
    power_capacity: Optional[float]
    description: Optional[str]
    status: str
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}