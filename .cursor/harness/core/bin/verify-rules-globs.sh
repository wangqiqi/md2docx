#!/usr/bin/env bash
# Rules frontmatter + glob 语义回归（母版）
#
# 覆盖三类真实事故：
#   1. frontmatter 键非法 / 缺 description
#   2. Cursor 未文档化的 brace glob（`**/*.{ts,tsx}`）静默不生效
#   3. glob 与真实仓结构不符：plan 闸门不加载 · 误命中（**/app/** 命中 Python/C++）· 零命中
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"
# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-rules-globs"

echo "=== verify-rules-globs ==="

vc_py "$CUR" <<'PY'
import re
import sys
from pathlib import Path

cur = Path(sys.argv[1])
fails = 0
okc = 0


def fail(msg):
    global fails
    print(f"FAIL {msg}")
    fails += 1


def ok(msg):
    global okc
    print(f"OK  {msg}")
    okc += 1


def parse_frontmatter(text):
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 4)
    if end < 0:
        return None
    block = text[4:end]
    data = {}
    key = None
    for raw in block.splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$", raw)
        if m:
            key, val = m.group(1), m.group(2).strip()
            data[key] = [] if val == "" else [val.strip('"').strip("'")]
            continue
        m = re.match(r"^\s*-\s*(.+?)\s*$", raw)
        if m and key:
            data[key].append(m.group(1).strip().strip('"').strip("'"))
            continue
        fail(f"unparsable frontmatter line in {raw!r}")
    return data


VALID_KEYS = {"description", "globs", "alwaysApply"}


def to_regex(pattern):
    # Cursor glob → 正则：**/ 可跨目录，* 不跨 '/'
    out = []
    i = 0
    while i < len(pattern):
        c = pattern[i]
        if pattern.startswith("**/", i):
            out.append("(?:.*/)?")
            i += 3
            continue
        if pattern.startswith("**", i):
            out.append(".*")
            i += 2
            continue
        if c == "*":
            out.append("[^/]*")
        elif c == "?":
            out.append("[^/]")
        else:
            out.append(re.escape(c))
        i += 1
    return re.compile("^" + "".join(out) + "$")


rules = {}
for path in sorted((cur / "rules").rglob("*.mdc")):
    # Windows 会返回 `rules\x.mdc` → 必须归一为 POSIX，否则与字面量比较全部不中
    rel = path.relative_to(cur).as_posix()
    text = path.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    if fm is None:
        fail(f"{rel}: missing YAML frontmatter")
        continue
    bad = set(fm) - VALID_KEYS
    if bad:
        fail(f"{rel}: invalid frontmatter key(s) {sorted(bad)}")
    if "description" not in fm:
        fail(f"{rel}: missing description")
    if fm.get("alwaysApply") and fm["alwaysApply"][0] not in ("true", "false"):
        fail(f"{rel}: alwaysApply must be unquoted boolean")
    for g in fm.get("globs", []):
        if "{" in g or "}" in g:
            fail(f"{rel}: brace glob {g!r} is not documented by Cursor; enumerate extensions")
    rules[rel] = [g.replace("\\", "/") for g in fm.get("globs", [])]

if rules:
    ok(f"frontmatter + keys valid ({len(rules)} rules)")

# 0. 路径分隔符回归：key 必须是 POSIX（Windows 下 str(relative_to) 会泄露反斜杠）
non_posix = [k for k in rules if "\\" in k]
if non_posix:
    fail(f"non-POSIX rule keys (Windows separator leak): {non_posix[:3]} — 用 .as_posix()")

# 1. plan 闸门规则必须能命中真实 plan 位置
PLAN_GATE = [
    "rules/feedback/verify.mdc",
    "rules/feedback/changelog.mdc",
    "rules/execution/ia.mdc",
    "rules/execution/delivery.mdc",
    "rules/execution/ux.mdc",
]
for rel in PLAN_GATE:
    if ".growing/plan.md" in rules.get(rel, []):
        ok(f"{rel} globs .growing/plan.md")
    else:
        fail(f"{rel} does not glob .growing/plan.md (plan gate never attaches)")

# 2. 禁用已被证伪的宽 glob
BANNED = ("**/src/**", "**/app/**", "**/*List*")
for rel, globs in rules.items():
    for g in globs:
        if g in BANNED:
            fail(f"{rel}: banned false-positive glob {g!r}")

# 3. 真实栈文件匹配断言（fixture 路径 = 项目内相对路径）
CASES = [
    # (rule, path, should_match, why)
    ("rules/tech/nextjs.mdc", "app/page.tsx", True, "Next.js App Router cell"),
    ("rules/tech/nextjs.mdc", "src/app/main.py", False, "python-fastapi app dir"),
    ("rules/tech/nextjs.mdc", "include/app/greet.hpp", False, "cpp-cmake app dir"),
    ("rules/execution/api.mdc", "internal/handler/health.go", True, "go-api handler"),
    ("rules/execution/api.mdc", "src/main.rs", False, "rust src is not an API surface"),
    ("rules/execution/error-context.mdc", "internal/handler/health.go", True, "go-api handler"),
    ("rules/tech/cpp.mdc", "include/app/greet.hpp", True, "C++ header"),
    ("rules/execution/data-list.mdc", "CMakeLists.txt", False, "CMake build file"),
    ("rules/execution/ux.mdc", "src/main.rs", False, "rust src is not UI"),
    ("rules/execution/ux.mdc", "src/components/Button.tsx", True, "UI component"),
    ("rules/execution/delivery.mdc", "src/greet.cpp", False, "C++ src is not deliverable UI"),
    ("rules/tech/nextjs.mdc", "src/app/dashboard/page.tsx", True, "Next.js src/app layout"),
]
for rel, path, want, why in CASES:
    if rel not in rules:
        fail(f"{rel} missing (fixture references a renamed rule)")
        continue
    matched = any(to_regex(g).match(path) for g in rules[rel])
    if matched == want:
        ok(f"{rel} {'matches' if want else 'ignores'} {path} ({why})")
    else:
        verb = "should match but does not" if want else "should ignore but matches"
        fail(f"{rel} {verb}: {path} ({why})")

print("---")
if fails:
    print(f"{fails} check(s) failed.")
    sys.exit(1)
print("rules globs check passed.")
PY

vc_summary "verify-rules-globs passed."
