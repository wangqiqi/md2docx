#!/usr/bin/env bash
# Secrets 扫描 —— 只扫**已跟踪**文件（git ls-files），命中即 FAIL
#
# 为什么需要：`.cursorignore` / `.gitignore` 只防"被读"，不防"被提交"；
#   **security** skill 是人工清单，CI 需要一道机器门禁。
#
# 误报豁免：`.env.example` / 本文档中的示例占位 / `config/denylist.txt`（模式本体）。
set -euo pipefail

CUR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$CUR/.." && pwd)"
# shellcheck source=../lib/verify-common.sh
source "$CUR/lib/verify-common.sh" "verify-secrets"

echo "=== verify-secrets ==="

vc_py "$ROOT" <<'PY'
import re
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])

try:
    tracked = subprocess.run(
        ["git", "-C", str(root), "ls-files"], capture_output=True, text=True, check=True
    ).stdout.split()
except Exception as exc:
    print(f"FAIL git ls-files unavailable: {exc}")
    sys.exit(1)

PATTERNS = [
    (r"AKIA[0-9A-Z]{16}", "AWS access key id"),
    (r"-----BEGIN [A-Z ]*PRIVATE KEY-----", "private key material"),
    (r"gh[pousr]_[A-Za-z0-9]{36,}", "GitHub token"),
    (r"xox[baprs]-[A-Za-z0-9-]{10,}", "Slack token"),
    (r"(?i)\b(api[_-]?key|secret|passwd|password|access[_-]?token)\b\s*[:=]\s*['\"][A-Za-z0-9/+_-]{20,}['\"]", "hardcoded credential"),
]

# 允许出现"看起来像密钥"的示例/文档位置
ALLOW_PATH = re.compile(
    r"(\.env\.example$|\.example$|config/denylist\.txt$|^\.cursor/bin/verify-secrets\.sh$|\.cursor/bin/verify-portability\.sh$)"
)

# 明显是占位符的值（含 xxx / your / example / changeme / <...>）
PLACEHOLDER = re.compile(r"(?i)(xxx+|your[_-]?|example|placeholder|changeme|dummy|redacted|<[^>]+>|\$\{)")

hits = []
for rel in tracked:
    path = root / rel
    if ALLOW_PATH.search(rel) or not path.is_file():
        continue
    # 二进制/大文件跳过
    try:
        text = path.read_text(encoding="utf-8", errors="strict")
    except (UnicodeDecodeError, OSError):
        continue
    if len(text) > 2_000_000:
        continue
    for i, line in enumerate(text.splitlines(), 1):
        if PLACEHOLDER.search(line):
            continue
        for pat, why in PATTERNS:
            if re.search(pat, line):
                hits.append(f"{rel}:{i} {why}")
                break

# 额外：不得跟踪真实 .env（模板 .env.example 允许）
for rel in tracked:
    base = rel.rsplit("/", 1)[-1]
    if base == ".env" or (base.startswith(".env.") and not base.endswith(".example")):
        hits.append(f"{rel} tracked .env file (should be gitignored)")

if hits:
    for h in hits:
        print("FAIL secret:", h)
    sys.exit(1)
print(f"OK  no secrets in {len(tracked)} tracked files")
PY

vc_summary "verify-secrets passed."
