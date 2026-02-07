# bin/ - Project Scripts

Canonical location for all project scripts.

## Setup Scripts

| Script | Description |
|--------|-------------|
| `setup.sh` | Interactive IDE setup wizard |
| `setup-vscode.sh` | VS Code with GitHub Copilot setup |
| `setup-claude.sh` | Claude Code setup |
| `setup-cursor.sh` | Cursor IDE setup |

## Project Creation

| Script | Description |
|--------|-------------|
| `create-project.sh` | Create new project from template (bash) - supports `--vscode`, `--claude`, `--cursor`, `--all` flags |
| `create-project.ps1` | Create new project from template (PowerShell) |

## Utilities

| Script | Description |
|--------|-------------|
| `sync-commands.sh` | Sync commands across IDEs (Bash) |
| `sync-commands.ps1` | Sync commands across IDEs (PowerShell) |
| `install-claude-commands.sh` | Install Claude Code commands globally |
| `install-dev-tools.sh` | Install development dependencies |

## Usage

### From Repository Root

```bash
# Use the main entry point (interactive menu)
./setup.sh

# Or with command-line flags
./setup.sh --vscode   # VS Code only
./setup.sh --claude   # Claude Code only
./setup.sh --cursor   # Cursor only
./setup.sh --all      # All IDEs

# Run bin scripts directly (can also use shims in root)
./bin/setup-claude.sh

# Create project with selective IDE installation
./create-project.sh ~/projects/my-app --vscode  # VS Code only
./create-project.sh ~/projects/my-app --all     # All IDEs (default)
```

### From bin/ Directory (Source of Truth)

```bash
cd bin
./setup.sh --vscode              # VS Code only
./setup.sh --all                 # All IDEs
./create-project.sh ~/projects/my-app --vscode  # VS Code project only
```

## Windows Users

PowerShell versions are provided for Windows compatibility (use root shims or bin directly):

```powershell
.\setup.ps1
.\create-project.ps1 C:\Projects\my-app
.\sync-commands.ps1
```

## Script Conventions

- All bash scripts use `set -e` for error handling
- Scripts auto-detect the repository root via `SCRIPT_DIR`
- Cross-platform paths are handled automatically
- Colored output for better readability
