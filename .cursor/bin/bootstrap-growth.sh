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
# Repair mistaken plain-file pointer (must be symlink or directory)
if [[ -f "$CURSOR_LOCAL" && ! -L "$CURSOR_LOCAL" ]]; then
  rm -f "$CURSOR_LOCAL"
fi
if [[ -d "$GROWTH_DIR/rules/local" ]]; then
  if [[ ! -e "$CURSOR_LOCAL" ]]; then
    if ln -sf "../../.cursorGrowth/rules/local" "$CURSOR_LOCAL" 2>/dev/null; then
      echo "Linked .cursor/rules/local → .cursorGrowth/rules/local"
    else
      mkdir -p "$CURSOR_LOCAL"
      cp -f "$GROWTH_DIR/rules/local/README.md" "$CURSOR_LOCAL/README.md" 2>/dev/null \
        || cp -f "$GROWTH_TEMPLATE/rules/local/README.md" "$CURSOR_LOCAL/README.md"
      echo "OK  rules/local directory (symlink unavailable)"
    fi
  elif [[ -L "$CURSOR_LOCAL" && ! -e "$CURSOR_LOCAL" ]]; then
    rm -f "$CURSOR_LOCAL"
    if ln -sf "../../.cursorGrowth/rules/local" "$CURSOR_LOCAL" 2>/dev/null; then
      echo "Repaired .cursor/rules/local symlink"
    else
      mkdir -p "$CURSOR_LOCAL"
      cp -f "$GROWTH_DIR/rules/local/README.md" "$CURSOR_LOCAL/README.md" 2>/dev/null \
        || cp -f "$GROWTH_TEMPLATE/rules/local/README.md" "$CURSOR_LOCAL/README.md"
      echo "OK  rules/local directory (symlink unavailable)"
    fi
  fi
fi

echo "OK  bootstrap-growth: .cursorGrowth ready ($GROWTH_DIR)"
