from typing import List
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.repositories.base import BaseRepository
from app.repositories.document_repository_interface import IDocumentRepository
from app.models.document import Document
from app.schemas.document import DocumentCreate

class DocumentRepository(BaseRepository[Document, DocumentCreate, BaseModel], IDocumentRepository):
    def get_by_project(self, db: Session, project_id: int) -> List[Document]:
        return db.query(self.model).filter(self.model.project_id == project_id).all()

document_repository = DocumentRepository(Document)