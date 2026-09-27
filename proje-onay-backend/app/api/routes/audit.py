from fastapi import APIRouter, Depends
from typing import List, Optional
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.dependencies import RequireRole
from app.models.user import User
from app.models.audit_log import AuditLog
from app.schemas.audit import AuditLogResponse

router = APIRouter(prefix="/audit-logs", tags=["Audit"])

# BFLA Koruması: Logları sadece admin rolüne sahip kullanıcılar görüntüleyebilir
@router.get("", response_model=List[AuditLogResponse])
def get_audit_logs(
    project_id: Optional[int] = None, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(RequireRole(["admin"]))
):
    query = db.query(AuditLog)
    if project_id:
        query = query.filter(AuditLog.entity_type == "project", AuditLog.entity_id == project_id)
    return query.order_by(AuditLog.timestamp.desc()).all()