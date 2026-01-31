# Structured Output Agent

A data analysis agent demonstrating Pydantic-validated structured outputs.

## Features

- Structured output validation with `result_type` parameter
- Pydantic models for response schema enforcement
- Field validation (ranges, patterns, constraints)
- Data analysis with statistical tools
- Professional report generation

## Output Models

| Model | Description |
|-------|-------------|
| `DataAnalysisReport` | Complete analysis with validated fields |
| `DataInsight` | Individual insight with confidence scores |

## Usage

```python
from examples.structured_output_agent.agent import analyze_data, AnalysisDependencies

deps = AnalysisDependencies(report_format="business")
report = await analyze_data("Sales data for Q4 2024...", deps)

# Structured output is validated
print(report.summary)
print(report.key_insights)
print(report.confidence_score)  # Guaranteed 0.0-1.0
```

## Running the Demo

```bash
# Set up environment variables
export LLM_API_KEY="your-api-key"
export LLM_MODEL="gpt-4"

# Run the demo
cd use-cases/pydantic-ai
python -m examples.structured_output_agent.agent
```

## Key Patterns Demonstrated

1. **result_type Parameter**: Forces structured JSON output matching Pydantic model
2. **Field Validation**: `Field(ge=0.0, le=1.0)` for numeric constraints
3. **Pattern Matching**: `Field(pattern="^(excellent|good|fair|poor)$")`
4. **Nested Models**: `DataInsight` inside `DataAnalysisReport`
5. **Optional Fields**: Graceful handling of optional report sections

## When to Use Structured Outputs

Use `result_type` when you need:
- Guaranteed schema compliance
- Type-safe downstream processing
- Data validation before storage
- API responses with defined contracts

Skip `result_type` (use default string) for:
- Conversational chat responses
- Creative or open-ended content
- Simple Q&A interactions
