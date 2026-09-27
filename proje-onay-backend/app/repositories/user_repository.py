from typing import Optional
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.repositories.base import BaseRepository
from app.repositories.user_repository_interface import IUserRepository
from app.models.user import User
from app.schemas.user import UserCreate

class UserRepository(BaseRepository[User, UserCreate, BaseModel], IUserRepository):
    def get_by_email(self, db: Session, email: str) -> Optional[User]:
        return db.query(self.model).filter(self.model.email == email).first()

user_repository = UserRepository(User)