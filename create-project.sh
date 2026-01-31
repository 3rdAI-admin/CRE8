#!/bin/bash
# create-project.sh - Create a new project from the context-engineering template

set -e

if [ -z "$1" ]; then
    echo "Usage: ./create-project.sh <project-path>"
    echo "Example: ./create-project.sh ~/projects/my-new-app"
    exit 1
fi

PROJECT_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if directory already exists
if [ -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Directory $PROJECT_PATH already exists"
    exit 1
fi

echo "📁 Creating project at $PROJECT_PATH..."

# Create the project directory
mkdir -p "$PROJECT_PATH"

# Copy template files
echo "📋 Copying template files..."
cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_PATH/"
cp "$SCRIPT_DIR/.cursorrules" "$PROJECT_PATH/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.claude" "$PROJECT_PATH/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.github" "$PROJECT_PATH/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.vscode" "$PROJECT_PATH/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.cursor" "$PROJECT_PATH/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.commands" "$PROJECT_PATH/" 2>/dev/null || true
cp "$SCRIPT_DIR/sync-commands.sh" "$PROJECT_PATH/" 2>/dev/null || true
cp "$SCRIPT_DIR/sync-commands.ps1" "$PROJECT_PATH/" 2>/dev/null || true

# Create project structure
echo "📂 Creating project structure..."
mkdir -p "$PROJECT_PATH/PRPs/prompts"
mkdir -p "$PROJECT_PATH/PRPs/templates"
mkdir -p "$PROJECT_PATH/examples"
mkdir -p "$PROJECT_PATH/journal"

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
