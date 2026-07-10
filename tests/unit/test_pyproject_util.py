"""pyproject_util works across Python versions."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

from pyproject_util import load_pyproject, project_version  # noqa: E402


def test_project_version_matches_pyproject() -> None:
    assert project_version(ROOT) == load_pyproject(ROOT)["project"]["version"]
