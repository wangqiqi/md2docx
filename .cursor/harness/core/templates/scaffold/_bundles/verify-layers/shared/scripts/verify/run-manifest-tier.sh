#!/usr/bin/env bash
# 按 manifest.tsv 运行指定 tier（累积：l2-standard ⊇ l2-core ⊇ …）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
TIER="${1:?usage: run-manifest-tier.sh l2-core|l2-standard|l3}"
MANIFEST="${VERIFY_MANIFEST:-$ROOT/scripts/verify/manifest.tsv}"
PARALLEL="${VERIFY_SLICE_PARALLEL:-4}"

tier_rank() {
  case "$1" in
    l2-core) echo 1 ;;
    l2-standard) echo 2 ;;
    l3) echo 3 ;;
    *) echo 0 ;;
  esac
}

want_rank="$(tier_rank "$TIER")"
[[ "$want_rank" -gt 0 ]] || { echo "FAIL: unknown tier=$TIER" >&2; exit 1; }

[[ -f "$MANIFEST" ]] || { echo "FAIL: missing manifest $MANIFEST" >&2; exit 1; }

PROFILE_LIB="$ROOT/.cursor/lib/project-profile.sh"
if [[ -f "$PROFILE_LIB" ]]; then
  # shellcheck source=/dev/null
  source "$PROFILE_LIB"
  if declare -f sc_profile_tier_allowed >/dev/null 2>&1; then
    if ! sc_profile_tier_allowed "$ROOT" "$TIER"; then
      echo "FAIL: project-profile verify.enabled_tiers blocks tier=${TIER} (or set VERIFY_IGNORE_PROFILE=1)" >&2
      exit 1
    fi
  fi
fi

load_bundle_commands() {
  local rel="$1"
  local full="$ROOT/scripts/verify/$rel"
  [[ -f "$full" ]] || full="$ROOT/$rel"
  [[ -f "$full" ]] || { echo "FAIL: missing bundle-commands file $rel" >&2; exit 1; }
  _lines=()
  while IFS= read -r line; do
    _lines+=("$line")
  done < <(grep -v '^[[:space:]]*#' "$full" | grep -v '^[[:space:]]*$' || true)
  if [[ ${#_lines[@]} -eq 0 ]]; then
    echo "FAIL: empty bundle-commands $rel (tier=$TIER)" >&2
    exit 1
  fi
  BUNDLE_CMDS+=("${_lines[@]}")
}

ROWS=()
while IFS= read -r line; do
  ROWS+=("$line")
done < <(awk -F'\t' 'NF>=3 && $0 !~ /^#/ { print }' "$MANIFEST")
if [[ ${#ROWS[@]} -eq 0 ]]; then
  echo "FAIL: manifest has no data rows: $MANIFEST" >&2
  exit 1
fi

# Do not name arrays BASH_CMDS — clashes with bash's special history array (appends become empty).
MANIFEST_BASH_CMDS=()
BUNDLE_CMDS=()
matched=0

for row in "${ROWS[@]}"; do
  IFS=$'\t' read -r row_tier type target stacks <<< "$row"
  row_tier="${row_tier//$'\r'/}"
  type="${type//$'\r'/}"
  target="${target//$'\r'/}"
  stacks="${stacks//$'\r'/}"
  r="$(tier_rank "$row_tier")"
  [[ "$r" -gt 0 && "$r" -le "$want_rank" ]] || continue
  if declare -f sc_profile_stacks_allow_row >/dev/null 2>&1; then
    if ! sc_profile_stacks_allow_row "$ROOT" "${stacks:-*}"; then
      echo "[verify] SKIP profile stacks=${stacks:-*} target=$target"
      continue
    fi
  fi
  matched=$((matched + 1))
  case "$type" in
    bash)
      MANIFEST_BASH_CMDS+=("bash scripts/verify/$target")
      ;;
    command)
      MANIFEST_BASH_CMDS+=("$target")
      ;;
    bundle-commands)
      load_bundle_commands "$target"
      ;;
    *)
      echo "FAIL: unknown manifest type=$type (row: $row)" >&2
      exit 1
      ;;
  esac
done

if [[ "$matched" -eq 0 ]]; then
  echo "FAIL: no manifest rows for tier=$TIER (cumulative) in $MANIFEST" >&2
  exit 1
fi

run_one() {
  local cmd="$1"
  echo "[verify] manifest: $cmd"
  eval "$cmd"
}

ALL_CMDS=()
if ((${#MANIFEST_BASH_CMDS[@]} > 0)); then
  ALL_CMDS+=("${MANIFEST_BASH_CMDS[@]}")
fi
if ((${#BUNDLE_CMDS[@]} > 0)); then
  ALL_CMDS+=("${BUNDLE_CMDS[@]}")
fi
if [[ ${#ALL_CMDS[@]} -eq 0 ]]; then
  echo "FAIL: no commands collected for tier=$TIER" >&2
  exit 1
fi

# Parallel: -n 1 passes each null-delimited command as a single $1 (never use -I{} — it word-splits).
if [[ "$PARALLEL" -gt 1 && ${#ALL_CMDS[@]} -gt 1 ]]; then
  export -f run_one
  printf '%s\0' "${ALL_CMDS[@]}" | xargs -0 -n 1 -P "$PARALLEL" bash -c 'run_one "$1"' bash
else
  for cmd in "${ALL_CMDS[@]}"; do
    run_one "$cmd"
  done
fi

echo "[verify] manifest tier=$TIER OK ($matched rows)"
