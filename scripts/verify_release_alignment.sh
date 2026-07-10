#!/usr/bin/env bash
# 发布门面一致性门禁：pyproject / runtime / README / tag / license / CHANGELOG
# 用法:
#   bash scripts/verify_release_alignment.sh
#   EXPECT_TAG=v0.5.49 bash scripts/verify_release_alignment.sh   # 打 tag / publish 前
# CI: quality 与 publish.yml 均调用本脚本
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"
EXPECT_TAG="${EXPECT_TAG:-${GITHUB_REF_NAME:-}}"

echo "=== release alignment verify ==="

"$PYTHON" - <<'PY' "$ROOT" "$EXPECT_TAG"
from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

root = Path(sys.argv[1])
expect_tag = sys.argv[2].strip()

pyproject = tomllib.loads((root / "pyproject.toml").read_text(encoding="utf-8"))
version = str(pyproject["project"]["version"])
license_value = pyproject["project"].get("license")

errors: list[str] = []

if not isinstance(license_value, dict) or license_value.get("text") != "MIT":
    errors.append(
        "pyproject.toml: project.license 须为 {text = \"MIT\"}（兼容 Python 3.8 / setuptools<77）"
    )

readme = (root / "README.md").read_text(encoding="utf-8")
badge_match = re.search(r"version-([0-9]+\.[0-9]+\.[0-9]+)-blue", readme)
if not badge_match:
    errors.append("README.md: 未找到 version badge")
elif badge_match.group(1) != version:
    errors.append(f"README badge {badge_match.group(1)!r} != pyproject {version!r}")

changelog = (root / "CHANGELOG.md").read_text(encoding="utf-8")
if f"## [{version}]" not in changelog:
    errors.append(f"CHANGELOG.md: 缺少 ## [{version}] 段落")

unreleased_block = changelog.split("## [Unreleased]", 1)
if expect_tag and len(unreleased_block) > 1:
    before_next = unreleased_block[1].split("\n## [", 1)[0]
    bullets = [
        line.strip()
        for line in before_next.splitlines()
        if line.strip().startswith("- ")
    ]
    if bullets:
        errors.append(
            f"CHANGELOG [Unreleased] 仍有 {len(bullets)} 条未折叠条目，打 tag 前须归入 [{version}]"
        )

if expect_tag:
    tag_version = expect_tag.removeprefix("v")
    if tag_version != version:
        errors.append(
            f"tag {expect_tag!r} -> {tag_version!r} != pyproject version {version!r}"
        )

sys.path.insert(0, str(root / "src"))
import mddocx  # noqa: E402

if mddocx.__version__ != version:
    errors.append(f"mddocx.__version__ {mddocx.__version__!r} != pyproject {version!r}")

if errors:
    print("❌ release alignment failed:", file=sys.stderr)
    for err in errors:
        print(f"  - {err}", file=sys.stderr)
    sys.exit(1)

print(f"OK: pyproject={version} runtime={mddocx.__version__} README badge={version}")
if expect_tag:
    print(f"OK: tag {expect_tag} matches pyproject")
PY

echo "OK: verify_release_alignment passed"
