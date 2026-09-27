# seed.py
from app.core.database import SessionLocal
from app.models.user import User
from app.core.security import get_password_hash

def seed_users():
    db = SessionLocal()
    try:
        users = [
            {
                "email": "m@t.com",
                "password": "123",
                "role": "basvuru_sahibi",
                "full_name": "Muhammed (Mühendis)"
            },
            {
                "email": "o@t.com",
                "password": "123",
                "role": "onaylayici",
                "full_name": "Onaylayıcı Personel"
            },
            {
                "email": "a@t.com",
                "password": "123",
                "role": "admin",
                "full_name": "Sistem Yöneticisi"
            },
        ]

        for u in users:
            existing = db.query(User).filter(User.email == u["email"]).first()
            if not existing:
                user_obj = User(
                    email=u["email"],
                    hashed_password=get_password_hash(u["password"]),
                    role=u["role"],
                    full_name=u["full_name"]
                )
                db.add(user_obj)
                print(f"Kullanıcı eklendi: {u['email']} ({u['role']})")
            else:
                print(f"Zaten mevcut: {u['email']}")

        db.commit()
        print("Tohumlama tamamlandı! Basit girişli test kullanıcıları hazır.")
    finally:
        db.close()

if __name__ == "__main__":
    seed_users()