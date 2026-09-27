from fastapi import APIRouter, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.schemas.document import DocumentResponse
from app.services.document_service import document_service
from app.services.signature_service import signature_service

router = APIRouter(tags=["Documents"])

@router.post("/projects/{id}/documents", response_model=DocumentResponse)
def upload_project_document(
    id: int, 
    file: UploadFile = File(...), 
    document_type: str = Form(...),
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    return document_service.upload_document(db, id, file, document_type, current_user)

@router.post("/documents/{id}/sign")
def sign_document(id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return signature_service.sign_document(db, id, current_user)

@router.get("/documents/{id}/verify")
def verify_document(id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return signature_service.verify_document(db, id)