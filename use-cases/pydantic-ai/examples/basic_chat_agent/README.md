# Basic Chat Agent

A simple conversational agent demonstrating core PydanticAI patterns.

## Features

- Environment-based model configuration via shared settings
- System prompts for personality and behavior
- Conversation context with memory
- Dynamic prompts based on context
- String output (default, no result_type needed)

## Files

| File | Description |
|------|-------------|
| `agent.py` | Main agent implementation |
| `__init__.py` | Package exports |

## Usage

```python
from examples.basic_chat_agent.agent import chat_with_agent, ConversationContext

# Create context for the conversation
context = ConversationContext(user_name="Alex")

# Chat with the agent
response = await chat_with_agent("Hello!", context)
print(response)
```

## Running the Demo

```bash
# Set up environment variables
export LLM_API_KEY="your-api-key"
export LLM_MODEL="gpt-4"

# Run the demo
cd use-cases/pydantic-ai
python -m examples.basic_chat_agent.agent
```

## Key Patterns Demonstrated

1. **Shared Configuration**: Uses `..shared.get_llm_model()` for consistent setup
2. **Context Dependency**: `ConversationContext` dataclass for state management
3. **Dynamic System Prompts**: `@agent.system_prompt` decorator for context-aware prompts
4. **Async/Sync Interfaces**: Both `chat_with_agent()` and `chat_with_agent_sync()`
