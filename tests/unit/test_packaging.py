"""打包与版本单一真源验收。"""

from __future__ import annotations

import subprocess
import sys
import tomllib
import zipfile
from pathlib import Path

import mddocx

ROOT = Path(__file__).resolve().parents[2]


def _pyproject_version() -> str:
    data = tomllib.loads((ROOT / "pyproject.toml").read_text(encoding="utf-8"))
    return str(data["project"]["version"])


def test_module_version_matches_pyproject() -> None:
    assert mddocx.__version__ == _pyproject_version()


def test_wheel_excludes_webui_tests(tmp_path: Path) -> None:
    outdir = tmp_path / "dist"
    outdir.mkdir()
    subprocess.run(
        [sys.executable, "-m", "build", "--outdir", str(outdir)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    wheels = list(outdir.glob("*.whl"))
    assert wheels, "expected at least one wheel"
    wheel = wheels[0]
    with zipfile.ZipFile(wheel) as zf:
        names = zf.namelist()
    test_paths = [n for n in names if "webui/tests" in n.replace("\\", "/")]
    assert not test_paths, f"wheel must not ship webui tests: {test_paths}"
    version = _pyproject_version()
    assert f"mddocx-{version}" in wheel.name.replace("_", "-")
