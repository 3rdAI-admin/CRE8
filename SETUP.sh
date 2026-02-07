#!/bin/bash
# Shim for the actual setup script in bin/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/bin/setup.sh" "$@"
