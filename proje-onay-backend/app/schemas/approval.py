from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ApprovalDecision(BaseModel):
    decision: str 
    reason: Optional[str] = None

class ApprovalStepResponse(BaseModel):
    id: int
    project_id: int
    step_number: int
    approver_id: Optional[int]
    decision: Optional[str]
    reason: Optional[str]
    decided_at: Optional[datetime]

    model_config = {"from_attributes": True}