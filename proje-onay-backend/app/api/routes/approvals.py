from fastapi import APIRouter, Depends
from typing import List
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.dependencies import RequireRole
from app.models.user import User
from app.schemas.project import ProjectResponse
from app.schemas.approval import ApprovalDecision
from app.services.approval_service import approval_service

router = APIRouter(tags=["Approvals"])

# BFLA Koruması: Sadece onaylayıcı ve admin rollerine izin veriliyor
@router.get("/approvals/queue", response_model=List[ProjectResponse])
def get_approval_queue(
    db: Session = Depends(get_db), 
    current_user: User = Depends(RequireRole(["onaylayici", "admin"]))
):
    return approval_service.get_approval_queue(db)

@router.post("/projects/{id}/approve", response_model=ProjectResponse)
def approve_project(
    id: int, 
    decision_in: ApprovalDecision, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(RequireRole(["onaylayici", "admin"]))
):
    return approval_service.process_approval(db, id, decision_in, current_user)