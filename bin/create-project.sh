#!/bin/bash
# create-project.sh - Create a new project from the context-engineering template
#
# Usage: ./create-project.sh <project-path> [--vscode|--claude|--cursor|--all]
#
# Flags:
#   --vscode    Copy only VS Code & GitHub Copilot files (.github, .vscode)
#   --claude    Copy only Claude Code files (.claude)
#   --cursor    Copy only Cursor files (.cursor, .cursorrules)
#   --all       Copy all IDE configurations (default if no flag provided)
#
# Examples:
#   ./create-project.sh ~/projects/my-app              # All IDEs
#   ./create-project.sh ~/projects/my-app --vscode     # VS Code only
#   ./create-project.sh ~/projects/my-app --all        # All IDEs (explicit)

set -e

if [ -z "$1" ]; then
    echo "Usage: ./create-project.sh <project-path> [--vscode|--claude|--cursor|--all]"
    echo "Example: ./create-project.sh ~/projects/my-new-app --vscode"
    exit 1
fi

PROJECT_PATH="$1"
shift

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default: install all unless specified
INCLUDE_VSCODE=true
INCLUDE_CLAUDE=true
INCLUDE_CURSOR=true

# If flags are provided, start with false and enable only what's requested
if [[ "$1" == --* ]]; then
    INCLUDE_VSCODE=false
    INCLUDE_CLAUDE=false
    INCLUDE_CURSOR=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --vscode) INCLUDE_VSCODE=true; shift ;;
            --claude) INCLUDE_CLAUDE=true; shift ;;
            --cursor) INCLUDE_CURSOR=true; shift ;;
            --all) INCLUDE_VSCODE=true; INCLUDE_CLAUDE=true; INCLUDE_CURSOR=true; shift ;;
            *) echo "Unknown option: $1"; shift ;;
        esac
    done
fi


# Check if directory already exists
if [ -d "$PROJECT_PATH" ]; then
    echo "⚠️  Directory $PROJECT_PATH already exists."
    read -p "Do you want to continue and potentially overwrite existing files? (y/N) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Aborting."
        exit 1
    fi
    echo "⚠️  Proceeding with existing directory..."
fi

echo "📁 Creating project at $PROJECT_PATH..."

# Create the project directory
mkdir -p "$PROJECT_PATH"

# Copy template files
echo "📋 Copying template files..."
cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_PATH/"
cp "$SCRIPT_DIR/sync-commands.sh" "$PROJECT_PATH/" 2>/dev/null || true
cp "$SCRIPT_DIR/sync-commands.ps1" "$PROJECT_PATH/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.commands" "$PROJECT_PATH/" 2>/dev/null || true

# Copy IDE-specific files based on selection
if [ "$INCLUDE_VSCODE" = true ]; then
    echo "  - Copying VS Code & GitHub Copilot files..."
    cp -r "$SCRIPT_DIR/.github" "$PROJECT_PATH/" 2>/dev/null || true
    cp -r "$SCRIPT_DIR/.vscode" "$PROJECT_PATH/" 2>/dev/null || true
else
    echo "  - Removing VS Code/Copilot files (not selected)..."
    rm -rf "$PROJECT_PATH/.github" 2>/dev/null || true
    rm -rf "$PROJECT_PATH/.vscode" 2>/dev/null || true
fi

if [ "$INCLUDE_CLAUDE" = true ]; then
    echo "  - Copying Claude Code files..."
    cp -r "$SCRIPT_DIR/.claude" "$PROJECT_PATH/" 2>/dev/null || true
else
    echo "  - Removing Claude Code files (not selected)..."
    rm -rf "$PROJECT_PATH/.claude" 2>/dev/null || true
fi

if [ "$INCLUDE_CURSOR" = true ]; then
    echo "  - Copying Cursor files..."
    cp -r "$SCRIPT_DIR/.cursor" "$PROJECT_PATH/" 2>/dev/null || true
    cp "$SCRIPT_DIR/.cursorrules" "$PROJECT_PATH/" 2>/dev/null || true
else
    echo "  - Removing Cursor files (not selected)..."
    rm -rf "$PROJECT_PATH/.cursor" 2>/dev/null || true
    rm -f "$PROJECT_PATH/.cursorrules" 2>/dev/null || true
fi

# Create project structure
echo "📂 Creating project structure..."
mkdir -p "$PROJECT_PATH/PRPs/prompts"
mkdir -p "$PROJECT_PATH/PRPs/templates"
mkdir -p "$PROJECT_PATH/examples"
mkdir -p "$PROJECT_PATH/journal"
# Starter journal index for progress tracking (resume after restart or IDE shutdown)
echo "# Validation journal index" > "$PROJECT_PATH/journal/README.md"

# Copy PRP templates
cp -r "$SCRIPT_DIR/PRPs/templates/"* "$PROJECT_PATH/PRPs/templates/" 2>/dev/null || true

# Create empty INITIAL.md
cat > "$PROJECT_PATH/INITIAL.md" << 'EOF'
## FEATURE:
[Describe what you want to build - be specific about functionality and requirements]

## EXAMPLES:
[List any example files in the examples/ folder and explain how they should be used]

## DOCUMENTATION:
[Include links to relevant documentation, APIs, or resources]

## OTHER CONSIDERATIONS:
[Mention any gotchas, specific requirements, or things AI assistants commonly miss]
EOF

# Create .gitignore
cat > "$PROJECT_PATH/.gitignore" << 'EOF'
# Environment
.env
.env.local
*.local

# Python
__pycache__/
*.py[cod]
.venv/
venv/
*.egg-info/

# Node
node_modules/
dist/

# IDE
.idea/
*.swp
*.swo
.DS_Store
EOF

# Initialize git
echo "🔧 Initializing git repository..."
cd "$PROJECT_PATH"
git init -q
git add .
git commit -q -m "Initial project from context-engineering template"

echo ""
echo "✅ Project created successfully!"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_PATH"
echo "  code .  # or cursor . or claude"
echo ""
echo "Then edit INITIAL.md and run:"
echo "  /generate-prp INITIAL.md"
