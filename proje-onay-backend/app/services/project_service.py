from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.project import Project
from app.models.user import User
from app.schemas.project import ProjectCreate, ProjectUpdate
from app.repositories.project_repository import project_repository
from app.repositories.audit_repository import audit_repository

class ProjectService:
    def create_project(self, db: Session, project_in: ProjectCreate, current_user: User) -> Project:
        project_data = project_in.model_dump()
        project_data["user_id"] = current_user.id
        project_data["status"] = "taslak"
        
        db_obj = Project(**project_data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        
        # İşlemi logluyoruz
        audit_repository.log_action(db, "project", db_obj.id, "created", current_user.id)
        return db_obj

    def get_user_projects(self, db: Session, current_user: User):
        return project_repository.get_by_user(db, user_id=current_user.id)

    def get_project(self, db: Session, project_id: int, current_user: User) -> Project:
        project = project_repository.get(db, id=project_id)
        if not project:
            raise HTTPException(status_code=404, detail="Proje bulunamadı.")
        
        # BOLA Koruması: Sadece proje sahibi veya onaylayıcı/admin görebilir
        if project.user_id != current_user.id and current_user.role == "basvuru_sahibi":
            raise HTTPException(status_code=403, detail="Bu projeyi görüntüleme yetkiniz yok.")
        
        return project

    def update_project(self, db: Session, project_id: int, project_in: ProjectUpdate, current_user: User) -> Project:
        project = self.get_project(db, project_id, current_user)
        
        # BOLA Koruması: Sadece sahibi güncelleyebilir
        if project.user_id != current_user.id:
            raise HTTPException(status_code=403, detail="Sadece proje sahibi güncelleyebilir.")
            
        # İş mantığı: Sadece taslak durumunda güncellenebilir
        if project.status != "taslak":
            raise HTTPException(status_code=400, detail="Sadece taslak durumundaki projeler güncellenebilir.")
            
        updated_project = project_repository.update(db, db_obj=project, obj_in=project_in)
        audit_repository.log_action(db, "project", project.id, "updated", current_user.id)
        return updated_project

    def submit_project(self, db: Session, project_id: int, current_user: User) -> Project:
        project = self.get_project(db, project_id, current_user)
        
        if project.user_id != current_user.id:
            raise HTTPException(status_code=403, detail="Sadece proje sahibi başvuruyu gönderebilir.")
            
        if project.status != "taslak":
            raise HTTPException(status_code=400, detail="Sadece taslak durumundaki projeler gönderilebilir.")
            
        # Durumu güncelliyoruz
        project.status = "gonderildi"
        db.commit()
        db.refresh(project)
        
        audit_repository.log_action(db, "project", project.id, "submitted", current_user.id)
        return project

project_service = ProjectService()