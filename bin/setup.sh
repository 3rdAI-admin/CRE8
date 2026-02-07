#!/bin/bash

# =============================================================================
# Context Engineering Template - Unified Setup Script
# =============================================================================
# Interactive setup for VS Code, Claude Code, and/or Cursor IDE
#
# Original Creator: Cole Medin (https://github.com/coleam00)
# Repository: https://github.com/coleam00/Context-Engineering-Intro
# Contributor: James Avila (https://th3rdai.com)
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get script directory (project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    clear
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                               ║${NC}"
    echo -e "${BLUE}║   ${CYAN}${BOLD}Context Engineering Template - Setup Wizard${NC}${BLUE}              ║${NC}"
    echo -e "${BLUE}║                                                               ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_menu() {
    echo -e "${BOLD}Select your IDE(s) to configure:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} VS Code with GitHub Copilot"
    echo -e "  ${GREEN}2)${NC} Claude Code"
    echo -e "  ${GREEN}3)${NC} Cursor"
    echo -e "  ${GREEN}4)${NC} All IDEs (VS Code + Claude Code + Cursor)"
    echo ""
    echo -e "  ${YELLOW}q)${NC} Quit"
    echo ""
}

print_separator() {
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

determine_target_and_create() {
    local ide_flags="$1" # e.g. "--vscode" or "--all"
    
    echo -e "${YELLOW}Where would you like to set up the environment?${NC}"
    echo "1) Configure current directory ($SCRIPT_DIR)"
    echo "2) Create and configure a new project"
    read -p "Select option (1/2): " setup_choice

    if [[ "$setup_choice" == "2" ]]; then
        read -p "Enter path for new project (e.g. ~/projects/my-app): " entered_path
        
        # Expand tilde manually
        local target_path="${entered_path/#\~/$HOME}"
        
        if [ -z "$target_path" ]; then
            print_error "Path is required."
            return 1
        fi
        
        # Check if create-project.sh exists
        if [ ! -f "${SCRIPT_DIR}/bin/create-project.sh" ]; then
             print_error "create-project.sh not found!"
             return 1
        fi

        # Run create-project.sh with flags
        print_info "Creating project with flags: $ide_flags"
        bash "${SCRIPT_DIR}/bin/create-project.sh" "$target_path" $ide_flags
        
        if [ $? -ne 0 ]; then
            return 1
        fi
        
        TARGET_PATH="$target_path"
        return 0
    else
        TARGET_PATH="$SCRIPT_DIR"
        return 0
    fi
}

# =============================================================================
# Setup Functions
# =============================================================================

setup_vscode() {
    local target_dir="${1:-}"

    echo ""
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}${BOLD}  Setting up VS Code with GitHub Copilot${NC}"
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "${SCRIPT_DIR}/bin/setup-vscode.sh" ]; then
        if [ -n "$target_dir" ]; then
            bash "${SCRIPT_DIR}/bin/setup-vscode.sh" "$target_dir"
        else
            bash "${SCRIPT_DIR}/bin/setup-vscode.sh"
        fi
        return $?
    else
        print_error "setup-vscode.sh not found!"
        return 1
    fi
}

setup_claude() {
    local target_dir="${1:-}"

    echo ""
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}${BOLD}  Setting up Claude Code${NC}"
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "${SCRIPT_DIR}/bin/setup-claude.sh" ]; then
        if [ -n "$target_dir" ]; then
            bash "${SCRIPT_DIR}/bin/setup-claude.sh" "$target_dir"
        else
            bash "${SCRIPT_DIR}/bin/setup-claude.sh"
        fi
        return $?
    else
        print_error "setup-claude.sh not found!"
        return 1
    fi
}

setup_cursor() {
    local target_dir="${1:-}"

    echo ""
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}${BOLD}  Setting up Cursor${NC}"
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "${SCRIPT_DIR}/bin/setup-cursor.sh" ]; then
        if [ -n "$target_dir" ]; then
            bash "${SCRIPT_DIR}/bin/setup-cursor.sh" "$target_dir"
        else
            bash "${SCRIPT_DIR}/bin/setup-cursor.sh"
        fi
        return $?
    else
        print_error "setup-cursor.sh not found!"
        return 1
    fi
}

setup_all() {
    local target_dir="${1:-}"
    local vscode_status=0
    local claude_status=0
    local cursor_status=0

    echo ""
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}${BOLD}  Setting up ALL IDEs${NC}"
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Sync commands from canonical source
    if [ -f "${SCRIPT_DIR}/bin/sync-commands.sh" ]; then
        print_info "Syncing commands to all IDE directories..."
        bash "${SCRIPT_DIR}/bin/sync-commands.sh" || print_warning "Command sync had issues"
        echo ""
        print_separator
        echo ""
    fi

    # VS Code
    print_info "Starting VS Code setup..."
    echo ""
    if setup_vscode "$target_dir"; then
        vscode_status=0
    else
        vscode_status=1
    fi
    
    echo ""
    print_separator
    
    # Claude Code
    print_info "Starting Claude Code setup..."
    echo ""
    if setup_claude "$target_dir"; then
        claude_status=0
    else
        claude_status=1
    fi
    
    echo ""
    print_separator
    
    # Cursor
    print_info "Starting Cursor setup..."
    echo ""
    if setup_cursor "$target_dir"; then
        cursor_status=0
    else
        cursor_status=1
    fi
    
    # Summary
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}                    SETUP SUMMARY${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ $vscode_status -eq 0 ]; then
        print_success "VS Code with GitHub Copilot"
    else
        print_error "VS Code with GitHub Copilot (had issues)"
    fi
    
    if [ $claude_status -eq 0 ]; then
        print_success "Claude Code"
    else
        print_error "Claude Code (had issues)"
    fi
    
    if [ $cursor_status -eq 0 ]; then
        print_success "Cursor"
    else
        print_error "Cursor (had issues)"
    fi
    
    echo ""
    
    return 0
}

print_quick_start() {
    echo ""
    echo -e "${CYAN}${BOLD}🚀 Quick Start Guide:${NC}"
    echo ""
    echo "  1. Edit INITIAL.md with your feature requirements"
    echo ""
echo "  2. Use slash commands in your IDE:"
echo -e "     ${GREEN}/new-project [path]${NC}           - Create new project from template"
echo -e "     ${GREEN}/generate-prp INITIAL.md${NC}     - Create implementation plan"
echo -e "     ${GREEN}/execute-prp PRPs/feature.md${NC}  - Implement the feature"
echo -e "     ${GREEN}/build-prp [PRPs/...]${NC}       - Finalize PRP, then optionally build and run"
echo -e "     ${GREEN}/generate-prompt <task>${NC}      - Create standalone prompt"
echo -e "     ${GREEN}/validate-project${NC}           - Run project validation (from /generate-validate)"
echo -e "     ${GREEN}/generate-validate${NC}          - Create /validate-project for your project (all 3 IDEs)"
echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# Command Line Arguments
# =============================================================================

show_help() {
    echo "Usage: ./setup.sh [option]"
    echo ""
    echo "Options:"
    echo "  --vscode, -v     Setup VS Code with GitHub Copilot only"
    echo "  --claude, -c     Setup Claude Code only"
    echo "  --cursor, -u     Setup Cursor only"
    echo "  --all, -a        Setup all IDEs"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Without options, an interactive menu will be displayed."
    echo ""
    echo "When creating a new project, only the selected IDE(s) configuration"
    echo "files will be copied (.github/.vscode for VS Code, .claude for Claude,"
    echo ".cursor/.cursorrules for Cursor). This keeps projects clean and focused."
    echo ""
}

# =============================================================================
# Main Script
# =============================================================================

main() {
    # Handle command line arguments
    case "${1:-}" in
        --vscode|-v)
            setup_vscode
            print_quick_start
            exit $?
            ;;
        --claude|-c)
            setup_claude
            print_quick_start
            exit $?
            ;;
        --cursor|-u)
            setup_cursor
            print_quick_start
            exit $?
            ;;
        --all|-a)
            setup_all
            print_quick_start
            exit $?
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        "")
            # Interactive mode
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    
    # Interactive menu
    while true; do
        print_header
        print_menu
        
        echo -n "Enter your choice [1-4, q]: "
        read -r choice
        
        case $choice in
            1)
                determine_target_and_create "--vscode"
                if [ $? -eq 0 ]; then
                    setup_vscode "$TARGET_PATH"
                    print_quick_start
                fi
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            2)
                determine_target_and_create "--claude"
                if [ $? -eq 0 ]; then
                    setup_claude "$TARGET_PATH"
                    print_quick_start
                fi
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            3)
                determine_target_and_create "--cursor"
                if [ $? -eq 0 ]; then
                    setup_cursor "$TARGET_PATH"
                    print_quick_start
                fi
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            4)
                determine_target_and_create "--all"
                if [ $? -eq 0 ]; then
                    setup_all "$TARGET_PATH"
                    print_quick_start
                fi
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            q|Q)
                echo ""
                echo -e "${GREEN}Goodbye! Happy coding! 🎉${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo ""
                print_warning "Invalid choice. Please enter 1, 2, 3, 4, or q."
                sleep 1
                ;;
        esac
    done
}

# Run main function
main "$@"
