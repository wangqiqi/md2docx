#!/usr/bin/env bash
# Smoke-test install-super-cursor.sh (temp dirs only; no side effects on repo)
# skills-bundle full|core 契约 → verify-install-skills-bundle.sh（非本脚本；install 默认 full）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CURSOR_DIR="$ROOT/.cursor"
# shellcheck source=../lib/temp-cleanup.sh
source "$CURSOR_DIR/lib/temp-cleanup.sh"
# shellcheck source=../lib/smoke-git.sh
source "$CURSOR_DIR/lib/smoke-git.sh"
sc_temp_trap_cleanup
INSTALL="$ROOT/install-super-cursor.sh"
sc_mktemp_dir sc-install-smoke
TMP_ROOT="$SC_MKTEMP_LAST"
FAIL=0

fail() { echo "FAIL $1"; FAIL=$((FAIL + 1)); }

# set -e 下"哪一行中止"必须可见 —— 曾出现「无 FAIL 行、秒退」，导致 macOS/Windows 失败无法定位
trap 'echo "FAIL install smoke aborted at line $LINENO (unguarded command under set -e)" >&2' ERR
ok() { echo "OK  $1"; }

assert_file() {
  local path="$1" label="$2"
  [[ -f "$path" ]] && ok "$label" || fail "$label (missing $path)"
}

assert_absent() {
  local path="$1" label="$2"
  [[ ! -e "$path" ]] && ok "$label" || fail "$label (unexpected $path)"
}

assert_grep() {
  local file="$1" pattern="$2" label="$3"
  grep -qE "$pattern" "$file" 2>/dev/null && ok "$label" || fail "$label ($file)"
}

# 安装必须「失败可见」：捕获输出，失败时打 FAIL 并回显尾部，且不中止整个 smoke
run_install() {
  local label="$1" out="$2"
  shift 2
  local rc=0
  "$INSTALL" "$@" >"$out" 2>&1 || rc=$?
  if [[ "$rc" -eq 0 ]]; then
    ok "$label"
  else
    fail "$label (installer exit $rc)"
    echo "  ---- installer output (tail) ----" >&2
    tail -15 "$out" 2>/dev/null | sed 's/^/  | /' >&2
    echo "  --------------------------------" >&2
  fi
  return 0
}

assert_git_ignored() {
  local dir="$1" file="$2" label="$3"
  sc_smoke_git_init_repo "$dir" "$ROOT"
  (
    cd "$dir"
    git add -A
    if git status --short | grep -qF "$file"; then
      echo "FAIL $label (would be tracked)"
      exit 1
    fi
    echo "OK  $label"
  ) || FAIL=$((FAIL + 1))
}

[[ -x "$INSTALL" ]] || { echo "FAIL install script not executable: $INSTALL"; exit 1; }

echo "=== install smoke ==="

# 1. full · empty target
FULL="$TMP_ROOT/full-empty"
run_install "full: install into empty target" "$TMP_ROOT/full.out" "$FULL" --profile full
assert_file "$FULL/.growing/plan.md" "full: .growing/plan.md copied"
assert_file "$FULL/.growing/learn/plan-conventions.md" "full: learn seeds"
# B4：安装输出必须把「首次必做 /learn」讲清楚，否则闸门与验收会空转
assert_grep "$TMP_ROOT/full.out" '/learn' "full: output points at /learn first-run"
assert_grep "$FULL/.gitignore" '.growing/' "full: gitignore .growing/"
assert_absent "$FULL/plan.md" "full: no root plan.md"
assert_grep "$FULL/.growing/plan.md" '执行顺序' "full: plan template 执行顺序"
# Windows/Git Bash 的 ln -s 可能退化为复制 → 断言「可达」而非「必须是符号链接」
if [[ -L "$FULL/.cursor/rules/local" ]] || [[ -e "$FULL/.cursor/rules/local/README.md" ]]; then
  ok "full: rules/local resolvable"
else
  fail "full: rules/local not resolvable"
fi
(
  cd "$FULL"
  bash .cursor/bin/runner.sh plan-check >/dev/null 2>&1
) && fail "full: plan-check must report not-ready before approval" \
  || ok "full: plan-check reports not-ready before approval"
# 闸门必须 fail-closed：模板默认 PLAN_APPROVED:(none) 不得放行（P0-3 回归）
(
  cd "$FULL"
  bash .cursor/bin/runner.sh gate-check >/dev/null 2>&1
) && fail "full: gate-check must BLOCK before PLAN_APPROVED" \
  || ok "full: gate-check blocks unapproved plan"
assert_grep "$FULL/.cursor/bin/runner.sh" 'release-tag' "full: runner.sh release-tag"
assert_file "$FULL/onekey_start.sh" "full: onekey_start.sh bootstrapped at install"
[[ -x "$FULL/onekey_start.sh" ]] && ok "full: onekey_start.sh executable" \
  || fail "full: onekey_start.sh not executable"
onekey_hash="$(sha256sum "$FULL/onekey_start.sh" | awk '{print $1}')"

# Windows/Git Bash 回归：cp/rsync 把 .cursor 根门面落成实体文件/目录后，二次 install 须恢复 symlink
# （CI windows 腿多次在此失败：AGENTS.md · agents 等 — 本地先抓，勿直接 push 烧 Actions）
# 与 rules/local 一致：symlink 优先；Windows 无权限时允许与 harness/core 一致的实体副本
smoke_facade_resolved() {
  local proj="$1" name="$2" label="$3"
  local cur="$proj/.cursor"
  local core="$cur/harness/core/$name"
  local path="$cur/$name"
  if [[ -L "$path" ]]; then
    ok "$label (symlink)"
    return 0
  fi
  if [[ -f "$core" ]]; then
    if [[ -f "$path" ]] && diff -q "$path" "$core" >/dev/null 2>&1; then
      ok "$label (materialized file)"
      return 0
    fi
  elif [[ -d "$core" ]]; then
    if [[ -d "$path" ]] && diff -qr "$path" "$core" >/dev/null 2>&1; then
      ok "$label (materialized dir)"
      return 0
    fi
  fi
  fail "$label (not symlink or equivalent to harness/core)"
}

smoke_corrupt_ide_facades() {
  local proj="$1"
  local cur="$proj/.cursor"
  local core="$cur/harness/core"
  local name
  for name in agents bin config docs lib rules skills templates; do
    [[ -e "$cur/$name" || -L "$cur/$name" ]] || continue
    rm -rf "$cur/$name"
    cp -a "$core/$name" "$cur/$name"
  done
  for name in AGENTS.md README.md verify-super-cursor.sh verify-system.sh; do
    [[ -e "$cur/$name" || -L "$cur/$name" ]] || continue
    rm -f "$cur/$name"
    cp -a "$core/$name" "$cur/$name"
  done
  if [[ -d "$cur/adaptors/cursor/hooks" ]]; then
    rm -rf "$cur/hooks" "$cur/hooks.json"
    cp -a "$cur/adaptors/cursor/hooks" "$cur/hooks"
    cp -a "$cur/adaptors/cursor/hooks.json" "$cur/hooks.json"
  fi
}
smoke_corrupt_ide_facades "$FULL"
run_install "full: reinstall after Windows-like facade copies" "$TMP_ROOT/full-facade.out" "$FULL" --profile full
smoke_facade_resolved "$FULL" agents "full: agents after facade reinstall"
smoke_facade_resolved "$FULL" AGENTS.md "full: AGENTS.md after facade reinstall"

run_install "full: reinstall idempotent onekey" "$TMP_ROOT/full-reinstall.out" "$FULL" --profile full
onekey_hash2="$(sha256sum "$FULL/onekey_start.sh" | awk '{print $1}')"
[[ "$onekey_hash" == "$onekey_hash2" ]] && ok "full: reinstall does not overwrite onekey_start.sh" \
  || fail "full: reinstall overwrote onekey_start.sh"

# 2. lite · no --copy-plan
LITE="$TMP_ROOT/lite-no-plan"
run_install "lite: install" "$TMP_ROOT/lite.out" "$LITE" --profile lite
assert_absent "$LITE/.growing/plan.md" "lite: no plan without --copy-plan"
assert_grep "$LITE/.gitignore" '.growing/' "lite: gitignore .growing/"

# 3. lite · --copy-plan
LITE_COPY="$TMP_ROOT/lite-copy"
run_install "lite --copy-plan: install" "$TMP_ROOT/lite-copy.out" "$LITE_COPY" --profile lite --copy-plan
assert_file "$LITE_COPY/.growing/plan.md" "lite --copy-plan: .growing/plan.md"

# 4. merge existing .gitignore
EXISTING="$TMP_ROOT/existing"
mkdir -p "$EXISTING"
echo 'node_modules/' >"$EXISTING/.gitignore"
run_install "merge: install onto existing .gitignore" "$TMP_ROOT/existing.out" "$EXISTING" --profile full
assert_grep "$EXISTING/.gitignore" 'node_modules' "merge: keeps node_modules/"
assert_grep "$EXISTING/.gitignore" '.growing/' "merge: adds .growing/"

# 5. .growing not tracked after git init
assert_git_ignored "$FULL" ".growing/plan.md" "full: .growing/plan.md gitignored"

# 6. --here / auto git root from subdirectory
HERE_ROOT="$TMP_ROOT/here-project"
mkdir -p "$HERE_ROOT/src/pkg"
sc_smoke_git_init_repo "$HERE_ROOT" "$ROOT"
HERE_OUT="$TMP_ROOT/here.out"
if ( cd "$HERE_ROOT/src/pkg" && "$INSTALL" --replace >"$HERE_OUT" 2>&1 ); then
  ok "here: install from nested dir"
else
  fail "here: install from nested dir (see output)"
  tail -10 "$HERE_OUT" 2>/dev/null | sed 's/^/  | /' >&2
fi
assert_file "$HERE_ROOT/.cursor/rules/core.mdc" "here: .cursor at git root"

# 7. --setup-shell
HOME_SAVE="$HOME"
export HOME="$TMP_ROOT/home-setup"
mkdir -p "$HOME"
touch "$HOME/.bashrc"
run_install "setup-shell" "$TMP_ROOT/setup-shell.out" --setup-shell
grep -qF 'SUPER_CURSOR_HOME=' "$HOME/.bashrc" && ok "setup-shell: SUPER_CURSOR_HOME" || fail "setup-shell: SUPER_CURSOR_HOME"
grep -qF 'install-super-cursor' "$HOME/.bashrc" && ok "setup-shell: alias" || fail "setup-shell: alias"
export HOME="$HOME_SAVE"

# 8. skills-bundle core
CORE_BUNDLE="$TMP_ROOT/core-bundle"
run_install "core bundle: install" "$TMP_ROOT/core-bundle.out" "$CORE_BUNDLE" --profile lite --skills-bundle core
core_n="$(find -L "$CORE_BUNDLE/.cursor/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
[[ "$core_n" == "23" ]] && ok "core bundle: 23 skills" || fail "core bundle: skills=$core_n (expected 23)"
assert_absent "$CORE_BUNDLE/.cursor/skills/week/SKILL.md" "core bundle: no week skill"

# 9. adaptor dsh alongside .cursor
DSH="$TMP_ROOT/dsh-adaptor"
run_install "adaptor dsh: install" "$TMP_ROOT/dsh.out" "$DSH" --profile lite --adaptor dsh
assert_file "$DSH/.dsh/rules/core.mdc" "adaptor dsh: .dsh/rules/core.mdc"
assert_file "$DSH/.cursor/rules/core.mdc" "adaptor dsh: .cursor still installed"
assert_absent "$DSH/.dsh/hooks.json" "adaptor dsh: no hooks.json in .dsh"

# 10. adaptor kiro rules export
KIRO="$TMP_ROOT/kiro-adaptor"
run_install "adaptor kiro: install" "$TMP_ROOT/kiro.out" "$KIRO" --profile lite --adaptor kiro
assert_file "$KIRO/.kiro/rules/core.mdc" "adaptor kiro: .kiro/rules/core.mdc"
assert_file "$KIRO/.kiro/RULES.md" "adaptor kiro: RULES.md index"
assert_absent "$KIRO/.kiro/skills" "adaptor kiro: no skills/"

# 11. adaptor opencode
OC="$TMP_ROOT/opencode-adaptor"
run_install "adaptor opencode: install" "$TMP_ROOT/opencode.out" "$OC" --profile lite --adaptor opencode
assert_file "$OC/.opencode/rules/core.mdc" "adaptor opencode: .opencode/rules/core.mdc"
assert_absent "$OC/.opencode/hooks.json" "adaptor opencode: no hooks.json"

# 12. self-replace guard（P0-4）：目标 == 母版目录时必须拒绝且不删 .cursor/
# 需要符号链接来构造「source==target」；无符号链接权限的平台（Windows/Git Bash）显式 SKIP，
# 而不是让裸 ln -s 在 set -e 下中止整个 smoke（曾导致 Windows 腿秒退且无 FAIL 行）
SELF="$TMP_ROOT/self-replace"
mkdir -p "$SELF"
cp "$INSTALL" "$SELF/install-super-cursor.sh"
if ln -s "$ROOT/.cursor" "$SELF/.cursor" 2>/dev/null; then
  (
    cd "$SELF"
    env -u SUPER_CURSOR_HOME -u CURSOR_AI_HOME \
      bash ./install-super-cursor.sh "$SELF" --replace >/dev/null 2>&1
  ) && fail "self-replace: must refuse source==target" || ok "self-replace: refuses source==target"
  assert_file "$SELF/.cursor/hooks.json" "self-replace: .cursor intact"
  assert_file "$ROOT/.cursor/hooks.json" "self-replace: mother repo untouched"
else
  echo "SKIP  self-replace guard（本平台无符号链接权限，无法构造 source==target）"
fi

echo "---"
if [[ "$FAIL" -eq 0 ]]; then
  echo "install smoke passed."
  exit 0
fi
echo "$FAIL install smoke check(s) failed."
exit 1
