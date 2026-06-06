from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str = "sqlite+aiosqlite:///./fashion_copilot.db"
    secret_key: str = "dev-secret-key"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 10080  # 7 days
    gemini_api_key: str = ""
    openweather_api_key: str = ""

    class Config:
        env_file = ".env"

settings = Settings()
