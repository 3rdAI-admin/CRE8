#!/bin/bash

# =============================================================================
# Context Engineering Template - Cursor IDE Setup Script
# =============================================================================
# This script verifies and sets up the Cursor IDE environment for the
# Context Engineering workflow with PRPs (Product Requirements Prompts).
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

# Get the directory of this script
BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Default to parent of bin/ if no argument provided
DEFAULT_DIR="$(dirname "$BIN_DIR")"

# Target Directory from argument or default
TARGET_DIR="${1:-$DEFAULT_DIR}"

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ${CYAN}Context Engineering - Cursor IDE Setup${BLUE}                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo -e "${BLUE}      Target: $TARGET_DIR${NC}"
echo ""

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory '$TARGET_DIR' does not exist.${NC}"
    exit 1
fi

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
echo -e "${CYAN}Phase 2: Verifying Project Structure in $TARGET_DIR...${NC}"
echo "─────────────────────────────────────────────────────────────────"

# Check .cursorrules file
if [ -f "${TARGET_DIR}/.cursorrules" ]; then
    RULES_LINES=$(wc -l < "${TARGET_DIR}/.cursorrules" | tr -d ' ')
    RULES_SIZE=$(stat -f%z "${TARGET_DIR}/.cursorrules" 2>/dev/null || stat -c%s "${TARGET_DIR}/.cursorrules" 2>/dev/null)
    echo -e "${CHECK} ${GREEN}.cursorrules exists${NC}"
    echo -e "   ${INFO} Lines: ${RULES_LINES}, Size: ${RULES_SIZE} bytes"
    
    # Check file encoding
    FILE_TYPE=$(file "${TARGET_DIR}/.cursorrules" | cut -d: -f2)
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
    cat > "${TARGET_DIR}/.cursorrules" << 'CURSORRULES_EOF'
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
if [ -d "${TARGET_DIR}/.cursor" ]; then
    echo -e "${CHECK} ${GREEN}.cursor/ directory exists${NC}"
else
    echo -e "${WARN} ${YELLOW}.cursor/ directory not found${NC}"
    mkdir -p "${TARGET_DIR}/.cursor"
    echo -e "   ${CHECK} Created .cursor/ directory"
fi

# Check .cursor/settings.json
if [ -f "${TARGET_DIR}/.cursor/settings.json" ]; then
    echo -e "${CHECK} ${GREEN}.cursor/settings.json exists${NC}"
    
    # Verify JSON is valid
    # Note: we use bash variable expansion for the path inside the python script arg
    if python3 -c "import json; json.load(open('${TARGET_DIR}/.cursor/settings.json'))" 2>/dev/null; then
        echo -e "   ${CHECK} JSON syntax is valid"
    else
        echo -e "   ${CROSS} ${RED}Invalid JSON syntax${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${WARN} ${YELLOW}.cursor/settings.json not found${NC}"
    echo -e "   ${INFO} Creating default settings..."
    
    cat > "${TARGET_DIR}/.cursor/settings.json" << 'SETTINGS_EOF'
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
if [ -d "${TARGET_DIR}/.cursor/prompts" ]; then
    echo -e "${CHECK} ${GREEN}.cursor/prompts/ directory exists${NC}"
    MISSING_PROMPTS=0
    for prompt_file in "${CURSOR_REQUIRED_PROMPTS[@]}"; do
        if [ -f "${TARGET_DIR}/.cursor/prompts/${prompt_file}" ]; then
            echo -e "   ${CHECK} /${prompt_file%.md}"
        else
            echo -e "   ${CROSS} ${prompt_file} missing"
            ((MISSING_PROMPTS++))
            ((WARNINGS++))
        fi
    done
    if [ "$MISSING_PROMPTS" -eq 0 ]; then
        echo -e "   ${CHECK} ${GREEN}All prompts present${NC}"
    fi
else
    echo -e "${WARN} ${YELLOW}.cursor/prompts/ directory not found${NC}"
    mkdir -p "${TARGET_DIR}/.cursor/prompts"
    # Copy prompts if we can find source? 
    # create-project.sh usually handles this. If missing, we might not be able to fix it easily without source location.
    # But usually this script runs inside the template or a created project.
    echo -e "   ${CHECK} Created .cursor/prompts/ directory (empty)"
fi

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${BLUE}============================================${NC}"
