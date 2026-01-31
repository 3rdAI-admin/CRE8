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
| `create-project.sh` | Create new project from template (bash) |
| `create-project.ps1` | Create new project from template (PowerShell) |

## Utilities

| Script | Description |
|--------|-------------|
| `sync-commands.ps1` | Sync commands across IDEs (PowerShell) |
| `install-claude-commands.sh` | Install Claude Code commands globally |
| `install-dev-tools.sh` | Install development dependencies |

## Usage

### From Repository Root

```bash
# Use the main entry point
./SETUP.sh

# Or run bin scripts directly
./bin/setup-claude.sh
./bin/create-project.sh ~/projects/my-app
```

### From bin/ Directory

```bash
cd bin
./setup.sh
./create-project.sh ~/projects/my-app
```

## Windows Users

PowerShell versions are provided for Windows compatibility:

```powershell
.\bin\setup.ps1
.\bin\create-project.ps1 C:\Projects\my-app
.\bin\sync-commands.ps1
```

## Script Conventions

- All bash scripts use `set -e` for error handling
- Scripts auto-detect the repository root via `SCRIPT_DIR`
- Cross-platform paths are handled automatically
- Colored output for better readability
