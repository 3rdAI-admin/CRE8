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
# Usage: ./bin/setup-vscode.sh [target-directory]
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the project root (parent of bin/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Context Engineering - VS Code Setup${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ----------------------------------------------------------------------------
# Step 0: Determine Target Directory
# ----------------------------------------------------------------------------
if [ -n "$1" ]; then
    TARGET_DIR="$1"
    echo -e "${YELLOW}Target directory provided: $TARGET_DIR${NC}"
else
    echo -e "${YELLOW}Where would you like to set up the environment?${NC}"
    echo "1) Configure current directory ($SCRIPT_DIR)"
    echo "2) Create and configure a new project"
    read -p "Select option (1/2): " setup_choice

    if [[ "$setup_choice" == "2" ]]; then
        read -p "Enter path for new project (e.g. ~/projects/my-app): " entered_path
        
        # Expand tilde manually
        TARGET_DIR="${entered_path/#\~/$HOME}"
        
        if [ -z "$TARGET_DIR" ]; then
            echo -e "${RED}Error: path is required.${NC}"
            exit 1
        fi

        # Run create-project.sh
        echo -e "${YELLOW}Running project creation script...${NC}"
        if [ -f "$SCRIPT_DIR/bin/create-project.sh" ]; then
            # Pass --vscode flag explicitly
            "$SCRIPT_DIR/bin/create-project.sh" "$TARGET_DIR" --vscode
        else
            echo -e "${RED}Error: create-project.sh not found at $SCRIPT_DIR/bin/create-project.sh${NC}"
            exit 1
        fi
    else
        TARGET_DIR="$SCRIPT_DIR"
    fi
fi

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
# Step 3: Verify project structure in Target Directory
# ----------------------------------------------------------------------------
echo ""
echo -e "${YELLOW}Step 3: Verifying project structure in $TARGET_DIR...${NC}"

# Check required directories exist
REQUIRED_DIRS=(
    ".github/prompts"
    ".vscode"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$TARGET_DIR/$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir exists"
    else
        echo -e "  ${YELLOW}!${NC} Creating $dir..."
        mkdir -p "$TARGET_DIR/$dir"
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
    if [ -f "$TARGET_DIR/$file" ]; then
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

SETTINGS_FILE="$TARGET_DIR/.vscode/settings.json"

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
fi

echo ""
echo -e "${GREEN}VS Code setup complete!${NC}"
echo "Open VS Code and try using slash commands in GitHub Copilot Chat."
