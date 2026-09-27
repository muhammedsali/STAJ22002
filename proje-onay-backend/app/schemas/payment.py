from pydantic import BaseModel
from datetime import datetime
from decimal import Decimal
from typing import Optional

class PaymentRequestCreate(BaseModel):
    project_id: int
    amount: Decimal
    description: Optional[str] = None

class PaymentDecision(BaseModel):
    decision: str

class PaymentResponse(BaseModel):
    id: int
    project_id: int
    amount: Decimal
    description: Optional[str]
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}