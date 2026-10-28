#!/usr/bin/env bash
# Config 校验 —— 未知键 / 类型错误即 FAIL
#
# 为什么需要：`workflow.json` 写错一个键（如 `workflow.release.mode` 而非 `release.mode`）
# 不会报错，只会**静默回退默认值**，行为与预期不符却毫无信号。
#
# 由 `config/schema.json` 声明允许的嵌套键与类型；角色/版本等自由结构用 "object"。
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-config"

echo "=== verify-config ==="

vc_py "$CUR" <<'PY'
import json
import sys
from pathlib import Path

cur = Path(sys.argv[1])
schema_path = cur / "config/schema.json"

if not schema_path.is_file():
    print("FAIL missing config/schema.json — config guard would be disabled")
    sys.exit(1)

schema = json.loads(schema_path.read_text(encoding="utf-8"))
schema.pop("_comment", None)
fails = []
checked = 0


def type_ok(value, expected):
    if expected == "string":
        return isinstance(value, str)
    if expected == "bool":
        return isinstance(value, bool)
    if expected == "int":
        return isinstance(value, int) and not isinstance(value, bool)
    if expected == "array":
        return isinstance(value, list)
    if expected == "object":
        return isinstance(value, dict)
    return False


def validate(conf, spec, prefix, rel):
    for key, value in conf.items():
        if key.startswith("_"):          # 注释键（_comment 等）不参与校验
            continue
        dotted = f"{prefix}{key}"
        if key not in spec:
            fails.append(f"{rel}: unknown key '{dotted}' (typo? silently falls back to defaults)")
            continue
        expected = spec[key]
        if isinstance(expected, dict):
            if not isinstance(value, dict):
                fails.append(f"{rel}: '{dotted}' should be an object, got {type(value).__name__}")
                continue
            validate(value, expected, f"{dotted}.", rel)
        elif not type_ok(value, expected):
            fails.append(f"{rel}: '{dotted}' should be {expected}, got {type(value).__name__}")


for rel, spec in sorted(schema.items()):
    path = cur / "config" / rel
    if not path.is_file():
        fails.append(f"missing config/{rel}")
        continue
    try:
        conf = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fails.append(f"{rel}: invalid JSON ({exc})")
        continue
    checked += 1
    validate(conf, spec, "", rel)

if fails:
    for f in fails:
        print("FAIL config:", f)
    sys.exit(1)
print(f"OK  config schema valid ({checked} files)")
PY

vc_summary "verify-config passed."
