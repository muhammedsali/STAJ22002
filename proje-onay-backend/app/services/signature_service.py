import os
import datetime
from pathlib import Path
from fastapi import HTTPException
from sqlalchemy.orm import Session

# Kriptografi ve Sertifika üretimi (Demo için)
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization, hashes
from cryptography import x509
from cryptography.x509.oid import NameOID

# pyHanko kütüphaneleri (PDF imzalama ve doğrulama)
from pyhanko.sign import signers
from pyhanko.pdf_utils.incremental_writer import IncrementalPdfFileWriter
from pyhanko.pdf_utils.reader import PdfFileReader
from pyhanko.sign.validation import validate_pdf_signature

from app.models.document import Document
from app.models.signature import Signature
from app.models.user import User
from app.repositories.audit_repository import audit_repository

# Projenin kök dizinini dinamik olarak belirliyoruz (proje-onay-backend/)
BASE_DIR = Path(__file__).resolve().parents[2]
def _get_or_create_demo_cert():
    """Demo amaçlı geçici bir X509 sertifikası ve private key üretir."""
    cert_path = BASE_DIR / "demo_cert.pem"
    key_path = BASE_DIR / "demo_key.pem"
    
    if not cert_path.exists() or not key_path.exists():
        key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
        subject = issuer = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, u"TEDAŞ Demo E-Imza")])
        cert = (
            x509.CertificateBuilder()
            .subject_name(subject)
            .issuer_name(issuer)
            .public_key(key.public_key())
            .serial_number(x509.random_serial_number())
            .not_valid_before(datetime.datetime.now(datetime.timezone.utc))
            .not_valid_after(datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=365))
            .sign(key, hashes.SHA256())
        )
        with open(key_path, "wb") as f:
            f.write(key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.TraditionalOpenSSL,
                encryption_algorithm=serialization.NoEncryption()
            ))
        with open(cert_path, "wb") as f:
            f.write(cert.public_bytes(serialization.Encoding.PEM))
            
    return str(cert_path), str(key_path)

class SignatureService:
    def sign_document(self, db: Session, document_id: int, current_user: User) -> dict:
        doc = db.query(Document).filter(Document.id == document_id).first()
        if not doc:
            raise HTTPException(status_code=404, detail="Evrak bulunamadı.")
        if not doc.file_path.endswith('.pdf'):
            raise HTTPException(status_code=400, detail="Sadece PDF formatındaki evraklar imzalanabilir.")
        if doc.is_signed:
            raise HTTPException(status_code=400, detail="Bu evrak zaten imzalanmış.")


        clean_sub_path = doc.file_path.lstrip("./").lstrip("/").replace("/", os.sep)
        absolute_in_path = BASE_DIR / clean_sub_path

        if not absolute_in_path.exists():
            raise HTTPException(status_code=404, detail=f"Sunucuda dosya bulunamadı: {absolute_in_path}")

        cert_path, key_path = _get_or_create_demo_cert()
        signer = signers.SimpleSigner.load(key_path, cert_path)

        absolute_out_path = Path(str(absolute_in_path).replace('.pdf', '_signed.pdf'))
        relative_db_out_path = doc.file_path.replace('.pdf', '_signed.pdf')

        try:
            with open(absolute_in_path, 'rb') as inf:
                w = IncrementalPdfFileWriter(inf)
                out_bytes = signers.sign_pdf(
                    w, signers.PdfSignatureMetadata(field_name='Signature1'),
                    signer=signer,
                )
                with open(absolute_out_path, 'wb') as outf:
                    outf.write(out_bytes.read() if hasattr(out_bytes, 'read') else out_bytes)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"İmzalama sırasında bir hata oluştu: {str(e)}")
        
        # Orijinal dosyayı silip, veritabanını güncelliyoruz
        if absolute_in_path.exists():
            os.remove(absolute_in_path)
            
        doc.file_path = relative_db_out_path
        doc.is_signed = True

        sig_record = Signature(
            document_id=doc.id,
            signer_id=current_user.id,
            certificate_info="TEDAŞ Demo E-İmza (pyHanko Self-Signed)",
            is_valid=True
        )
        db.add(sig_record)
        db.commit()

        audit_repository.log_action(db, "document", doc.id, "signed", current_user.id)
        return {"message": "Evrak başarıyla imzalandı.", "document_id": doc.id}

    def verify_document(self, db: Session, document_id: int) -> dict:
        doc = db.query(Document).filter(Document.id == document_id).first()
        if not doc or not doc.is_signed:
            return {"is_valid": False, "detail": "İmzalı bir belge bulunamadı veya belge henüz imzalanmamış."}

        clean_sub_path = doc.file_path.lstrip("./").lstrip("/").replace("/", os.sep)
        absolute_path = BASE_DIR / clean_sub_path

        if not absolute_path.exists():
            return {"is_valid": False, "detail": "İmzalanmış dosya sunucu diskinde bulunamadı."}

        try:
            with open(absolute_path, 'rb') as f:
                r = PdfFileReader(f)
                if not r.embedded_signatures:
                    return {"is_valid": False, "detail": "PDF içinde kriptografik imza bulunamadı."}
                
                # Belgenin hash bütünlüğünü doğruluyoruz (Bölüm 15 gereksinimi)
                sig = r.embedded_signatures[0]
                status = validate_pdf_signature(sig, signer_validation_context=None)
                
                # status.intact, belgenin imzalandıktan sonra değiştirilip değiştirilmediğini söyler
                if status.intact:
                    return {"is_valid": True, "detail": "İmza geçerli. Belge bütünlüğü korunmuş."}
                else:
                    return {"is_valid": False, "detail": "GEÇERSİZ İMZA: Belge imzalandıktan sonra değiştirilmiş!"}
        except Exception as e:
            return {"is_valid": False, "detail": f"Doğrulama hatası: {str(e)}"}

signature_service = SignatureService()