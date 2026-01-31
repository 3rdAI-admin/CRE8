"""
Shared utilities for PydanticAI examples.

Provides common configuration and model setup used across all examples.
"""

from .settings import Settings, settings
from .providers import get_llm_model

__all__ = ["Settings", "settings", "get_llm_model"]
