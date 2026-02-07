# Tool-Enabled Agent

A research assistant agent with web search and calculation capabilities.

## Features

- Tool registration with `@agent.tool` decorator
- RunContext for dependency injection
- Parameter validation with type hints
- Error handling for tool failures
- Multiple tool types (sync and async)

## Tools Included

| Tool | Description |
|------|-------------|
| `web_search` | Search the web using DuckDuckGo API |
| `calculate` | Safe mathematical expression evaluation |
| `format_data` | Format data as table, list, or JSON |
| `get_current_time` | Get current timestamp |

## Usage

```python
from examples.tool_enabled_agent.agent import ask_agent, ToolDependencies
import aiohttp

async with aiohttp.ClientSession() as session:
    deps = ToolDependencies(session=session)
    response = await ask_agent("Calculate 25% of 200", deps)
    print(response)
```

## Running the Demo

```bash
# Set up environment variables
export LLM_API_KEY="your-api-key"
export LLM_MODEL="gpt-4"

# Run the demo
cd use-cases/pydantic-ai
python -m examples.tool_enabled_agent.agent
```

## Key Patterns Demonstrated

1. **Tool Registration**: `@agent.tool` decorator for adding capabilities
2. **Dependency Injection**: `RunContext[ToolDependencies]` for tool dependencies
3. **Async Tools**: `web_search` with aiohttp for non-blocking HTTP
4. **Safe Evaluation**: `calculate` with restricted `eval()` for security
5. **Error Handling**: Graceful degradation when tools fail
