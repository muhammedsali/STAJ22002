from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Numeric, Text
from sqlalchemy.sql import func
from app.core.database import Base

class PaymentRequest(Base):
    __tablename__ = "payment_requests"

    id = Column(Integer, primary_key=True, autoincrement=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    description = Column(Text)
    status = Column(String(30))
    created_at = Column(DateTime, server_default=func.now())