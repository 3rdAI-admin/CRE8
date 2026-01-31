#!/bin/bash

# =============================================================================
# Context Engineering Template - Cursor IDE Setup Script
# =============================================================================
# This script verifies and sets up the Cursor IDE environment for the
# Context Engineering workflow with PRPs (Product Requirements Prompts).
#
# Original Creator: Cole Medin (https://github.com/coleam00)
# Repository: https://github.com/coleam00/Context-Engineering-Intro
# License: MIT
#
# Contributor: James Avila (https://th3rdai.com)
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emoji indicators
CHECK="✅"
CROSS="❌"
WARN="⚠️"
INFO="ℹ️"
ROCKET="🚀"

# Get script directory (project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ${CYAN}Context Engineering - Cursor IDE Setup${BLUE}                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track overall status
ERRORS=0
WARNINGS=0

# =============================================================================
# Phase 1: Check Cursor CLI
# =============================================================================
echo -e "${CYAN}Phase 1: Checking Cursor CLI...${NC}"
echo "─────────────────────────────────────────────────────────────────"

if command -v cursor &> /dev/null; then
    CURSOR_VERSION=$(cursor --version 2>/dev/null | head -n 1 || echo "unknown")
    echo -e "${CHECK} ${GREEN}Cursor CLI is available${NC}"
    echo -e "   ${INFO} Version: ${CURSOR_VERSION}"
else
    echo -e "${WARN} ${YELLOW}Cursor CLI not found in PATH${NC}"
    echo -e "   ${INFO} Install Cursor from: https://cursor.sh/"
    echo -e "   ${INFO} After installation, run: 'Shell Command: Install cursor command' from Cursor"
    ((WARNINGS++))
fi
echo ""

# =============================================================================
# Phase 2: Verify Project Structure
# =============================================================================
echo -e "${CYAN}Phase 2: Verifying Project Structure...${NC}"
echo "─────────────────────────────────────────────────────────────────"

# Check .cursorrules file
if [ -f "${SCRIPT_DIR}/.cursorrules" ]; then
    RULES_LINES=$(wc -l < "${SCRIPT_DIR}/.cursorrules" | tr -d ' ')
    RULES_SIZE=$(stat -f%z "${SCRIPT_DIR}/.cursorrules" 2>/dev/null || stat -c%s "${SCRIPT_DIR}/.cursorrules" 2>/dev/null)
    echo -e "${CHECK} ${GREEN}.cursorrules exists${NC}"
    echo -e "   ${INFO} Lines: ${RULES_LINES}, Size: ${RULES_SIZE} bytes"
    
    # Check file encoding
    FILE_TYPE=$(file "${SCRIPT_DIR}/.cursorrules" | cut -d: -f2)
    if echo "$FILE_TYPE" | grep -qi "utf-8\|ascii"; then
        echo -e "   ${CHECK} Encoding: UTF-8/ASCII"
    else
        echo -e "   ${WARN} ${YELLOW}Encoding might not be UTF-8: ${FILE_TYPE}${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${CROSS} ${RED}.cursorrules not found${NC}"
    echo -e "   ${INFO} Creating .cursorrules from template..."
    
    # Create .cursorrules if missing
    cat > "${SCRIPT_DIR}/.cursorrules" << 'CURSORRULES_EOF'
# Context Engineering Template - Cursor AI Rules

## Project Overview
This is a **Context Engineering Template** for AI-assisted development using PRPs (Product Requirements Prompts).

## Core Workflow: The PRP Pattern

1. **INITIAL.md** → Define requirements in structured format
2. **Generate PRP** → AI creates comprehensive implementation plan
3. **Execute PRP** → AI implements with validation loops

## Architecture
- `.cursor/` - Cursor IDE configuration
- `PRPs/templates/` - PRP templates for feature requests
- `examples/` - Code examples for AI context
- `use-cases/` - Specialized templates for different AI app types

## Code Standards
- **Max 500 lines per file** - split into modules when approaching
- **Use environment variables** for secrets via `.env` files
- **Tests required** in `/tests` folder

## Validation Requirements
Every implementation must include executable validation:
- Python: `ruff check --fix && mypy . && pytest tests/ -v`
- TypeScript: `npm run type-check && npm test`

## Design Principles
- **KISS** - Choose straightforward solutions over complex ones
- **YAGNI** - Implement features only when needed
- **Context is King** - Include ALL necessary documentation in PRPs
CURSORRULES_EOF
    
    echo -e "   ${CHECK} ${GREEN}Created .cursorrules${NC}"
fi
echo ""

# Check .cursor directory
if [ -d "${SCRIPT_DIR}/.cursor" ]; then
    echo -e "${CHECK} ${GREEN}.cursor/ directory exists${NC}"
else
    echo -e "${WARN} ${YELLOW}.cursor/ directory not found${NC}"
    mkdir -p "${SCRIPT_DIR}/.cursor"
    echo -e "   ${CHECK} Created .cursor/ directory"
fi

# Check .cursor/settings.json
if [ -f "${SCRIPT_DIR}/.cursor/settings.json" ]; then
    echo -e "${CHECK} ${GREEN}.cursor/settings.json exists${NC}"
    
    # Verify JSON is valid
    if python3 -c "import json; json.load(open('${SCRIPT_DIR}/.cursor/settings.json'))" 2>/dev/null; then
        echo -e "   ${CHECK} JSON syntax is valid"
    else
        echo -e "   ${CROSS} ${RED}Invalid JSON syntax${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${WARN} ${YELLOW}.cursor/settings.json not found${NC}"
    echo -e "   ${INFO} Creating default settings..."
    
    cat > "${SCRIPT_DIR}/.cursor/settings.json" << 'SETTINGS_EOF'
{
    "cursor.chat.enableAgent": true,
    "cursor.composer.enabled": true,
    "cursor.chat.enablePrompts": true,
    "editor.formatOnSave": true,
    "editor.defaultFormatter": null,
    "[python]": {
        "editor.defaultFormatter": "charliermarsh.ruff",
        "editor.formatOnSave": true
    },
    "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.formatOnSave": true
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.formatOnSave": true
    }
}
SETTINGS_EOF
    
    echo -e "   ${CHECK} ${GREEN}Created .cursor/settings.json${NC}"
fi

# Check .cursor/prompts directory (slash commands) - verify all commands including validate-project for IDE parity
CURSOR_REQUIRED_PROMPTS=(
    "new-project.md"
    "generate-prp.md"
    "execute-prp.md"
    "build-prp.md"
    "generate-prompt.md"
    "validate-project.md"
    "validate.md"
    "generate-validate.md"
)
if [ -d "${SCRIPT_DIR}/.cursor/prompts" ]; then
    echo -e "${CHECK} ${GREEN}.cursor/prompts/ directory exists${NC}"
    MISSING_PROMPTS=0
    for prompt_file in "${CURSOR_REQUIRED_PROMPTS[@]}"; do
        if [ -f "${SCRIPT_DIR}/.cursor/prompts/${prompt_file}" ]; then
            echo -e "   ${CHECK} /${prompt_file%.md}"
        else
            echo -e "   ${CROSS} ${prompt_file} missing"
            ((MISSING_PROMPTS++))
            ((WARNINGS++))
        fi
    done
    if [ "$MISSING_PROMPTS" -eq 0 ]; then
        echo -e "   ${INFO} All slash commands present including validate-project (parity with Claude & VS Code)"
    fi
else
    echo -e "${WARN} ${YELLOW}.cursor/prompts/ directory not found${NC}"
    echo -e "   ${INFO} Slash commands not available (create .cursor/prompts/*.md)"
    ((WARNINGS++))
fi
echo ""

# =============================================================================
# Phase 3: Verify PRP Templates
# =============================================================================
echo -e "${CYAN}Phase 3: Verifying PRP Templates...${NC}"
echo "─────────────────────────────────────────────────────────────────"

# Check for PRP templates
TEMPLATE_COUNT=0
if [ -d "${SCRIPT_DIR}/PRPs/templates" ]; then
    TEMPLATE_COUNT=$(find "${SCRIPT_DIR}/PRPs/templates" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$TEMPLATE_COUNT" -gt 0 ]; then
    echo -e "${CHECK} ${GREEN}Found ${TEMPLATE_COUNT} PRP template(s)${NC}"
    find "${SCRIPT_DIR}/PRPs/templates" -name "*.md" 2>/dev/null | while read -r template; do
        echo -e "   ${INFO} $(basename "$template")"
    done
else
    echo -e "${WARN} ${YELLOW}No PRP templates found in PRPs/templates/${NC}"
    ((WARNINGS++))
fi

# Check for INITIAL.md
if [ -f "${SCRIPT_DIR}/INITIAL.md" ]; then
    echo -e "${CHECK} ${GREEN}INITIAL.md exists (requirements template)${NC}"
else
    echo -e "${INFO} No INITIAL.md found (create one to start a new feature)"
fi
echo ""

# =============================================================================
# Phase 4: Check Use Cases
# =============================================================================
echo -e "${CYAN}Phase 4: Checking Available Use Cases...${NC}"
echo "─────────────────────────────────────────────────────────────────"

USE_CASES=("pydantic-ai" "mcp-server" "agent-factory-with-subagents" "template-generator" "ai-coding-workflows-foundation")
AVAILABLE_CASES=0

for use_case in "${USE_CASES[@]}"; do
    USE_CASE_DIR="${SCRIPT_DIR}/use-cases/${use_case}"
    if [ -d "$USE_CASE_DIR" ]; then
        ((AVAILABLE_CASES++))
        
        # Check for use-case specific docs
        HAS_README=""
        HAS_CLAUDE=""
        [ -f "${USE_CASE_DIR}/README.md" ] && HAS_README="README"
        [ -f "${USE_CASE_DIR}/CLAUDE.md" ] && HAS_CLAUDE="CLAUDE"
        
        DOCS=""
        [ -n "$HAS_README" ] && DOCS="$HAS_README"
        [ -n "$HAS_CLAUDE" ] && DOCS="${DOCS:+$DOCS, }$HAS_CLAUDE"
        
        echo -e "${CHECK} ${GREEN}${use_case}${NC}"
        [ -n "$DOCS" ] && echo -e "   ${INFO} Docs: ${DOCS}"
    fi
done

if [ "$AVAILABLE_CASES" -eq 0 ]; then
    echo -e "${WARN} ${YELLOW}No use cases found${NC}"
    ((WARNINGS++))
else
    echo ""
    echo -e "   ${INFO} Total: ${AVAILABLE_CASES} use case(s) available"
fi
echo ""

# =============================================================================
# Phase 5: Development Environment Check
# =============================================================================
echo -e "${CYAN}Phase 5: Checking Development Environment...${NC}"
echo "─────────────────────────────────────────────────────────────────"

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo -e "${CHECK} ${GREEN}Python: ${PYTHON_VERSION}${NC}"
else
    echo -e "${WARN} ${YELLOW}Python 3 not found (needed for pydantic-ai use case)${NC}"
    ((WARNINGS++))
fi

# Check uv (Python package manager)
if command -v uv &> /dev/null; then
    UV_VERSION=$(uv --version 2>&1 | head -n 1)
    echo -e "${CHECK} ${GREEN}uv: ${UV_VERSION}${NC}"
else
    echo -e "${INFO} uv not installed (recommended for Python projects)"
    echo -e "   ${INFO} Install: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version 2>&1)
    echo -e "${CHECK} ${GREEN}Node.js: ${NODE_VERSION}${NC}"
else
    echo -e "${WARN} ${YELLOW}Node.js not found (needed for mcp-server use case)${NC}"
    ((WARNINGS++))
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version 2>&1)
    echo -e "${CHECK} ${GREEN}npm: ${NPM_VERSION}${NC}"
else
    echo -e "${WARN} ${YELLOW}npm not found (needed for mcp-server use case)${NC}"
    ((WARNINGS++))
fi

# Check wrangler (Cloudflare CLI)
if command -v wrangler &> /dev/null; then
    WRANGLER_VERSION=$(wrangler --version 2>&1 | head -n 1)
    echo -e "${CHECK} ${GREEN}Wrangler: ${WRANGLER_VERSION}${NC}"
else
    echo -e "${INFO} Wrangler not installed (needed for Cloudflare Workers deployment)"
    echo -e "   ${INFO} Install: npm install -g wrangler"
fi
echo ""

# =============================================================================
# Summary
# =============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                         SUMMARY                               ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${CHECK} ${GREEN}All checks passed! Environment is ready.${NC}"
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${WARN} ${YELLOW}Setup complete with ${WARNINGS} warning(s)${NC}"
else
    echo -e "${CROSS} ${RED}Setup completed with ${ERRORS} error(s) and ${WARNINGS} warning(s)${NC}"
fi
echo ""

# =============================================================================
# Quick Start Guide
# =============================================================================
echo -e "${CYAN}${ROCKET} Quick Start Guide:${NC}"
echo ""
echo "  1. Open project in Cursor:"
echo -e "     ${GREEN}cursor ${SCRIPT_DIR}${NC}"
echo ""
echo "  2. Define your feature in INITIAL.md:"
echo -e "     ${GREEN}Edit INITIAL.md with your requirements${NC}"
echo ""
echo "  3. Use slash commands in Cursor chat:"
echo -e "     ${GREEN}/generate-prp INITIAL.md${NC}"
echo -e "     ${GREEN}/execute-prp PRPs/my-feature.md${NC}"
echo -e "     ${GREEN}/validate-project${NC}"
echo ""
echo "  4. Available slash commands:"
echo -e "     ${GREEN}/new-project${NC}       - Create new project from template"
echo -e "     ${GREEN}/generate-prp${NC}      - Create implementation plan"
echo -e "     ${GREEN}/execute-prp${NC}       - Implement from PRP"
echo -e "     ${GREEN}/build-prp${NC}         - Finalize PRP, then optionally build and run"
echo -e "     ${GREEN}/generate-prompt${NC}   - Create XML-structured prompt"
echo -e "     ${GREEN}/validate-project${NC}   - Run project validation (from /generate-validate)"
echo -e "     ${GREEN}/validate${NC}          - Run template validation (this repo only)"
echo -e "     ${GREEN}/generate-validate${NC} - Create /validate-project for your project (all 3 IDEs)"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${INFO} For more information, see:"
echo -e "   • ${CYAN}README.md${NC} - Project overview"
echo -e "   • ${CYAN}.cursor/README.md${NC} - Cursor-specific documentation"
echo -e "   • ${CYAN}PRPs/templates/prp_base.md${NC} - PRP template reference"
echo ""

exit $ERRORS
