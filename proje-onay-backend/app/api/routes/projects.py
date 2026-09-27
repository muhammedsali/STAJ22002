from fastapi import APIRouter, Depends
from typing import List
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.dependencies import get_current_user, RequireRole
from app.models.user import User
from app.schemas.project import ProjectCreate, ProjectUpdate, ProjectResponse
from app.services.project_service import project_service
from app.services.auto_check_service import auto_check_service

router = APIRouter(prefix="/projects", tags=["Projects"])

@router.post("", response_model=ProjectResponse)
def create_project(project_in: ProjectCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return project_service.create_project(db, project_in, current_user)

@router.get("", response_model=List[ProjectResponse])
def get_projects(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return project_service.get_user_projects(db, current_user)

@router.get("/{id}", response_model=ProjectResponse)
def get_project(id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return project_service.get_project(db, id, current_user)

@router.patch("/{id}", response_model=ProjectResponse)
def update_project(id: int, project_in: ProjectUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return project_service.update_project(db, id, project_in, current_user)

@router.post("/{id}/submit", response_model=ProjectResponse)
def submit_project(id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return project_service.submit_project(db, id, current_user)

@router.post("/{id}/auto-check")
def trigger_auto_check(id: int, db: Session = Depends(get_db)):
    return auto_check_service.run_checks(db, id)

@router.get("/{id}/auto-check")
def get_auto_check_results(
    id: int, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(RequireRole(["onaylayici", "admin"]))
):
    return auto_check_service.get_results(db, id)