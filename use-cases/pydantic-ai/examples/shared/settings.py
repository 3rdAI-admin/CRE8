"""
Configuration management using pydantic-settings.

Provides a shared Settings class for LLM configuration used across examples.
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Settings(BaseSettings):
    """Application settings with environment variable support."""

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", case_sensitive=False
    )

    # LLM Configuration
    llm_provider: str = Field(default="openai")
    llm_api_key: str = Field(...)
    llm_model: str = Field(default="gpt-4")
    llm_base_url: Optional[str] = Field(default="https://api.openai.com/v1")


# Global settings instance with fallback for testing
try:
    settings = Settings()  # type: ignore[call-arg]
except Exception:
    # For testing without env vars, create settings with dummy values
    os.environ.setdefault("LLM_API_KEY", "test-key")
    settings = Settings()  # type: ignore[call-arg]
