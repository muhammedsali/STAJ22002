from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # Zorunlu alanlar (Eksikse uygulama başlamaz)
    DATABASE_URL: str
    SECRET_KEY: str
    
    # Varsayılanı olan alanlar
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    STORAGE_PATH: str = "./storage/documents"

    # .env dosyasını okuması için yapılandırma
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

try:
    settings = Settings()
except Exception as e:
    # Staj 1'deki RuntimeError desenini uygulayarak eksik env değişkeninde uygulamanın çökmesini sağlıyoruz.
    raise RuntimeError(f"Çevresel değişkenler yüklenirken kritik bir hata oluştu. Lütfen .env dosyanızı kontrol edin. Hata: {e}")