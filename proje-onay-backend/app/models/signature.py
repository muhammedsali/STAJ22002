from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, Boolean
from sqlalchemy.sql import func
from app.core.database import Base

class Signature(Base):
    __tablename__ = "signatures"

    id = Column(Integer, primary_key=True, autoincrement=True)
    document_id = Column(Integer, ForeignKey("documents.id"), nullable=False)
    signer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    signed_at = Column(DateTime, server_default=func.now())
    certificate_info = Column(Text)
    is_valid = Column(Boolean)