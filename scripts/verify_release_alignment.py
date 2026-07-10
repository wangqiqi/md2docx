#!/usr/bin/env python3
"""Release facade alignment checks (Python 3.8+)."""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pyproject_util import load_pyproject

SEMVER_TAG = re.compile(r"^v\d+\.\d+\.\d+$")


def main(argv: list[str]) -> int:
    root = Path(argv[1])
    expect_tag = argv[2].strip() if len(argv) > 2 else ""
    if expect_tag and not SEMVER_TAG.match(expect_tag):
        expect_tag = ""

    pyproject = load_pyproject(root)
    version = str(pyproject["project"]["version"])
    license_value = pyproject["project"].get("license")

    errors: list[str] = []

    if not isinstance(license_value, dict) or license_value.get("text") != "MIT":
        errors.append(
            'pyproject.toml: project.license 须为 {text = "MIT"}（兼容 Python 3.8 / setuptools<77）'
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

    if expect_tag:
        unreleased_block = changelog.split("## [Unreleased]", 1)
        if len(unreleased_block) > 1:
            before_next = unreleased_block[1].split("\n## [", 1)[0]
            bullets = [line.strip() for line in before_next.splitlines() if line.strip().startswith("- ")]
            if bullets:
                errors.append(
                    f"CHANGELOG [Unreleased] 仍有 {len(bullets)} 条未折叠条目，打 tag 前须归入 [{version}]"
                )

        tag_version = expect_tag.removeprefix("v")
        if tag_version != version:
            errors.append(f"tag {expect_tag!r} -> {tag_version!r} != pyproject version {version!r}")

    sys.path.insert(0, str(root / "src"))
    import mddocx  # noqa: E402

    if mddocx.__version__ != version:
        errors.append(f"mddocx.__version__ {mddocx.__version__!r} != pyproject {version!r}")

    if errors:
        print("❌ release alignment failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"OK: pyproject={version} runtime={mddocx.__version__} README badge={version}")
    if expect_tag:
        print(f"OK: tag {expect_tag} matches pyproject")
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: verify_release_alignment.py <repo_root> [expect_tag]", file=sys.stderr)
        raise SystemExit(2)
    raise SystemExit(main(sys.argv))
