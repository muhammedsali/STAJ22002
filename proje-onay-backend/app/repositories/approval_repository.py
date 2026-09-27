from typing import List
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.repositories.base import BaseRepository
from app.repositories.approval_repository_interface import IApprovalRepository
from app.models.approval_step import ApprovalStep

class ApprovalRepository(BaseRepository[ApprovalStep, BaseModel, BaseModel], IApprovalRepository):
    def get_by_project(self, db: Session, project_id: int) -> List[ApprovalStep]:
        return db.query(self.model).filter(self.model.project_id == project_id).order_by(self.model.step_number).all()

approval_repository = ApprovalRepository(ApprovalStep)