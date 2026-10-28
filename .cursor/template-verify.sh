#!/usr/bin/env bash
# Mother repo CI entry: ensure IDE symlinks then full template verify (no flat copy).
set -euo pipefail
PACK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$PACK/harness/link-cursor-ide.sh" "$PACK"
exec bash "$PACK/harness/core/bin/template-verify.sh"
