# Fashion Copilot — AI Personal Stylist MVP

A full-stack AI-powered fashion assistant built with FastAPI + Flutter.

## Project Structure

```
fashion_copilot/
├── backend/          # FastAPI backend
│   ├── app/
│   │   ├── models/       # SQLAlchemy ORM models
│   │   ├── schemas/      # Pydantic request/response schemas
│   │   ├── routers/      # API route handlers
│   │   ├── services/     # Business logic
│   │   │   ├── recommendation_engine.py   # Rule-based outfit scorer
│   │   │   ├── gemini_service.py          # AI stylist via Gemini
│   │   │   ├── weather_service.py         # OpenWeatherMap integration
│   │   │   └── style_service.py           # Style DNA processing
│   │   ├── main.py
│   │   ├── database.py
│   │   ├── config.py
│   │   └── dependencies.py
│   ├── tests/
│   ├── requirements.txt
│   └── .env.example
└── frontend/         # Flutter app
    ├── lib/
    │   ├── core/         # Theme, router, constants
    │   ├── models/       # Data models
    │   ├── providers/    # State management (Provider)
    │   ├── services/     # API service
    │   └── screens/
    │       ├── splash_screen.dart
    │       ├── auth/         # Login, Signup
    │       ├── onboarding/   # Style DNA quiz
    │       ├── home/         # Dashboard + today's outfit
    │       ├── discover/     # Outfit Tinder
    │       ├── stylist/      # AI chat
    │       ├── wardrobe/     # Clothing inventory
    │       ├── calendar/     # Fashion calendar
    │       └── profile/      # Style DNA dashboard
    └── pubspec.yaml
```

## Quick Start

### Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Mac/Linux

pip install -r requirements.txt
cp .env.example .env
# Edit .env with your API keys

uvicorn app.main:app --reload
```

API docs available at: http://localhost:8000/docs

### Flutter

```bash
cd frontend
flutter pub get
flutter run
```

Update `lib/core/constants.dart` → `baseUrl` to point to your backend.

## API Keys Required

| Key | Where | Notes |
|-----|-------|-------|
| `GEMINI_API_KEY` | Google AI Studio | AI Stylist chat feature |
| `OPENWEATHER_API_KEY` | openweathermap.org | Weather-based recommendations |

Both are optional for MVP — app works without them (uses fallbacks).

## Running Tests

```bash
cd backend
pip install pytest pytest-asyncio httpx
pytest
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /auth/signup | Create account |
| POST | /auth/login | Get JWT token |
| GET | /auth/me | Current user |
| POST | /style/quiz | Submit Style DNA quiz |
| GET | /style/profile | Get style profile |
| GET | /style/tinder/outfits | Outfit cards for Tinder |
| POST | /style/tinder/swipe | Record like/dislike |
| GET | /style/evolution | Style evolution stats |
| GET | /wardrobe/ | List wardrobe items |
| POST | /wardrobe/ | Add item |
| PATCH | /wardrobe/{id} | Update item |
| DELETE | /wardrobe/{id} | Remove item |
| POST | /recommendations/ | Get outfit recommendation |
| GET | /recommendations/saved | Saved outfits |
| POST | /chat/ | Chat with AI stylist |
| GET | /chat/history | Chat history |
| GET | /weather/ | Current weather |
| GET | /events/ | List events |
| POST | /events/ | Create event |
| POST | /events/{id}/outfit | Generate event outfit |
| GET | /shopping/insights | Wardrobe gap analysis |

## Deployment (Render)

1. Push backend to GitHub
2. Create a new Web Service on Render
3. Set build command: `pip install -r requirements.txt`
4. Set start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Add environment variables from `.env.example`

For production, swap SQLite for PostgreSQL by updating `DATABASE_URL`:
```
DATABASE_URL=postgresql+asyncpg://user:pass@host/dbname
```
Add `asyncpg` to requirements.txt.

## Development Roadmap

**Week 1–2:** Backend setup, auth, database, wardrobe CRUD  
**Week 3–4:** Style DNA quiz, recommendation engine  
**Week 5–6:** Flutter UI — all screens wired to API  
**Week 7:** AI chat, weather integration, calendar  
**Week 8:** Testing, polish, deploy to Render
