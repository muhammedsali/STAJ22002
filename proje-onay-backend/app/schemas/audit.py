from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class AuditLogResponse(BaseModel):
    id: int
    entity_type: Optional[str]
    entity_id: Optional[int]
    action: Optional[str]
    user_id: Optional[int]
    timestamp: datetime

    model_config = {"from_attributes": True}