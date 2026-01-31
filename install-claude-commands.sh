#!/bin/bash
# ============================================================================
# Install Claude Code slash commands (commands + skills) into a project
# ============================================================================
# Run this FROM the context-engineering template repo to copy the 7 slash
# commands into another project (e.g. one created with /new-project earlier,
# or any project where you want the / menu to show generate-prp, build-prp, etc.).
#
# Usage (from context-engineering repo):
#   ./install-claude-commands.sh                    # prompts for install path
#   ./install-claude-commands.sh /path/to/project   # install into given path
# ============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install path: from argument or prompt
if [ -n "$1" ]; then
    TARGET="$1"
else
    echo -e "${BLUE}Install Claude Code slash commands into a project${NC}"
    echo ""
    echo "Enter the full path to the project (or . for current directory):"
    read -r -e TARGET
    TARGET="${TARGET:-.}"
fi

TARGET_DIR="$(cd "$TARGET" && pwd)"

if [ "$TARGET_DIR" = "$SCRIPT_DIR" ]; then
    echo -e "${YELLOW}Target is the template repo; .claude is already here.${NC}"
    echo "Run this script with the path to a different project, e.g.:"
    echo "  $0 /Users/james/AI_Dev/Context_Tutorial"
    exit 0
fi

echo -e "${BLUE}Installing Claude Code slash commands into: $TARGET_DIR${NC}"
echo ""

mkdir -p "$TARGET_DIR/.claude"

# Copy commands (full instruction files)
if [ -d "$SCRIPT_DIR/.claude/commands" ]; then
    echo -e "${GREEN}Copying .claude/commands/ ...${NC}"
    rm -rf "$TARGET_DIR/.claude/commands"
    cp -r "$SCRIPT_DIR/.claude/commands" "$TARGET_DIR/.claude/"
    echo "  ✓ commands/"
else
    echo -e "${YELLOW}  No .claude/commands in template; skipping.${NC}"
fi

# Copy skills (so / shows all commands in chat, including validate-project)
if [ -d "$SCRIPT_DIR/.claude/skills" ]; then
    echo -e "${GREEN}Copying .claude/skills/ ...${NC}"
    rm -rf "$TARGET_DIR/.claude/skills"
    cp -r "$SCRIPT_DIR/.claude/skills" "$TARGET_DIR/.claude/"
    echo "  ✓ skills/"
else
    echo -e "${YELLOW}  No .claude/skills in template; skipping.${NC}"
fi

# Optional: copy settings if target doesn't have any
if [ ! -f "$TARGET_DIR/.claude/settings.local.json" ] && [ -f "$SCRIPT_DIR/.claude/settings.local.json" ]; then
    cp "$SCRIPT_DIR/.claude/settings.local.json" "$TARGET_DIR/.claude/"
    echo -e "  ${GREEN}✓ settings.local.json (created)${NC}"
fi

echo ""
echo -e "${GREEN}Done. Slash commands are now in $TARGET_DIR/.claude/${NC}"
echo ""
echo "Next:"
echo "  1. Open that project in Claude Code:  claude $TARGET_DIR"
echo "  2. Restart Claude Code (Cmd+Q, then reopen) so it rescans .claude/skills/"
echo "  3. In chat, type / to see: new-project, generate-prp, execute-prp, build-prp, generate-prompt, validate-project, validate, generate-validate"
echo ""
