#!/bin/bash
# ============================================================================
# Claude Code Setup Script for Context Engineering Template
# ============================================================================
# This script verifies and configures Claude Code for the Context Engineering
# workflow with slash commands (/generate-prp, /execute-prp)
#
# Original Creator: Cole Medin (https://github.com/coleam00)
# Repository: https://github.com/coleam00/Context-Engineering-Intro
# License: MIT
#
# Contributor: James Avila (https://th3rdai.com)
#
# Usage: ./SETUP-CLAUDE.sh
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Context Engineering - Claude Code Setup${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ----------------------------------------------------------------------------
# Step 1: Check if Claude Code CLI is available
# ----------------------------------------------------------------------------
echo -e "${YELLOW}Step 1: Checking Claude Code installation...${NC}"

if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓ Claude Code CLI found${NC}"
    claude --version 2>/dev/null || true
else
    echo -e "${RED}✗ Claude Code CLI not found${NC}"
    echo ""
    echo "Please install Claude Code:"
    echo "  1. Visit https://claude.ai/code"
    echo "  2. Download and install Claude Code for your platform"
    echo "  3. Run this script again"
    echo ""
    echo "Alternatively, install via npm:"
    echo "  npm install -g @anthropic-ai/claude-code"
    echo ""
    exit 1
fi

# ----------------------------------------------------------------------------
# Step 2: Verify project structure
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 2: Verifying project structure...${NC}"

# Check required directories exist
REQUIRED_DIRS=(
    ".claude/commands"
    "PRPs/templates"
    "examples"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir exists"
    else
        echo -e "  ${YELLOW}!${NC} Creating $dir..."
        mkdir -p "$SCRIPT_DIR/$dir"
    fi
done

# ----------------------------------------------------------------------------
# Step 3: Verify command files exist
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 3: Verifying slash command files...${NC}"

REQUIRED_FILES=(
    ".claude/commands/new-project.md"
    ".claude/commands/generate-prp.md"
    ".claude/commands/execute-prp.md"
    ".claude/commands/build-prp.md"
    ".claude/commands/generate-prompt.md"
    ".claude/commands/validate-project.md"
    ".claude/commands/validate.md"
    ".claude/commands/generate-validate.md"
    ".claude/settings.local.json"
    "CLAUDE.md"
    "INITIAL.md"
    "PRPs/templates/prp_base.md"
)

ALL_FILES_EXIST=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file (missing!)"
        ALL_FILES_EXIST=false
    fi
done

if [ "$ALL_FILES_EXIST" = false ]; then
    echo -e "${YELLOW}⚠ Some files are missing. Setup can continue but may be incomplete.${NC}"
fi

# ----------------------------------------------------------------------------
# Step 4: Verify settings.local.json has correct permissions
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 4: Checking Claude Code settings...${NC}"

SETTINGS_FILE="$SCRIPT_DIR/.claude/settings.local.json"

if [ -f "$SETTINGS_FILE" ]; then
    # Check for key permissions
    if grep -q '"permissions"' "$SETTINGS_FILE"; then
        echo -e "  ${GREEN}✓${NC} Permissions configured"
    else
        echo -e "  ${RED}✗${NC} Permissions not found in settings"
    fi
    
    if grep -q 'Bash(python' "$SETTINGS_FILE"; then
        echo -e "  ${GREEN}✓${NC} Python execution allowed"
    else
        echo -e "  ${YELLOW}!${NC} Python execution not configured"
    fi
    
    if grep -q 'Bash(pytest' "$SETTINGS_FILE"; then
        echo -e "  ${GREEN}✓${NC} Pytest execution allowed"
    else
        echo -e "  ${YELLOW}!${NC} Pytest execution not configured"
    fi
    
    if grep -q 'WebFetch' "$SETTINGS_FILE"; then
        echo -e "  ${GREEN}✓${NC} Web fetch permissions configured"
    else
        echo -e "  ${YELLOW}!${NC} Web fetch not configured (optional)"
    fi
else
    echo -e "  ${RED}✗${NC} settings.local.json not found"
    echo "  Creating default settings..."
    mkdir -p "$SCRIPT_DIR/.claude"
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(grep:*)",
      "Bash(ls:*)",
      "Bash(source:*)",
      "Bash(find:*)",
      "Bash(mv:*)",
      "Bash(mkdir:*)",
      "Bash(tree:*)",
      "Bash(ruff:*)",
      "Bash(touch:*)",
      "Bash(cat:*)",
      "Bash(ruff check:*)",
      "Bash(pytest:*)",
      "Bash(python:*)",
      "Bash(python -m pytest:*)",
      "Bash(python3 -m pytest:*)",
      "WebFetch(domain:docs.anthropic.com)",
      "WebFetch(domain:github.com)"
    ],
    "deny": []
  }
}
EOF
    echo -e "  ${GREEN}✓${NC} Created default settings.local.json"
fi

# ----------------------------------------------------------------------------
# Step 5: Verify CLAUDE.md exists
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 5: Checking CLAUDE.md...${NC}"

if [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
    echo -e "  ${GREEN}✓${NC} CLAUDE.md found"
    # Show first line as preview
    FIRST_LINE=$(head -1 "$SCRIPT_DIR/CLAUDE.md" | tr -d '#' | xargs)
    echo -e "  ${BLUE}→${NC} $FIRST_LINE"
else
    echo -e "  ${RED}✗${NC} CLAUDE.md not found"
    echo "  This file contains global rules for the AI assistant."
fi

# ----------------------------------------------------------------------------
# Step 6: Display available commands and usage
# ----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${YELLOW}Available Slash Commands:${NC}"
echo ""
echo "  /new-project       - Create new project from template"
echo "  /generate-prp      - Create comprehensive PRP from INITIAL.md"
echo "  /execute-prp       - Implement feature from PRP with validation"
echo "  /build-prp         - Finalize PRP, then optionally build and run"
echo "  /generate-prompt   - Create XML-structured prompt (standalone)"
echo "  /validate-project  - Run project validation (from /generate-validate)"
echo "  /validate          - Run template validation (this repo only)"
echo "  /generate-validate - Create /validate-project for your project (all 3 IDEs)"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo ""
echo "  1. Open this project in Claude Code:"
echo "     ${BLUE}cd $SCRIPT_DIR && claude${NC}"
echo ""
echo "  2. Create your feature request:"
echo "     Edit ${BLUE}INITIAL.md${NC} with your requirements"
echo ""
echo "  3. Generate a PRP:"
echo "     ${BLUE}/generate-prp INITIAL.md${NC}"
echo ""
echo "  4. Execute the PRP:"
echo "     ${BLUE}/execute-prp PRPs/your-feature-name.md${NC}"
echo ""
echo -e "${YELLOW}Workflow:${NC}"
echo ""
echo "  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐"
echo "  │   INITIAL.md    │────▶│  /generate-prp  │────▶│  PRPs/feature.md│"
echo "  │  (requirements) │     │   (research &   │     │  (comprehensive │"
echo "  │                 │     │    planning)    │     │   impl guide)   │"
echo "  └─────────────────┘     └─────────────────┘     └────────┬────────┘"
echo "                                                           │"
echo "                                                           ▼"
echo "  ┌─────────────────┐                             ┌─────────────────┐"
echo "  │    Complete!    │◀────────────────────────────│   /execute-prp  │"
echo "  │                 │                             │  (implement &   │"
echo "  │                 │                             │ validate-project)│"
echo "  └─────────────────┘                             └─────────────────┘"
echo ""
echo -e "${YELLOW}Use Cases:${NC}"
echo ""
echo "  This template includes specialized configurations for:"
echo "  • ${BLUE}use-cases/pydantic-ai/${NC}     - PydanticAI agent development"
echo "  • ${BLUE}use-cases/mcp-server/${NC}      - Cloudflare Workers MCP servers"
echo "  • ${BLUE}use-cases/agent-factory/${NC}   - Multi-agent orchestration"
echo "  • ${BLUE}use-cases/template-generator/${NC} - Create new templates"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo ""
echo "  - CLAUDE.md - Global AI coding rules"
echo "  - PRPs/EXAMPLE_multi_agent_prp.md - Example PRP"
echo "  - README.md - Full documentation"
echo ""
echo -e "${GREEN}Happy coding with Context Engineering! 🚀${NC}"
