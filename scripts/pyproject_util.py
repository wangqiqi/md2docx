"""Read pyproject.toml on Python 3.8+ (tomllib 3.11+ or tomli fallback)."""

from __future__ import annotations

from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def loads_toml(text: str) -> dict[str, Any]:
    try:
        import tomllib

        return tomllib.loads(text)
    except ModuleNotFoundError:
        import tomli

        return tomli.loads(text)


def load_pyproject(root: Path | None = None) -> dict[str, Any]:
    base = root or ROOT
    text = (base / "pyproject.toml").read_text(encoding="utf-8")
    return loads_toml(text)


def project_version(root: Path | None = None) -> str:
    return str(load_pyproject(root)["project"]["version"])
