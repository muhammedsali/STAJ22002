from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from app.core.database import Base

class ApprovalStep(Base):
    __tablename__ = "approval_steps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=False)
    step_number = Column(Integer)
    approver_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    decision = Column(String(30), nullable=True)
    reason = Column(Text, nullable=True)
    decided_at = Column(DateTime, nullable=True)