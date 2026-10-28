#!/usr/bin/env bash
# Deprecated: flat copy removed — use link-cursor-ide.sh (symlinks only).
set -euo pipefail
echo "WARN: assemble.sh is deprecated; running link-cursor-ide.sh (symlinks, no duplicate tree)" >&2
exec bash "$(dirname "${BASH_SOURCE[0]}")/link-cursor-ide.sh" "$@"
