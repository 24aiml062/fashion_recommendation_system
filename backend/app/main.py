from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from contextlib import asynccontextmanager
from pathlib import Path
from app.database import init_db
from app.routers import auth, style, wardrobe, recommendations, chat, weather, events, shopping

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield

app = FastAPI(
    title="Fashion Copilot API",
    description="AI-powered personal stylist backend",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(style.router)
app.include_router(wardrobe.router)
app.include_router(recommendations.router)
app.include_router(chat.router)
app.include_router(weather.router)
app.include_router(events.router)
app.include_router(shopping.router)

# Serve the web frontend
web_dir = Path(__file__).parent.parent.parent / "web"
if web_dir.exists():
    app.mount("/static", StaticFiles(directory=str(web_dir)), name="static")

    @app.get("/app", include_in_schema=False)
    async def serve_frontend():
        return FileResponse(str(web_dir / "index.html"))

@app.get("/")
async def root():
    return {"status": "ok", "app": "Fashion Copilot API", "frontend": "/app"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
