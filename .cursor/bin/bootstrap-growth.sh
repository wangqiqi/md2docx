#!/usr/bin/env bash
# Bootstrap .cursorGrowth/ for mother-repo dev or repair broken rules/local symlink.
# Idempotent — safe to run before template-verify or on first clone.
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"
GROWTH_TEMPLATE="$CUR/templates/cursorGrowth"
GROWTH_DIR="$ROOT/.cursorGrowth"

[[ -d "$GROWTH_TEMPLATE" ]] || { echo "FAIL bootstrap-growth: missing $GROWTH_TEMPLATE"; exit 1; }

mkdir -p "$GROWTH_DIR/learn" "$GROWTH_DIR/archive" "$GROWTH_DIR/rules/local" \
  "$GROWTH_DIR/logs" "$GROWTH_DIR/perception"

if [[ ! -f "$GROWTH_DIR/README.md" && -f "$GROWTH_TEMPLATE/README.md" ]]; then
  cp "$GROWTH_TEMPLATE/README.md" "$GROWTH_DIR/README.md"
fi

for stub in "$GROWTH_TEMPLATE/learn"/*.md; do
  [[ -f "$stub" ]] || continue
  dest="$GROWTH_DIR/learn/$(basename "$stub")"
  [[ -f "$dest" ]] || cp "$stub" "$dest"
done

if [[ -f "$GROWTH_TEMPLATE/rules/local/README.md" && ! -f "$GROWTH_DIR/rules/local/README.md" ]]; then
  cp "$GROWTH_TEMPLATE/rules/local/README.md" "$GROWTH_DIR/rules/local/README.md"
fi

CURSOR_LOCAL="$ROOT/.cursor/rules/local"
if [[ -d "$GROWTH_DIR/rules/local" ]]; then
  if [[ ! -L "$CURSOR_LOCAL" && ! -d "$CURSOR_LOCAL" ]]; then
    ln -sf "../../.cursorGrowth/rules/local" "$CURSOR_LOCAL"
    echo "Linked .cursor/rules/local → .cursorGrowth/rules/local"
  elif [[ -L "$CURSOR_LOCAL" && ! -e "$CURSOR_LOCAL" ]]; then
    rm -f "$CURSOR_LOCAL"
    ln -sf "../../.cursorGrowth/rules/local" "$CURSOR_LOCAL"
    echo "Repaired .cursor/rules/local symlink"
  fi
fi

echo "OK  bootstrap-growth: .cursorGrowth ready ($GROWTH_DIR)"
