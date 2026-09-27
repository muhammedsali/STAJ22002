from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.project import Project
from app.models.approval_step import ApprovalStep
from app.models.user import User
from app.schemas.approval import ApprovalDecision
from app.repositories.audit_repository import audit_repository

class ApprovalService:
    def get_approval_queue(self, db: Session):
        return db.query(Project).filter(Project.status.in_(["kademe1", "kademe2"])).all()

    def process_approval(self, db: Session, project_id: int, decision_in: ApprovalDecision, current_user: User) -> Project:
        project = db.query(Project).filter(Project.id == project_id).first()
        if not project:
            raise HTTPException(status_code=404, detail="Proje bulunamadı.")
        
        if project.status not in ["kademe1", "kademe2"]:
            raise HTTPException(status_code=400, detail="Bu proje şu an onaylanabilir bir aşamada değil.")
            
        if decision_in.decision in ["red", "ek_belge"] and not decision_in.reason:
            raise HTTPException(status_code=400, detail="Red veya ek belge taleplerinde gerekçe (reason) zorunludur.")

        current_step_number = 1 if project.status == "kademe1" else 2
        
        if decision_in.decision == "onay":
            if current_step_number == 1:
                project.status = "kademe2"
            else:
                project.status = "onaylandi"
        elif decision_in.decision == "red":
            project.status = "reddedildi"
        elif decision_in.decision == "ek_belge":
            project.status = "ek_belge_istendi"
        else:
            raise HTTPException(status_code=400, detail="Geçersiz karar. İzin verilenler: onay, red, ek_belge")

        approval_step = ApprovalStep(
            project_id=project.id,
            step_number=current_step_number,
            approver_id=current_user.id,
            decision=decision_in.decision,
            reason=decision_in.reason,
            decided_at=datetime.now()
        )
        db.add(approval_step)
        db.commit()
        db.refresh(project)

        # Denetim (Audit) logu
        audit_repository.log_action(db, "project", project.id, f"approval_{decision_in.decision}_step{current_step_number}", current_user.id)
        
        return project

approval_service = ApprovalService()