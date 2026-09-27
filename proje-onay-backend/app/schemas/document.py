from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class DocumentCreate(BaseModel):
    project_id: int
    document_type: Optional[str] = None

class DocumentResponse(BaseModel):
    id: int
    project_id: int
    file_path: str
    document_type: Optional[str]
    is_signed: bool
    uploaded_at: datetime

    model_config = {"from_attributes": True}