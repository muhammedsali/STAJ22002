from fastapi import APIRouter, Depends
from typing import List
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.dependencies import get_current_user, RequireRole
from app.models.user import User
from app.schemas.payment import PaymentRequestCreate, PaymentDecision, PaymentResponse
from app.services.payment_service import payment_service

router = APIRouter(prefix="/payments", tags=["Payments"])

@router.post("", response_model=PaymentResponse)
def create_payment(
    payment_in: PaymentRequestCreate, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    return payment_service.create_request(db, payment_in, current_user)

@router.get("", response_model=List[PaymentResponse])
def get_payments(
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    return payment_service.get_payments(db)

# BFLA Koruması: Ödeme onaylarını sadece onaylayici ve admin yapabilir
@router.post("/{id}/decision", response_model=PaymentResponse)
def process_payment_decision(
    id: int, 
    decision_in: PaymentDecision, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(RequireRole(["onaylayici", "admin"]))
):
    return payment_service.process_decision(db, id, decision_in, current_user)