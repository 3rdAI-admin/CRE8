#!/bin/bash
# ============================================================================
# Claude Code Setup Script for Context Engineering Template
# ============================================================================
# This script verifies and configures Claude Code for the Context Engineering
# workflow with slash commands (/generate-prp, /execute-prp)
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script
BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Default to parent of bin/ if no argument provided
DEFAULT_DIR="$(dirname "$BIN_DIR")"

# Target Directory from argument or default
TARGET_DIR="${1:-$DEFAULT_DIR}"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Context Engineering - Claude Code Setup${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Target: $TARGET_DIR${NC}"
echo ""

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory '$TARGET_DIR' does not exist.${NC}"
    exit 1
fi

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
echo -e "${YELLOW}Step 2: Verifying project structure in $TARGET_DIR...${NC}"

# Check required directories exist
REQUIRED_DIRS=(
    ".claude/commands"
    "PRPs/templates"
    "examples"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$TARGET_DIR/$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir exists"
    else
        echo -e "  ${YELLOW}!${NC} Creating $dir..."
        mkdir -p "$TARGET_DIR/$dir"
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
    # ".claude/settings.local.json" # Checked separately next
    "CLAUDE.md"
    "INITIAL.md"
    "PRPs/templates/prp_base.md"
)

ALL_FILES_EXIST=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        # Only warn if files are missing, as they might not be part of new project template yet
        # But if we just created a project, they should be there.
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

SETTINGS_FILE="$TARGET_DIR/.claude/settings.local.json"

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
    mkdir -p "$TARGET_DIR/.claude"
    # We write to the TARGET_DIR
    cat > "$SETTINGS_FILE" << 'JSONEOF'
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
JSONEOF
    echo -e "  ${GREEN}✓${NC} Created default settings.local.json"
fi

# ----------------------------------------------------------------------------
# Step 5: Verify CLAUDE.md exists
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 5: Checking CLAUDE.md...${NC}"

if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo -e "  ${GREEN}✓${NC} CLAUDE.md found"
    # Show first line as preview
    FIRST_LINE=$(head -1 "$TARGET_DIR/CLAUDE.md" | tr -d '#' | xargs)
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
echo -e "${YELLOW}Usage:${NC}"
echo ""
echo "  1. Open this project in your terminal"
echo "  2. Run Claude Code:"
echo "     ${BLUE}claude${NC}"
echo ""
echo "  3. Use slash commands:"
echo "     ${BLUE}/generate-prp INITIAL.md${NC}"
echo "     ${BLUE}/execute-prp PRPs/feature.md${NC}"
echo ""
echo -e "${GREEN}Happy coding with Context Engineering! 🚀${NC}"
