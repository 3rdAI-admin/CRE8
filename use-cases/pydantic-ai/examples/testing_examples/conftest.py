# Skip test collection - these example tests require OPENAI_API_KEY
# and use deprecated pydantic-ai API (FunctionModel)
collect_ignore = ["test_agent_patterns.py"]
