from abc import ABC, abstractmethod
from typing import List
from sqlalchemy.orm import Session
from app.models.project import Project

class IProjectRepository(ABC):
    @abstractmethod
    def get_by_user(self, db: Session, user_id: int) -> List[Project]:
        pass