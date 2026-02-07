# =============================================================================
# Context Engineering Template - Windows PowerShell Setup Script
# =============================================================================
# Interactive setup for VS Code, Claude Code, and/or Cursor IDE on Windows
#
# Original Creator: Cole Medin (https://github.com/coleam00)
# Repository: https://github.com/coleam00/Context-Engineering-Intro
# Contributor: James Avila (https://th3rdai.com)
#
# Usage:
#   .\SETUP.ps1              # Interactive menu
#   .\SETUP.ps1 -VSCode      # VS Code only
#   .\SETUP.ps1 -Claude      # Claude Code only
#   .\SETUP.ps1 -Cursor      # Cursor only
#   .\SETUP.ps1 -All         # All IDEs
# =============================================================================

[CmdletBinding()]
param(
    [switch]$VSCode,
    [switch]$Claude,
    [switch]$Cursor,
    [switch]$All,
    [switch]$Help
)

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Get script directory (project root)
$BinDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $BinDir

# =============================================================================
# Helper Functions
# =============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$ForegroundColor = "White"
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "  [X] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "  [!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [i] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "+===============================================================+" -ForegroundColor Blue
    Write-Host "|                                                               |" -ForegroundColor Blue
    Write-Host "|   " -ForegroundColor Blue -NoNewline
    Write-Host "Context Engineering Template - Setup Wizard" -ForegroundColor Cyan -NoNewline
    Write-Host "              |" -ForegroundColor Blue
    Write-Host "|                                                               |" -ForegroundColor Blue
    Write-Host "+===============================================================+" -ForegroundColor Blue
    Write-Host ""
}

function Write-Separator {
    Write-Host "---------------------------------------------------------------" -ForegroundColor Blue
}

function Write-Menu {
    Write-Host "Select your IDE(s) to configure:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1) " -ForegroundColor Green -NoNewline
    Write-Host "VS Code with GitHub Copilot"
    Write-Host "  2) " -ForegroundColor Green -NoNewline
    Write-Host "Claude Code"
    Write-Host "  3) " -ForegroundColor Green -NoNewline
    Write-Host "Cursor"
    Write-Host "  4) " -ForegroundColor Green -NoNewline
    Write-Host "All IDEs (VS Code + Claude Code + Cursor)"
    Write-Host ""
    Write-Host "  q) " -ForegroundColor Yellow -NoNewline
    Write-Host "Quit"
    Write-Host ""
}

function Write-QuickStart {
    Write-Host ""
    Write-Host "Quick Start Guide:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Edit INITIAL.md with your feature requirements"
    Write-Host ""
    Write-Host "  2. Use slash commands in your IDE:"
    Write-Host "     " -NoNewline
    Write-Host "/new-project [path]" -ForegroundColor Green -NoNewline
    Write-Host "           - Create new project from template"
    Write-Host "     " -NoNewline
    Write-Host "/generate-prp INITIAL.md" -ForegroundColor Green -NoNewline
    Write-Host "     - Create implementation plan"
    Write-Host "     " -NoNewline
    Write-Host "/execute-prp PRPs/feature.md" -ForegroundColor Green -NoNewline
    Write-Host "  - Implement the feature"
    Write-Host "     " -NoNewline
    Write-Host "/build-prp [PRPs/...]" -ForegroundColor Green -NoNewline
    Write-Host "       - Finalize PRP, then build and run"
    Write-Host "     " -NoNewline
    Write-Host "/generate-prompt <task>" -ForegroundColor Green -NoNewline
    Write-Host "      - Create standalone prompt"
    Write-Host "     " -NoNewline
    Write-Host "/validate-project" -ForegroundColor Green -NoNewline
    Write-Host "           - Run project validation"
    Write-Host "     " -NoNewline
    Write-Host "/generate-validate" -ForegroundColor Green -NoNewline
    Write-Host "          - Create /validate-project for your project"
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor Blue
    Write-Host ""
}

function Show-Help {
    Write-Host "Usage: .\SETUP.ps1 [option]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -VSCode      Setup VS Code with GitHub Copilot only"
    Write-Host "  -Claude      Setup Claude Code only"
    Write-Host "  -Cursor      Setup Cursor only"
    Write-Host "  -All         Setup all IDEs"
    Write-Host "  -Help        Show this help message"
    Write-Host ""
    Write-Host "Without options, an interactive menu will be displayed."
    Write-Host ""
}

# =============================================================================
# Setup Functions
# =============================================================================

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Setup-VSCode {
    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host "  Setting up VS Code with GitHub Copilot" -ForegroundColor Magenta
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host ""

    # Step 1: Check if VS Code is installed
    Write-Host "Step 1: Checking VS Code installation..." -ForegroundColor Yellow

    $vscodePath = $null
    if (Test-CommandExists "code") {
        $vscodePath = "code"
        Write-Success "VS Code CLI found"
    }
    elseif (Test-Path "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd") {
        $vscodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
        Write-Success "VS Code found at default location"
    }
    else {
        Write-Error2 "VS Code not found"
        Write-Host ""
        Write-Host "  Please install VS Code from: https://code.visualstudio.com/"
        Write-Host "  Then run: Shell Command: Install 'code' command in PATH"
        Write-Host ""
        return $false
    }

    # Step 2: Install GitHub Copilot extensions
    Write-Host ""
    Write-Host "Step 2: Installing GitHub Copilot extensions..." -ForegroundColor Yellow

    $extensions = @(
        "GitHub.copilot",
        "GitHub.copilot-chat"
    )

    foreach ($ext in $extensions) {
        Write-Host "  Installing $ext... " -NoNewline
        try {
            $result = & $vscodePath --install-extension $ext --force 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[OK]" -ForegroundColor Green
            }
            else {
                Write-Host "(may already be installed)" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "(may already be installed or requires login)" -ForegroundColor Yellow
        }
    }

    # Step 3: Verify project structure
    Write-Host ""
    Write-Host "Step 3: Verifying project structure..." -ForegroundColor Yellow

    $requiredDirs = @(
        ".github\prompts",
        ".vscode",
        "PRPs\templates"
    )

    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $ScriptDir $dir
        if (Test-Path $fullPath) {
            Write-Success "$dir exists"
        }
        else {
            Write-Warning2 "Creating $dir..."
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
    }

    # Step 4: Verify prompt files
    Write-Host ""
    Write-Host "Step 4: Verifying prompt files..." -ForegroundColor Yellow

    $requiredFiles = @(
        ".github\prompts\new-project.prompt.md",
        ".github\prompts\generate-prp.prompt.md",
        ".github\prompts\execute-prp.prompt.md",
        ".github\prompts\build-prp.prompt.md",
        ".github\prompts\generate-prompt.prompt.md",
        ".github\prompts\validate-project.prompt.md",
        ".github\prompts\generate-validate.prompt.md",
        ".github\copilot-instructions.md"
    )

    $allFilesExist = $true
    foreach ($file in $requiredFiles) {
        $fullPath = Join-Path $ScriptDir $file
        if (Test-Path $fullPath) {
            Write-Success $file
        }
        else {
            Write-Error2 "$file (missing!)"
            $allFilesExist = $false
        }
    }

    if (-not $allFilesExist) {
        Write-Warning2 "Some files are missing. Setup can continue but may be incomplete."
    }

    # Step 5: Check VS Code settings
    Write-Host ""
    Write-Host "Step 5: Checking VS Code settings..." -ForegroundColor Yellow

    $settingsFile = Join-Path $ScriptDir ".vscode\settings.json"
    if (Test-Path $settingsFile) {
        $settingsContent = Get-Content $settingsFile -Raw

        if ($settingsContent -match '"chat.promptFiles"') {
            Write-Success "chat.promptFiles configured"
        }
        else {
            Write-Warning2 "chat.promptFiles not configured"
        }

        if ($settingsContent -match '"github.copilot.chat.codeGeneration.useInstructionFiles"') {
            Write-Success "useInstructionFiles configured"
        }
        else {
            Write-Warning2 "useInstructionFiles not configured (optional)"
        }
    }
    else {
        Write-Warning2 "Creating default settings.json..."
        $settingsContent = @'
{
  "chat.promptFiles": true,
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "github.copilot.chat.localeOverride": "en",
  "chat.agent.enabled": true
}
'@
        New-Item -ItemType Directory -Path (Split-Path $settingsFile) -Force | Out-Null
        $settingsContent | Set-Content $settingsFile
        Write-Success "Created default settings.json"
    }

    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Blue
    Write-Host "  VS Code Setup Complete!" -ForegroundColor Green
    Write-Host "==============================================================" -ForegroundColor Blue

    return $true
}

function Setup-Claude {
    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host "  Setting up Claude Code" -ForegroundColor Magenta
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host ""

    # Step 1: Check if Claude Code CLI is available
    Write-Host "Step 1: Checking Claude Code installation..." -ForegroundColor Yellow

    if (Test-CommandExists "claude") {
        Write-Success "Claude Code CLI found"
        try {
            $version = & claude --version 2>&1
            Write-Host "       Version: $version" -ForegroundColor Gray
        }
        catch {
            # Ignore version check errors
        }
    }
    else {
        Write-Error2 "Claude Code CLI not found"
        Write-Host ""
        Write-Host "  Please install Claude Code:"
        Write-Host "    1. Visit https://claude.ai/code"
        Write-Host "    2. Download and install Claude Code for Windows"
        Write-Host "    3. Run this script again"
        Write-Host ""
        Write-Host "  Alternatively, install via npm:"
        Write-Host "    npm install -g @anthropic-ai/claude-code"
        Write-Host ""
        return $false
    }

    # Step 2: Verify project structure
    Write-Host ""
    Write-Host "Step 2: Verifying project structure..." -ForegroundColor Yellow

    $requiredDirs = @(
        ".claude\commands",
        ".claude\skills",
        "PRPs\templates"
    )

    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $ScriptDir $dir
        if (Test-Path $fullPath) {
            Write-Success "$dir exists"
        }
        else {
            Write-Warning2 "Creating $dir..."
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
    }

    # Step 3: Verify command files
    Write-Host ""
    Write-Host "Step 3: Verifying slash command files..." -ForegroundColor Yellow

    $requiredFiles = @(
        ".claude\commands\new-project.md",
        ".claude\commands\generate-prp.md",
        ".claude\commands\execute-prp.md",
        ".claude\commands\build-prp.md",
        ".claude\commands\generate-prompt.md",
        ".claude\commands\validate-project.md",
        ".claude\commands\generate-validate.md",
        ".claude\settings.local.json",
        "CLAUDE.md",
        "INITIAL.md",
        "PRPs\templates\prp_base.md"
    )

    $allFilesExist = $true
    foreach ($file in $requiredFiles) {
        $fullPath = Join-Path $ScriptDir $file
        if (Test-Path $fullPath) {
            Write-Success $file
        }
        else {
            Write-Error2 "$file (missing!)"
            $allFilesExist = $false
        }
    }

    if (-not $allFilesExist) {
        Write-Warning2 "Some files are missing. Setup can continue but may be incomplete."
    }

    # Step 4: Verify settings.local.json
    Write-Host ""
    Write-Host "Step 4: Checking Claude Code settings..." -ForegroundColor Yellow

    $settingsFile = Join-Path $ScriptDir ".claude\settings.local.json"
    if (Test-Path $settingsFile) {
        $settingsContent = Get-Content $settingsFile -Raw

        if ($settingsContent -match '"permissions"') {
            Write-Success "Permissions configured"
        }
        else {
            Write-Error2 "Permissions not found in settings"
        }

        if ($settingsContent -match 'Bash\(python') {
            Write-Success "Python execution allowed"
        }
        else {
            Write-Warning2 "Python execution not configured"
        }

        if ($settingsContent -match 'Bash\(pytest') {
            Write-Success "Pytest execution allowed"
        }
        else {
            Write-Warning2 "Pytest execution not configured"
        }
    }
    else {
        Write-Warning2 "settings.local.json not found, creating default..."
        $defaultSettings = @'
{
  "permissions": {
    "allow": [
      "Bash(grep:*)",
      "Bash(ls:*)",
      "Bash(find:*)",
      "Bash(mv:*)",
      "Bash(mkdir:*)",
      "Bash(ruff:*)",
      "Bash(touch:*)",
      "Bash(cat:*)",
      "Bash(ruff check:*)",
      "Bash(pytest:*)",
      "Bash(python:*)",
      "Bash(python -m pytest:*)",
      "WebFetch(domain:docs.anthropic.com)",
      "WebFetch(domain:github.com)"
    ],
    "deny": []
  }
}
'@
        New-Item -ItemType Directory -Path (Split-Path $settingsFile) -Force | Out-Null
        $defaultSettings | Set-Content $settingsFile
        Write-Success "Created default settings.local.json"
    }

    # Step 5: Verify CLAUDE.md
    Write-Host ""
    Write-Host "Step 5: Checking CLAUDE.md..." -ForegroundColor Yellow

    $claudeMdPath = Join-Path $ScriptDir "CLAUDE.md"
    if (Test-Path $claudeMdPath) {
        Write-Success "CLAUDE.md found"
        $firstLine = (Get-Content $claudeMdPath -TotalCount 1) -replace '^#+\s*', ''
        Write-Host "       -> $firstLine" -ForegroundColor Blue
    }
    else {
        Write-Error2 "CLAUDE.md not found"
    }

    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Blue
    Write-Host "  Claude Code Setup Complete!" -ForegroundColor Green
    Write-Host "==============================================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Available Slash Commands:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  /new-project       - Create new project from template"
    Write-Host "  /generate-prp      - Create comprehensive PRP from INITIAL.md"
    Write-Host "  /execute-prp       - Implement feature from PRP with validation"
    Write-Host "  /build-prp         - Finalize PRP, then build and run"
    Write-Host "  /generate-prompt   - Create XML-structured prompt (standalone)"
    Write-Host "  /validate-project  - Run project validation"
    Write-Host "  /generate-validate - Create /validate-project for your project"
    Write-Host ""

    return $true
}

function Setup-Cursor {
    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host "  Setting up Cursor" -ForegroundColor Magenta
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host ""

    # Step 1: Check if Cursor is installed
    Write-Host "Step 1: Checking Cursor installation..." -ForegroundColor Yellow

    $cursorPath = $null
    if (Test-CommandExists "cursor") {
        $cursorPath = "cursor"
        Write-Success "Cursor CLI found"
    }
    elseif (Test-Path "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe") {
        Write-Success "Cursor found at default location"
    }
    else {
        Write-Warning2 "Cursor not found (optional)"
        Write-Host "  Install from: https://cursor.sh/"
    }

    # Step 2: Verify project structure
    Write-Host ""
    Write-Host "Step 2: Verifying project structure..." -ForegroundColor Yellow

    $requiredDirs = @(
        ".cursor\prompts",
        "PRPs\templates"
    )

    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $ScriptDir $dir
        if (Test-Path $fullPath) {
            Write-Success "$dir exists"
        }
        else {
            Write-Warning2 "Creating $dir..."
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
    }

    # Step 3: Verify prompt files
    Write-Host ""
    Write-Host "Step 3: Verifying prompt files..." -ForegroundColor Yellow

    $requiredFiles = @(
        ".cursor\prompts\new-project.md",
        ".cursor\prompts\generate-prp.md",
        ".cursor\prompts\execute-prp.md",
        ".cursor\prompts\build-prp.md",
        ".cursor\prompts\generate-prompt.md",
        ".cursor\prompts\validate-project.md",
        ".cursor\prompts\generate-validate.md",
        ".cursorrules"
    )

    $allFilesExist = $true
    foreach ($file in $requiredFiles) {
        $fullPath = Join-Path $ScriptDir $file
        if (Test-Path $fullPath) {
            Write-Success $file
        }
        else {
            Write-Error2 "$file (missing!)"
            $allFilesExist = $false
        }
    }

    if (-not $allFilesExist) {
        Write-Warning2 "Some files are missing. Setup can continue but may be incomplete."
    }

    # Step 4: Check .cursorrules
    Write-Host ""
    Write-Host "Step 4: Checking .cursorrules..." -ForegroundColor Yellow

    $cursorRulesPath = Join-Path $ScriptDir ".cursorrules"
    if (Test-Path $cursorRulesPath) {
        Write-Success ".cursorrules found"
        $fileSize = (Get-Item $cursorRulesPath).Length
        $lineCount = (Get-Content $cursorRulesPath | Measure-Object -Line).Lines
        Write-Host "       Lines: $lineCount, Size: $fileSize bytes" -ForegroundColor Gray
    }
    else {
        Write-Warning2 ".cursorrules not found, creating default..."
        $defaultCursorRules = @'
# Context Engineering Template - Cursor AI Rules

## Project Overview
This is a **Context Engineering Template** for AI-assisted development using PRPs (Product Requirements Prompts).

## Core Workflow: The PRP Pattern

1. **INITIAL.md** - Define requirements in structured format
2. **Generate PRP** - AI creates comprehensive implementation plan
3. **Execute PRP** - AI implements with validation loops
4. **Validate** - Run checks to verify implementation

## Slash Commands

Use these commands in Cursor chat:
- `/new-project` - Create new project from template
- `/generate-prp` - Create PRP from INITIAL.md
- `/execute-prp` - Implement feature from PRP
- `/build-prp` - Finalize PRP, then build and run
- `/generate-prompt` - Create standalone prompt
- `/validate-project` - Run project validation
- `/generate-validate` - Create validation command

## Key Rules

1. Always read INITIAL.md or PRP before implementing
2. Follow the validation loops defined in PRPs
3. Create tests for new functionality
4. Document code with clear comments
5. Keep files under 500 lines
'@
        $defaultCursorRules | Set-Content $cursorRulesPath -Encoding UTF8
        Write-Success "Created default .cursorrules"
    }

    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Blue
    Write-Host "  Cursor Setup Complete!" -ForegroundColor Green
    Write-Host "==============================================================" -ForegroundColor Blue

    return $true
}

function Setup-All {
    $vscodeStatus = $true
    $claudeStatus = $true
    $cursorStatus = $true

    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host "  Setting up ALL IDEs" -ForegroundColor Magenta
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host ""

    # VS Code
    Write-Info "Starting VS Code setup..."
    $vscodeStatus = Setup-VSCode

    Write-Host ""
    Write-Separator

    # Claude Code
    Write-Info "Starting Claude Code setup..."
    $claudeStatus = Setup-Claude

    Write-Host ""
    Write-Separator

    # Cursor
    Write-Info "Starting Cursor setup..."
    $cursorStatus = Setup-Cursor

    # Summary
    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Blue
    Write-Host "                    SETUP SUMMARY" -ForegroundColor White
    Write-Host "==============================================================" -ForegroundColor Blue
    Write-Host ""

    if ($vscodeStatus) {
        Write-Success "VS Code with GitHub Copilot"
    }
    else {
        Write-Error2 "VS Code with GitHub Copilot (had issues)"
    }

    if ($claudeStatus) {
        Write-Success "Claude Code"
    }
    else {
        Write-Error2 "Claude Code (had issues)"
    }

    if ($cursorStatus) {
        Write-Success "Cursor"
    }
    else {
        Write-Error2 "Cursor (had issues)"
    }

    Write-Host ""

    return $true
}

# =============================================================================
# Main Script
# =============================================================================

# Handle command line arguments
if ($Help) {
    Show-Help
    exit 0
}

if ($VSCode) {
    Setup-VSCode | Out-Null
    Write-QuickStart
    exit 0
}

if ($Claude) {
    Setup-Claude | Out-Null
    Write-QuickStart
    exit 0
}

if ($Cursor) {
    Setup-Cursor | Out-Null
    Write-QuickStart
    exit 0
}

if ($All) {
    Setup-All | Out-Null
    Write-QuickStart
    exit 0
}

# Interactive menu
while ($true) {
    Write-Header
    Write-Menu

    $choice = Read-Host "Enter your choice [1-4, q]"

    switch ($choice) {
        "1" {
            Setup-VSCode | Out-Null
            Write-QuickStart
            Read-Host "Press Enter to continue..."
        }
        "2" {
            Setup-Claude | Out-Null
            Write-QuickStart
            Read-Host "Press Enter to continue..."
        }
        "3" {
            Setup-Cursor | Out-Null
            Write-QuickStart
            Read-Host "Press Enter to continue..."
        }
        "4" {
            Setup-All | Out-Null
            Write-QuickStart
            Read-Host "Press Enter to continue..."
        }
        { $_ -eq "q" -or $_ -eq "Q" } {
            Write-Host ""
            Write-Host "Goodbye! Happy coding!" -ForegroundColor Green
            Write-Host ""
            exit 0
        }
        default {
            Write-Host ""
            Write-Warning2 "Invalid choice. Please enter 1, 2, 3, 4, or q."
            Start-Sleep -Seconds 1
        }
    }
}
