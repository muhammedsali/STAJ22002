from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.project import Project
from app.models.document import Document
from app.models.auto_check_result import AutoCheckResult
from app.services.signature_service import signature_service
from app.repositories.audit_repository import audit_repository

class AutoCheckService:
    def run_checks(self, db: Session, project_id: int) -> dict:
        project = db.query(Project).filter(Project.id == project_id).first()
        if not project:
            raise HTTPException(status_code=404, detail="Proje bulunamadı.")
            
        if project.status != "gonderildi":
            raise HTTPException(status_code=400, detail="Sadece 'gonderildi' durumundaki projelere otomatik ön kontrol yapılabilir.")

        documents = db.query(Document).filter(Document.project_id == project_id).all()
        
        doc_check = "gecti" if len(documents) > 0 else "kaldi"
        doc_detail = "Evraklar tam." if doc_check == "gecti" else "Projeye ait hiçbir evrak yüklenmemiş."
        self._save_result(db, project_id, "evrak_tamligi", doc_check, doc_detail)

        sig_check = "gecti"
        sig_detail = "Tüm evrak imzaları geçerli."
        
        if doc_check == "gecti":
            for doc in documents:
                if not doc.is_signed:
                    sig_check = "kaldi"
                    sig_detail = f"İmzasız evrak tespit edildi (Evrak ID: {doc.id})."
                    break
                
                verify_result = signature_service.verify_document(db, doc.id)
                if not verify_result["is_valid"]:
                    sig_check = "kaldi"
                    sig_detail = f"Geçersiz imza tespit edildi (Evrak ID: {doc.id}): {verify_result['detail']}"
                    break
        else:
            sig_check = "kaldi"
            sig_detail = "Evrak bulunmadığı için imza kontrolü yapılamadı."

        self._save_result(db, project_id, "imza_gecerliligi", sig_check, sig_detail)

        if doc_check == "gecti" and sig_check == "gecti":
            project.status = "kademe1"  
        else:
            project.status = "reddedildi"  
            
        db.commit()
        
        audit_repository.log_action(db, "project", project_id, f"auto_check_{project.status}", 0) 
        
        return {
            "project_id": project_id,
            "new_status": project.status,
            "results": [
                {"criterion": "evrak_tamligi", "result": doc_check, "detail": doc_detail},
                {"criterion": "imza_gecerliligi", "result": sig_check, "detail": sig_detail}
            ]
        }

    def _save_result(self, db: Session, project_id: int, criterion: str, result: str, detail: str):
        check_record = AutoCheckResult(
            project_id=project_id,
            criterion=criterion,
            result=result,
            detail=detail
        )
        db.add(check_record)
        db.commit()

    def get_results(self, db: Session, project_id: int):
        return db.query(AutoCheckResult).filter(AutoCheckResult.project_id == project_id).all()

auto_check_service = AutoCheckService()