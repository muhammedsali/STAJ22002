from typing import Optional
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.repositories.base import BaseRepository
from app.repositories.payment_repository_interface import IPaymentRepository
from app.models.payment_request import PaymentRequest
from app.schemas.payment import PaymentRequestCreate

class PaymentRepository(BaseRepository[PaymentRequest, PaymentRequestCreate, BaseModel], IPaymentRepository):
    def get_by_project(self, db: Session, project_id: int) -> Optional[PaymentRequest]:
        return db.query(self.model).filter(self.model.project_id == project_id).first()

payment_repository = PaymentRepository(PaymentRequest)