"""verify_release_alignment.sh 存在性与语法。"""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "verify_release_alignment.sh"


def test_verify_release_alignment_script_exists() -> None:
    assert SCRIPT.is_file()
    assert os.access(SCRIPT, os.X_OK)


def test_verify_release_alignment_bash_syntax() -> None:
    subprocess.run(["bash", "-n", str(SCRIPT)], check=True)


def test_release_alignment_passes_on_repo() -> None:
    subprocess.run(["bash", str(SCRIPT)], cwd=ROOT, check=True)
