# create-project.ps1 - Create a new project from the context-engineering template
# Usage: .\create-project.ps1 <project-path>
# Example: .\create-project.ps1 C:\projects\my-new-app

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"

# Get bin directory and root directory
$BinDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $BinDir

# Expand path if relative
if (-not [System.IO.Path]::IsPathRooted($ProjectPath)) {
    $ProjectPath = Join-Path (Get-Location) $ProjectPath
}

# Check if directory already exists
if (Test-Path $ProjectPath) {
    Write-Host "[X] Error: Directory $ProjectPath already exists" -ForegroundColor Red
    exit 1
}

Write-Host "Creating project at $ProjectPath..." -ForegroundColor Cyan

# Create the project directory
New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null

# Copy template files
Write-Host "Copying template files..." -ForegroundColor Cyan

$filesToCopy = @(
    "CLAUDE.md",
    ".cursorrules",
    "sync-commands.sh",
    "sync-commands.ps1"
)

foreach ($file in $filesToCopy) {
    $srcPath = Join-Path $ScriptDir $file
    if (Test-Path $srcPath) {
        Copy-Item $srcPath -Destination $ProjectPath -Force
    }
}

# Copy directories
$dirsToCopy = @(
    ".claude",
    ".github",
    ".vscode",
    ".cursor",
    ".commands"
)

foreach ($dir in $dirsToCopy) {
    $srcPath = Join-Path $ScriptDir $dir
    if (Test-Path $srcPath) {
        Copy-Item $srcPath -Destination $ProjectPath -Recurse -Force
    }
}

# Create project structure
Write-Host "Creating project structure..." -ForegroundColor Cyan

$dirsToCreate = @(
    "PRPs\prompts",
    "PRPs\templates",
    "examples",
    "journal"
)

foreach ($dir in $dirsToCreate) {
    $fullPath = Join-Path $ProjectPath $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

# Copy PRP templates
$prpTemplatesPath = Join-Path $ScriptDir "PRPs\templates"
if (Test-Path $prpTemplatesPath) {
    $destPath = Join-Path $ProjectPath "PRPs\templates"
    Get-ChildItem $prpTemplatesPath -File | ForEach-Object {
        Copy-Item $_.FullName -Destination $destPath -Force
    }
}

# Create empty INITIAL.md
$initialMdContent = @"
## FEATURE:
[Describe what you want to build - be specific about functionality and requirements]

## EXAMPLES:
[List any example files in the examples/ folder and explain how they should be used]

## DOCUMENTATION:
[Include links to relevant documentation, APIs, or resources]

## OTHER CONSIDERATIONS:
[Mention any gotchas, specific requirements, or things AI assistants commonly miss]
"@
$initialMdContent | Set-Content (Join-Path $ProjectPath "INITIAL.md")

# Create .gitignore
$gitignoreContent = @"
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
"@
$gitignoreContent | Set-Content (Join-Path $ProjectPath ".gitignore")

# Initialize git
Write-Host "Initializing git repository..." -ForegroundColor Cyan
Push-Location $ProjectPath
try {
    & git init -q
    & git add .
    & git commit -q -m "Initial project from context-engineering template"
}
catch {
    Write-Host "[!] Git initialization failed (git may not be installed)" -ForegroundColor Yellow
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "[OK] Project created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  cd $ProjectPath"
Write-Host "  code .  # or cursor . or claude"
Write-Host ""
Write-Host "Then edit INITIAL.md and run:"
Write-Host "  /generate-prp INITIAL.md"
Write-Host ""
