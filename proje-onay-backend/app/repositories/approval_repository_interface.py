from abc import ABC, abstractmethod
from typing import List
from sqlalchemy.orm import Session
from app.models.approval_step import ApprovalStep

class IApprovalRepository(ABC):
    @abstractmethod
    def get_by_project(self, db: Session, project_id: int) -> List[ApprovalStep]:
        pass