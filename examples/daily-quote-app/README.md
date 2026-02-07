# Daily Quote App

A sample Flask application demonstrating the Context Engineering workflow.

## Overview

This example shows how to use the Context Engineering Template to build a complete web application from an INITIAL.md specification.

## Files

| File | Description |
|------|-------------|
| `INITIAL.md` | Feature requirements specification |
| `app.py` | Flask application entry point |
| `quotes.py` | Quote data organized by category |
| `templates/` | Jinja2 HTML templates |
| `static/` | CSS and JavaScript assets |
| `requirements.txt` | Python dependencies |

## Features

- Displays inspirational quotes with background images
- Category filtering (Motivation, Success, Wisdom, Life)
- Favorite quotes saved to browser localStorage
- Responsive design for mobile and desktop

## Usage

### As a Learning Example

1. Review `INITIAL.md` to understand the feature specification format
2. Study how the specification maps to the implemented code
3. Use this as a template for your own INITIAL.md files

### Running the App

```bash
cd examples/daily-quote-app
pip install -r requirements.txt
python app.py
```

Then open http://localhost:5000 in your browser.

## Context Engineering Workflow

To rebuild this app from scratch using the template:

1. Copy `INITIAL.md` to a new project
2. Run `/generate-prp INITIAL.md` to create an implementation plan
3. Run `/execute-prp PRPs/daily-quote.md` to implement
4. Run `/validate-project` to verify the implementation
