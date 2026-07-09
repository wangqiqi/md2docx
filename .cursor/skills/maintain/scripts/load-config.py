#!/usr/bin/env python3
"""Merge maintain config and emit bash arrays for dev-maintain.sh."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


def deep_merge(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    out = dict(base)
    for key, value in override.items():
        if key in out and isinstance(out[key], list) and isinstance(value, list):
            if key == "protected_dirs":
                seen = set(out[key])
                out[key] = out[key] + [x for x in value if x not in seen]
            else:
                out[key] = value
        else:
            out[key] = value
    return out


def load_json(path: Path) -> dict[str, Any]:
    if not path.is_file():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def shell_quote(value: str) -> str:
    return "'" + value.replace("'", "'\"'\"'") + "'"


def emit_bash(config: dict[str, Any]) -> None:
    protected = config.get("protected_dirs", [])
    cache_dirs = config.get("cache_dirs", [])
    extra_cache = config.get("extra_cache_dirs", [])
    build_dirs = config.get("build_artifact_dirs", [])
    tmp_globs = config.get("build_artifact_tmp_globs", [])
    installer_dirs = config.get("installer_dirs", [])

    print("PROTECTED_DIRS=(")
    for item in protected:
        print(f"  {shell_quote(str(item))}")
    print(")")

    print("CACHE_DIRS=(")
    for item in cache_dirs:
        print(f"  {shell_quote(str(item))}")
    print(")")

    print("EXTRA_CACHE_DIRS=(")
    for item in extra_cache:
        print(f"  {shell_quote(str(item))}")
    print(")")

    print("BUILD_ARTIFACT_DIRS=(")
    for item in build_dirs:
        print(f"  {shell_quote(str(item))}")
    print(")")

    print("BUILD_ARTIFACT_TMP_GLOBS=(")
    for item in tmp_globs:
        print(f"  {shell_quote(str(item))}")
    print(")")

    print(f"INSTALLER_DIRS_JSON={shell_quote(json.dumps(installer_dirs, ensure_ascii=False))}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--default", type=Path, required=True)
    parser.add_argument("--override", type=Path, default=None)
    parser.add_argument("--format", choices=("bash", "json"), default="bash")
    args = parser.parse_args()

    config = load_json(args.default)
    if args.override and args.override.is_file():
        config = deep_merge(config, load_json(args.override))

    if args.format == "json":
        print(json.dumps(config, ensure_ascii=False, indent=2))
    else:
        emit_bash(config)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
