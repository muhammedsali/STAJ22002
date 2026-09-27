from fastapi import FastAPI
from app.api.routes import auth, projects, documents, approvals, payments, audit

app = FastAPI(title="TEDAŞ Proje Onay Sistemi API")

app.include_router(auth.router)
app.include_router(projects.router)
app.include_router(documents.router)
app.include_router(approvals.router)
app.include_router(payments.router)
app.include_router(audit.router)