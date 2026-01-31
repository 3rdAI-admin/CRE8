"""
Pytest configuration for pydantic-ai testing examples.

These tests use TestModel for isolated testing without requiring API keys.
"""


def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line("markers", "integration: mark test as integration test")
    config.addinivalue_line("markers", "slow: mark test as slow running")
