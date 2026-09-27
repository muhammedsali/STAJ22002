from datetime import datetime, timedelta, timezone
from typing import Any, Union
from jose import jwt
from passlib.context import CryptContext
from app.core.config import settings

# Şifre hashleme algoritması olarak bcrypt kullanıyoruz
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Düz metin şifre ile hashlenmiş şifrenin eşleşip eşleşmediğini kontrol eder."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Düz metin şifreyi hashler."""
    return pwd_context.hash(password)

def create_access_token(subject: Union[str, Any], role: str) -> str:
    """Kullanıcı kimliği (sub) ve rolü (role) içeren JWT token üretir."""
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    # JWT içine gömülecek veriler (payload)
    to_encode = {"exp": expire, "sub": str(subject), "role": role}
    
    # Token'ı SECRET_KEY ve ALGORITHM kullanarak imzala
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt