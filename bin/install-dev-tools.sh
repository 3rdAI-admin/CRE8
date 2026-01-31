#!/bin/bash
# Install development tools for Context Engineering Template
# Usage: ./install-dev-tools.sh [--uv]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Symbols
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
ARROW="${BLUE}→${NC}"
INFO="${BLUE}ℹ${NC}"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Context Engineering Dev Tools Installer  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo -e "${CROSS} Python 3 not found. Please install Python 3.11+ first."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${CHECK} Python $PYTHON_VERSION found"

# Determine installation method
USE_UV=false
if [ "$1" == "--uv" ] || command -v uv &> /dev/null; then
    USE_UV=true
    if ! command -v uv &> /dev/null; then
        echo -e "${INFO} Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    fi
    echo -e "${CHECK} Using uv for package management"
else
    echo -e "${CHECK} Using pip for package management"
fi

echo ""
echo -e "${ARROW} Installing development tools..."
echo ""

# Install packages: prefer uv (creates .venv without ensurepip) when available
if [ "$USE_UV" == true ]; then
    if [ -f "pyproject.toml" ]; then
        echo -e "${INFO} Using uv (pyproject.toml)..."
        uv venv
        uv sync --extra dev
        echo -e "${CHECK} .venv created and dev dependencies installed"
    else
        echo -e "${INFO} Installing from requirements-dev.txt..."
        uv venv
        uv pip install -r requirements-dev.txt --python .venv/bin/python
    fi
else
    # Create venv if missing or broken (pip path)
    if [ ! -d ".venv" ] || [ ! -f ".venv/bin/pip" ]; then
        if [ -d ".venv" ]; then
            echo -e "${INFO} Removing incomplete .venv..."
            rm -rf .venv
        fi
        echo -e "${ARROW} Creating .venv..."
        python3 -m venv .venv
        echo -e "${CHECK} .venv created"
    fi
    echo -e "${INFO} Installing from requirements-dev.txt..."
    if [ -f ".venv/bin/pip" ]; then
        .venv/bin/pip install -r requirements-dev.txt
    else
        python3 -m pip install -r requirements-dev.txt
    fi
fi

echo ""
echo -e "${CHECK} ${GREEN}Development tools installed successfully!${NC}"
echo ""

# Install pre-commit hooks
echo -e "${ARROW} Setting up pre-commit hooks..."
if pre-commit install; then
    echo -e "${CHECK} Pre-commit hooks installed"
else
    echo -e "${CROSS} Failed to install pre-commit hooks"
fi

if pre-commit install --hook-type commit-msg; then
    echo -e "${CHECK} Commit message hooks installed"
else
    echo -e "${CROSS} Failed to install commit message hooks"
fi

echo ""
echo -e "${CHECK} ${GREEN}Installation complete!${NC}"
echo ""

# Summary of installed tools
echo -e "${BLUE}Installed tools:${NC}"
echo -e "  ${CHECK} ruff       - Python linter & formatter"
echo -e "  ${CHECK} mypy       - Static type checker"
echo -e "  ${CHECK} pytest     - Test framework"
echo -e "  ${CHECK} pre-commit - Git hooks framework"
echo -e "  ${CHECK} ipython    - Enhanced Python REPL"
echo -e "  ${CHECK} rich       - Beautiful terminal output"
echo ""

# Next steps
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Activate venv:     ${YELLOW}source .venv/bin/activate${NC} (if you created one)"
echo -e "  2. Full validation:   ${YELLOW}/validate-project --thorough${NC}"
echo -e "  3. Test pre-commit:   ${YELLOW}pre-commit run --all-files${NC}"
echo -e "  4. Check formatting:  ${YELLOW}ruff format .${NC}"
echo -e "  5. Run tests:         ${YELLOW}pytest use-cases/pydantic-ai use-cases/agent-factory-with-subagents${NC}"
echo ""

# Install MCP server dependencies if requested
read -p "Install MCP server dependencies? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${ARROW} Installing MCP server dependencies..."
    if [ -d "use-cases/mcp-server" ]; then
        cd use-cases/mcp-server
        if command -v npm &> /dev/null; then
            npm install
            echo -e "${CHECK} MCP server dependencies installed"
        else
            echo -e "${CROSS} npm not found. Install Node.js first."
        fi
        cd "$SCRIPT_DIR"
    else
        echo -e "${CROSS} use-cases/mcp-server not found"
    fi
fi

echo ""
echo -e "${GREEN}All done! Happy coding! 🚀${NC}"
