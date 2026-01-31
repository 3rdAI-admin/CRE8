#!/bin/bash
# ============================================================================
# VS Code Setup Script for Context Engineering Template
# ============================================================================
# This script installs VS Code extensions and configures settings for
# GitHub Copilot prompt commands (/generate-prp, /execute-prp, /validate-project, etc.)
#
# Original Creator: Cole Medin (https://github.com/coleam00)
# Repository: https://github.com/coleam00/Context-Engineering-Intro
# License: MIT
#
# Contributor: James Avila (https://th3rdai.com)
#
# Usage: ./SETUP-VSCODE.sh
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
echo -e "${BLUE}  Context Engineering - VS Code Setup${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ----------------------------------------------------------------------------
# Step 1: Check if VS Code CLI is available
# ----------------------------------------------------------------------------
echo -e "${YELLOW}Step 1: Checking VS Code installation...${NC}"

if command -v code &> /dev/null; then
    echo -e "${GREEN}✓ VS Code CLI found${NC}"
else
    echo -e "${RED}✗ VS Code CLI not found${NC}"
    echo ""
    echo "Please install VS Code and ensure 'code' command is available:"
    echo "  1. Install VS Code from https://code.visualstudio.com/"
    echo "  2. Open VS Code"
    echo "  3. Press Cmd+Shift+P (macOS) or Ctrl+Shift+P (Windows/Linux)"
    echo "  4. Type 'Shell Command: Install code command in PATH'"
    echo ""
    exit 1
fi

# ----------------------------------------------------------------------------
# Step 2: Install required extensions
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 2: Installing GitHub Copilot extensions...${NC}"

# List of required extensions
EXTENSIONS=(
    "GitHub.copilot"
    "GitHub.copilot-chat"
)

for ext in "${EXTENSIONS[@]}"; do
    echo -n "  Installing $ext... "
    if code --install-extension "$ext" --force &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}(may already be installed or requires login)${NC}"
    fi
done

# ----------------------------------------------------------------------------
# Step 3: Verify project structure
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 3: Verifying project structure...${NC}"

# Check required directories exist
REQUIRED_DIRS=(
    ".github/prompts"
    ".vscode"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir exists"
    else
        echo -e "  ${YELLOW}!${NC} Creating $dir..."
        mkdir -p "$SCRIPT_DIR/$dir"
    fi
done

# Check required files exist (all commands for parity with Claude/Cursor)
REQUIRED_FILES=(
    ".github/prompts/new-project.prompt.md"
    ".github/prompts/generate-prp.prompt.md"
    ".github/prompts/execute-prp.prompt.md"
    ".github/prompts/build-prp.prompt.md"
    ".github/prompts/generate-prompt.prompt.md"
    ".github/prompts/validate-project.prompt.md"
    ".github/prompts/validate.prompt.md"
    ".github/prompts/generate-validate.prompt.md"
    ".github/copilot-instructions.md"
    ".vscode/settings.json"
)

echo ""
echo -e "${YELLOW}Step 4: Verifying prompt files...${NC}"

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file (missing!)"
    fi
done

# ----------------------------------------------------------------------------
# Step 5: Verify settings.json has correct configuration
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 5: Checking VS Code settings...${NC}"

SETTINGS_FILE="$SCRIPT_DIR/.vscode/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    # Check for key settings
    if grep -q '"chat.promptFiles"' "$SETTINGS_FILE"; then
        echo -e "  ${GREEN}✓${NC} chat.promptFiles configured"
    else
        echo -e "  ${RED}✗${NC} chat.promptFiles not found in settings"
    fi
    
    if grep -q '"github.copilot.chat.codeGeneration.useInstructionFiles"' "$SETTINGS_FILE"; then
        echo -e "  ${GREEN}✓${NC} useInstructionFiles configured"
    else
        echo -e "  ${YELLOW}!${NC} useInstructionFiles not configured (optional)"
    fi
    
    if grep -q '"chat.agent.enabled"' "$SETTINGS_FILE"; then
        echo -e "  ${GREEN}✓${NC} chat.agent.enabled configured"
    else
        echo -e "  ${YELLOW}!${NC} chat.agent.enabled not configured (optional)"
    fi
else
    echo -e "  ${RED}✗${NC} settings.json not found"
    echo "  Creating default settings..."
    cat > "$SETTINGS_FILE" << 'EOF'
{
  // VS Code Copilot Settings for Context Engineering Template
  // These settings optimize the Copilot experience for this project
  
  // Enable prompt files as slash commands
  "chat.promptFiles": true,
  
  // Recommended: Include workspace instructions automatically
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  
  // Recommended: Better context from open files
  "github.copilot.chat.localeOverride": "en",
  
  // Recommended: Agent mode for complex tasks
  "chat.agent.enabled": true
}
EOF
    echo -e "  ${GREEN}✓${NC} Created default settings.json"
fi

# ----------------------------------------------------------------------------
# Step 6: Display available commands
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
echo "  1. Open this project in VS Code:"
echo "     ${BLUE}code $SCRIPT_DIR${NC}"
echo ""
echo "  2. Open Copilot Chat:"
echo "     ${BLUE}Cmd+Shift+I${NC} (macOS) or ${BLUE}Ctrl+Shift+I${NC} (Windows/Linux)"
echo ""
echo "  3. Type ${BLUE}/${NC} to see available commands"
echo ""
echo "  4. Try a command:"
echo "     ${BLUE}/generate-prp INITIAL.md${NC}"
echo ""
echo -e "${YELLOW}Workflow:${NC}"
echo ""
echo "  1. Define requirements in INITIAL.md"
echo "  2. Run: /generate-prp INITIAL.md"
echo "  3. Review generated PRP in PRPs/ folder"
echo "  4. Run: /execute-prp PRPs/feature-name.md"
echo "  5. Run: /validate-project to verify implementation"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo ""
echo "  - .vscode/README.md - Detailed VS Code setup guide"
echo "  - .github/prompts/README.md - Command documentation"
echo "  - .github/copilot-instructions.md - AI coding rules"
echo ""
echo -e "${GREEN}Happy coding with Context Engineering! 🚀${NC}"
