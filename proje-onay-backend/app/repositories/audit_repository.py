from sqlalchemy.orm import Session
from app.models.audit_log import AuditLog

class AuditRepository:
    def log_action(self, db: Session, entity_type: str, entity_id: int, action: str, user_id: int) -> AuditLog:
        db_obj = AuditLog(
            entity_type=entity_type,
            entity_id=entity_id,
            action=action,
            user_id=user_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

audit_repository = AuditRepository()