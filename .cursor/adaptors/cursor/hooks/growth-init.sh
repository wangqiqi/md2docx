#!/usr/bin/env bash
# Bootstrap .growing from template — see config growth.enabled
set -euo pipefail

INPUT=$(cat)

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/config-load.sh
source "$HOOKS_DIR/lib/config-load.sh"
# shellcheck source=lib/json-utils.sh
source "$HOOKS_DIR/lib/json-utils.sh"
if [[ -f "$HOOKS_DIR/../lib/onekey-bootstrap.sh" ]]; then
  _core_lib="$(cd "$HOOKS_DIR/.." && pwd)/lib"
else
  _core_lib="$(sc_cursor_core_lib_dir "$HOOKS_DIR")"
fi
# shellcheck source=onekey-bootstrap.sh
source "$_core_lib/onekey-bootstrap.sh"
_pack="$(sc_cursor_pack_from_dir "$HOOKS_DIR")"
CURSOR_DIR="${_pack:-$(cd "$HOOKS_DIR/../.." && pwd)}"

sc_resolve_project_root "$HOOKS_DIR"
sc_init_config "$CURSOR_DIR"

if [[ "$SC_GROWTH_ENABLED" != "true" ]]; then
  echo "$INPUT"
  exit 0
fi

PROJECT_ROOT="$(json_workspace_root "$INPUT")"
if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$SC_PROJECT_ROOT"
fi

if [[ "$PROJECT_ROOT" == *"/.cursor" || "$(basename "$PROJECT_ROOT")" == ".cursor" ]]; then
  PROJECT_ROOT="$(cd "$PROJECT_ROOT/.." && pwd)"
fi

GROWTH_DIR="$PROJECT_ROOT/.growing"
# 插件轨不含 templates/ → 回退到已安装项目的母版模板（否则 Growth 只是空目录）
TEMPLATE_DIR="${SC_CURSOR_DIR:-$CURSOR_DIR}/templates/growing"

if [[ ! -d "$GROWTH_DIR" ]]; then
  mkdir -p "$GROWTH_DIR"
  if [[ -d "$TEMPLATE_DIR" ]]; then
    sc_copy_tree "$TEMPLATE_DIR" "$GROWTH_DIR"
  else
    mkdir -p "$GROWTH_DIR/learn" "$GROWTH_DIR/archive" "$GROWTH_DIR/rules/local" \
      "$GROWTH_DIR/logs" "$GROWTH_DIR/perception" "$GROWTH_DIR/session"
  fi
fi

mkdir -p "$GROWTH_DIR/learn" "$GROWTH_DIR/archive" "$GROWTH_DIR/rules/local" \
  "$GROWTH_DIR/logs" "$GROWTH_DIR/perception" "$GROWTH_DIR/session"

if [[ ! -f "$GROWTH_DIR/README.md" && -f "$TEMPLATE_DIR/README.md" ]]; then
  cp "$TEMPLATE_DIR/README.md" "$GROWTH_DIR/README.md"
fi

# Seed learn/*.md from template (idempotent — never overwrite existing)
if [[ -d "$TEMPLATE_DIR/learn" ]]; then
  for stub in "$TEMPLATE_DIR/learn"/*.md; do
    [[ -f "$stub" ]] || continue
    dest="$GROWTH_DIR/learn/$(basename "$stub")"
    if [[ ! -f "$dest" ]]; then
      cp "$stub" "$dest"
    fi
  done
fi

# Seed session/persona.json + aliases.json (idempotent)
if [[ -f "$TEMPLATE_DIR/session/persona.json" && ! -f "$GROWTH_DIR/session/persona.json" ]]; then
  mkdir -p "$GROWTH_DIR/session"
  cp "$TEMPLATE_DIR/session/persona.json" "$GROWTH_DIR/session/persona.json"
fi
if [[ -f "$TEMPLATE_DIR/session/aliases.json" && ! -f "$GROWTH_DIR/session/aliases.json" ]]; then
  mkdir -p "$GROWTH_DIR/session"
  cp "$TEMPLATE_DIR/session/aliases.json" "$GROWTH_DIR/session/aliases.json"
fi

if [[ -f "$TEMPLATE_DIR/rules/local/README.md" && ! -f "$GROWTH_DIR/rules/local/README.md" ]]; then
  cp "$TEMPLATE_DIR/rules/local/README.md" "$GROWTH_DIR/rules/local/README.md"
fi

if [[ -f "$TEMPLATE_DIR/project-profile.example.json" && ! -f "$GROWTH_DIR/project-profile.example.json" ]]; then
  cp "$TEMPLATE_DIR/project-profile.example.json" "$GROWTH_DIR/project-profile.example.json"
fi
if [[ -f "$TEMPLATE_DIR/project-profile.schema.json" && ! -f "$GROWTH_DIR/project-profile.schema.json" ]]; then
  cp "$TEMPLATE_DIR/project-profile.schema.json" "$GROWTH_DIR/project-profile.schema.json"
fi

# Legacy migration: root plan.md / archive/
if [[ -f "$PROJECT_ROOT/plan.md" && ! -f "$GROWTH_DIR/plan.md" ]]; then
  mv "$PROJECT_ROOT/plan.md" "$GROWTH_DIR/plan.md"
fi
if [[ -d "$PROJECT_ROOT/archive" && ! -d "$GROWTH_DIR/archive" ]] || \
   { [[ -d "$PROJECT_ROOT/archive" ]] && [[ -z "$(ls -A "$GROWTH_DIR/archive" 2>/dev/null || true)" ]]; }; then
  if [[ -d "$PROJECT_ROOT/archive" ]] && [[ "$(ls -A "$PROJECT_ROOT/archive" 2>/dev/null || true)" != "" ]]; then
    mkdir -p "$GROWTH_DIR/archive"
    mv "$PROJECT_ROOT/archive"/* "$GROWTH_DIR/archive/" 2>/dev/null || true
    rmdir "$PROJECT_ROOT/archive" 2>/dev/null || true
  fi
fi

# Symlink rules/local for Cursor globs
CURSOR_LOCAL="$PROJECT_ROOT/.cursor/rules/local"
if [[ -d "$GROWTH_DIR/rules/local" && ! -L "$CURSOR_LOCAL" ]]; then
  if [[ ! -e "$CURSOR_LOCAL" ]] || { [[ -d "$CURSOR_LOCAL" ]] && \
    [[ "$(find "$CURSOR_LOCAL" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')" -le 1 ]]; }; then
    rm -rf "$CURSOR_LOCAL"
    mkdir -p "$(dirname "$CURSOR_LOCAL")"
    # Windows / Git Bash 可能无符号链接权限：失败必须降级为目录副本，不能让 hook 中断（set -e）
    if ! ln -sf "../../.growing/rules/local" "$CURSOR_LOCAL" 2>/dev/null; then
      mkdir -p "$CURSOR_LOCAL"
      cp "$GROWTH_DIR/rules/local/README.md" "$CURSOR_LOCAL/README.md" 2>/dev/null \
        || cp "$TEMPLATE_DIR/rules/local/README.md" "$CURSOR_LOCAL/README.md" 2>/dev/null \
        || true
    fi
  fi
fi

SC_HOOK_CURSOR_DIR="$CURSOR_DIR"
sc_bootstrap_onekey_start "$PROJECT_ROOT" "${SC_CURSOR_DIR:-$CURSOR_DIR}" "$SC_ONEKEY_BOOTSTRAP"

echo "$INPUT"
