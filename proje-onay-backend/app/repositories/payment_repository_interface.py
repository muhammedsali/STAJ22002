from abc import ABC, abstractmethod
from typing import Optional
from sqlalchemy.orm import Session
from app.models.payment_request import PaymentRequest

class IPaymentRepository(ABC):
    @abstractmethod
    def get_by_project(self, db: Session, project_id: int) -> Optional[PaymentRequest]:
        pass