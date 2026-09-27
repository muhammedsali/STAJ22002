from typing import List
from sqlalchemy.orm import Session
from app.repositories.base import BaseRepository
from app.repositories.project_repository_interface import IProjectRepository
from app.models.project import Project
from app.schemas.project import ProjectCreate, ProjectUpdate

class ProjectRepository(BaseRepository[Project, ProjectCreate, ProjectUpdate], IProjectRepository):
    def get_by_user(self, db: Session, user_id: int) -> List[Project]:
        return db.query(self.model).filter(self.model.user_id == user_id).all()

project_repository = ProjectRepository(Project)