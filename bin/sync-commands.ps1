# sync-commands.ps1 - Sync canonical commands to all IDE directories (Windows)
#
# Usage:
#   .\sync-commands.ps1              # Sync all commands
#   .\sync-commands.ps1 -DryRun      # Show what would be changed
#   .\sync-commands.ps1 -Check       # Check for drift (CI mode)

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Check
)

$ErrorActionPreference = "Stop"
$BinDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $BinDir

$CanonicalDir = Join-Path $ScriptDir ".commands"
$ClaudeDir = Join-Path $ScriptDir ".claude\commands"
$CursorDir = Join-Path $ScriptDir ".cursor\prompts"
$VSCodeDir = Join-Path $ScriptDir ".github\prompts"

# Ensure canonical directory exists
if (-not (Test-Path $CanonicalDir)) {
    Write-Host "[X] Error: Canonical commands directory not found: $CanonicalDir" -ForegroundColor Red
    Write-Host "Create .commands/ directory with canonical command files first."
    exit 1
}

# Get command files (exclude README.md)
$commandFiles = Get-ChildItem -Path $CanonicalDir -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

if ($commandFiles.Count -eq 0) {
    Write-Host "[!] Warning: No .md files found in $CanonicalDir" -ForegroundColor Yellow
    Write-Host "Add canonical command files to .commands/ directory."
    exit 0
}

Write-Host "Syncing $($commandFiles.Count) commands from .commands/ to IDE directories..." -ForegroundColor Cyan
Write-Host ""

$synced = 0
$skipped = 0
$drifted = 0

function Get-Description {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw

    # Try frontmatter first
    if ($content -match "(?s)^---\s*\n(.+?)\n---") {
        $frontmatter = $Matches[1]
        if ($frontmatter -match "description:\s*['""]?(.+?)['""]?\s*$") {
            return $Matches[1].Trim()
        }
    }

    # Fall back to first heading
    $lines = Get-Content $FilePath
    foreach ($line in $lines) {
        if ($line -match "^#\s+(.+)$") {
            return $Matches[1].Trim()
        }
    }

    return "Command"
}

function Get-ContentWithoutFrontmatter {
    param([string]$FilePath)

    $lines = Get-Content $FilePath
    $inFrontmatter = $false
    $frontmatterEnd = -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -eq 0 -and $lines[$i] -eq "---") {
            $inFrontmatter = $true
            continue
        }
        if ($inFrontmatter -and $lines[$i] -eq "---") {
            $frontmatterEnd = $i
            break
        }
    }

    if ($frontmatterEnd -ge 0) {
        $contentLines = $lines[($frontmatterEnd + 1)..($lines.Count - 1)]
        # Trim leading empty lines
        $startIdx = 0
        foreach ($line in $contentLines) {
            if ($line.Trim() -ne "") { break }
            $startIdx++
        }
        if ($startIdx -lt $contentLines.Count) {
            return ($contentLines[$startIdx..($contentLines.Count - 1)] -join "`n")
        }
        return ""
    }

    return (Get-Content $FilePath -Raw)
}

function Sync-Command {
    param([System.IO.FileInfo]$SourceFile)

    $basename = $SourceFile.BaseName
    $description = Get-Description -FilePath $SourceFile.FullName
    $content = Get-ContentWithoutFrontmatter -FilePath $SourceFile.FullName

    # Adjust relative links to be workspace-relative from target directory (2 levels deep)
    $transformedContent = $content -replace '\]\(([^/h#][^)]*)\)', '](../../$1)'

    # Define target files and their content
    $targets = @(
        @{
            Path = Join-Path $ClaudeDir "$basename.md"
            Content = "---`ndescription: $description`n---`n`n$transformedContent"
        },
        @{
            Path = Join-Path $CursorDir "$basename.md"
            Content = "---`ndescription: $description`n---`n`n$transformedContent"
        },
        @{
            Path = Join-Path $VSCodeDir "$basename.prompt.md"
            Content = "---`nagent: agent`ndescription: $description`n---`n`n$transformedContent"
        }
    )

    $changes = 0

    foreach ($target in $targets) {
        $targetPath = $target.Path
        $targetContent = $target.Content

        $needsUpdate = $false
        $isMissing = $false

        if (Test-Path $targetPath) {
            $existing = Get-Content $targetPath -Raw
            if ($existing -ne $targetContent) {
                $needsUpdate = $true
            }
        } else {
            $isMissing = $true
            $needsUpdate = $true
        }

        if ($needsUpdate) {
            $changes++
            $relativePath = $targetPath.Replace($ScriptDir, "").TrimStart("\", "/")

            if ($Check) {
                if ($isMissing) {
                    Write-Host "  MISSING $relativePath" -ForegroundColor Red
                } else {
                    Write-Host "  DRIFT $relativePath" -ForegroundColor Yellow
                }
                $script:drifted++
            } elseif ($DryRun) {
                if ($isMissing) {
                    Write-Host "  WOULD CREATE $relativePath" -ForegroundColor Yellow
                } else {
                    Write-Host "  WOULD UPDATE $relativePath" -ForegroundColor Yellow
                }
            } else {
                # Ensure directory exists
                $dir = Split-Path $targetPath -Parent
                if (-not (Test-Path $dir)) {
                    New-Item -ItemType Directory -Path $dir -Force | Out-Null
                }

                # Write content
                Set-Content -Path $targetPath -Value $targetContent -NoNewline

                if ($isMissing) {
                    Write-Host "  CREATED $relativePath" -ForegroundColor Green
                } else {
                    Write-Host "  UPDATED $relativePath" -ForegroundColor Green
                }
            }
        } else {
            $script:skipped++
        }
    }

    if ($changes -gt 0) {
        $script:synced += $changes
    }
}

# Process each command
foreach ($file in $commandFiles) {
    Write-Host $file.Name -ForegroundColor Cyan
    Sync-Command -SourceFile $file
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan

if ($Check) {
    if ($drifted -gt 0) {
        Write-Host "Found $drifted files with drift" -ForegroundColor Red
        Write-Host "Run .\sync-commands.ps1 to sync changes"
        exit 1
    } else {
        Write-Host "All commands in sync" -ForegroundColor Green
        exit 0
    }
} elseif ($DryRun) {
    Write-Host "Dry run complete" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to apply changes"
} else {
    Write-Host "Sync complete: $synced updated, $skipped unchanged" -ForegroundColor Green
}
