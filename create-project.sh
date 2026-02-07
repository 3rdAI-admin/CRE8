#!/bin/bash
# Shim for bin/create-project.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/bin/create-project.sh" "$@"
