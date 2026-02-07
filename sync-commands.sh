#!/bin/bash
# Shim for the actual sync script in bin/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/bin/sync-commands.sh" "$@"
