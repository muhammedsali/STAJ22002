from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.payment_request import PaymentRequest
from app.models.project import Project
from app.models.user import User
from app.schemas.payment import PaymentRequestCreate, PaymentDecision
from app.repositories.audit_repository import audit_repository

class PaymentService:
    def create_request(self, db: Session, payment_in: PaymentRequestCreate, current_user: User) -> PaymentRequest:
        project = db.query(Project).filter(Project.id == payment_in.project_id).first()
        if not project:
            raise HTTPException(status_code=404, detail="Proje bulunamadı.")
            
        # BOLA Koruması: Sadece projenin asıl sahibi hakediş talep edebilir
        if project.user_id != current_user.id:
            raise HTTPException(status_code=403, detail="Sadece proje sahibi hakediş talep edebilir.")
            
        if project.status != "onaylandi":
            raise HTTPException(status_code=400, detail="Sadece 'onaylandi' durumundaki projeler için hakediş talep edilebilir.")
        
        db_obj = PaymentRequest(
            project_id=payment_in.project_id,
            amount=payment_in.amount,
            description=payment_in.description,
            status="talep_edildi"
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        
        audit_repository.log_action(db, "payment", db_obj.id, "created", current_user.id)
        return db_obj

    def process_decision(self, db: Session, payment_id: int, decision_in: PaymentDecision, current_user: User) -> PaymentRequest:
        payment = db.query(PaymentRequest).filter(PaymentRequest.id == payment_id).first()
        if not payment:
            raise HTTPException(status_code=404, detail="Hakediş talebi bulunamadı.")
        
        if decision_in.decision == "red":
            payment.status = "reddedildi"
        elif decision_in.decision == "onay":
            if payment.status == "talep_edildi":
                payment.status = "kademe1_onay"
            elif payment.status == "kademe1_onay":
                payment.status = "kademe2_onay"
            elif payment.status == "kademe2_onay":
                payment.status = "onaylandi"
            else:
                raise HTTPException(status_code=400, detail="Bu talep zaten nihai karara bağlanmış.")
        else:
            raise HTTPException(status_code=400, detail="Geçersiz karar. İzin verilenler: onay, red")
        
        db.commit()
        db.refresh(payment)
        
        audit_repository.log_action(db, "payment", payment.id, f"decision_{decision_in.decision}_{payment.status}", current_user.id)
        return payment
        
    def get_payments(self, db: Session):
        return db.query(PaymentRequest).all()

payment_service = PaymentService()