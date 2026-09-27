from abc import ABC, abstractmethod
from typing import List
from sqlalchemy.orm import Session
from app.models.document import Document

class IDocumentRepository(ABC):
    @abstractmethod
    def get_by_project(self, db: Session, project_id: int) -> List[Document]:
        pass