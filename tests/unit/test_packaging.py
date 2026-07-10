"""打包与版本单一真源验收。"""

from __future__ import annotations

import subprocess
import sys
import zipfile
from pathlib import Path

import mddocx

ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = ROOT / "scripts"
if str(SCRIPTS) not in sys.path:
    sys.path.insert(0, str(SCRIPTS))

from pyproject_util import load_pyproject, project_version  # noqa: E402


def _pyproject_version() -> str:
    return project_version(ROOT)


def _pyproject_license() -> object:
    return load_pyproject(ROOT)["project"]["license"]


def test_license_table_compatible_with_old_setuptools() -> None:
    """SPDX 字符串 license 在 Python 3.8 CI 旧 setuptools 下会失败。"""
    license_value = _pyproject_license()
    assert isinstance(license_value, dict), "project.license must be a table for setuptools<77"
    assert license_value.get("text") == "MIT"


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


def test_editable_install_with_old_setuptools(tmp_path: Path) -> None:
    """模拟 CI Python 3.8 隔离环境中的 pip install -e。"""
    venv = tmp_path / "venv"
    subprocess.run([sys.executable, "-m", "venv", str(venv)], check=True)
    pip = venv / "bin" / "pip"
    subprocess.run(
        [str(pip), "install", "-q", "-U", "pip<25", "setuptools<70", "wheel"],
        check=True,
    )
    result = subprocess.run(
        [str(pip), "install", "-e", str(ROOT)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stderr or result.stdout
