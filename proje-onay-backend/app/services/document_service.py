import os
import shutil
import uuid
from fastapi import UploadFile, HTTPException, status
from sqlalchemy.orm import Session
from app.core.config import settings
from app.models.document import Document
from app.models.user import User
from app.repositories.audit_repository import audit_repository
from app.services.project_service import project_service

# Güvenlik Kısıtlamaları (Bölüm 15)
ALLOWED_MIME_TYPES = ["application/pdf", "image/jpeg", "image/png"]
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB

class DocumentService:
    def upload_document(self, db: Session, project_id: int, file: UploadFile, document_type: str, current_user: User) -> Document:
        # BOLA Koruması: Sadece proje sahibi işlem yapabilir
        project = project_service.get_project(db, project_id, current_user)
        if project.user_id != current_user.id:
            raise HTTPException(status_code=403, detail="Sadece proje sahibi evrak yükleyebilir.")
        
        # Güvenlik: MIME tipi kontrolü
        if file.content_type not in ALLOWED_MIME_TYPES:
            raise HTTPException(status_code=400, detail="Sadece PDF, JPEG veya PNG formatında dosya yüklenebilir.")
            
        # Dosya boyutu kontrolü için imleci sona alıp boyutu okuyoruz, sonra başa sarıyoruz
        file.file.seek(0, 2)
        file_size = file.file.tell()
        file.file.seek(0)
        
        if file_size > MAX_FILE_SIZE:
            raise HTTPException(status_code=400, detail="Dosya boyutu 10MB'ı geçemez.")

        # Benzersiz dosya adı oluşturma ve diske yazma
        os.makedirs(settings.STORAGE_PATH, exist_ok=True)
        file_extension = file.filename.split(".")[-1]
        unique_filename = f"{uuid.uuid4()}.{file_extension}"
        file_path = os.path.join(settings.STORAGE_PATH, unique_filename)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Veritabanına kaydetme
        db_obj = Document(
            project_id=project_id,
            file_path=file_path,
            document_type=document_type,
            is_signed=False
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        
        # Denetim (Audit) kaydı oluşturma
        audit_repository.log_action(db, "document", db_obj.id, "uploaded", current_user.id)
        
        return db_obj

document_service = DocumentService()