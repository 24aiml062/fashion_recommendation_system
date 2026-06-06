"""Integration tests for auth endpoints."""
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.main import app
from app.database import Base, get_db

TEST_DB = "sqlite+aiosqlite:///./test.db"
engine = create_async_engine(TEST_DB)
TestSession = async_sessionmaker(engine, expire_on_commit=False)

async def override_get_db():
    async with TestSession() as session:
        yield session

app.dependency_overrides[get_db] = override_get_db

@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest.mark.asyncio
async def test_signup():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        res = await client.post("/auth/signup", json={
            "email": "test@example.com",
            "full_name": "Test User",
            "password": "password123"
        })
    assert res.status_code == 201
    assert "access_token" in res.json()

@pytest.mark.asyncio
async def test_signup_duplicate_email():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        await client.post("/auth/signup", json={
            "email": "dup@example.com", "full_name": "User", "password": "pass123"
        })
        res = await client.post("/auth/signup", json={
            "email": "dup@example.com", "full_name": "User2", "password": "pass456"
        })
    assert res.status_code == 400

@pytest.mark.asyncio
async def test_login_success():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        await client.post("/auth/signup", json={
            "email": "login@example.com", "full_name": "Login User", "password": "mypassword"
        })
        res = await client.post("/auth/login", json={
            "email": "login@example.com", "password": "mypassword"
        })
    assert res.status_code == 200
    assert "access_token" in res.json()

@pytest.mark.asyncio
async def test_login_wrong_password():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        await client.post("/auth/signup", json={
            "email": "wp@example.com", "full_name": "WP User", "password": "correct"
        })
        res = await client.post("/auth/login", json={
            "email": "wp@example.com", "password": "wrong"
        })
    assert res.status_code == 401

@pytest.mark.asyncio
async def test_get_me():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        signup = await client.post("/auth/signup", json={
            "email": "me@example.com", "full_name": "Me User", "password": "pass123"
        })
        token = signup.json()["access_token"]
        res = await client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert res.status_code == 200
    assert res.json()["email"] == "me@example.com"
