from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.sql import func
from app.core.database import Base

class AutoCheckResult(Base):
    __tablename__ = "auto_check_results"

    id = Column(Integer, primary_key=True, autoincrement=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=False)
    criterion = Column(String(100))
    result = Column(String(20))
    detail = Column(Text, nullable=True)
    checked_at = Column(DateTime, server_default=func.now())