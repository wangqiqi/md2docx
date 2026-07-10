"""verify_release_candidate.sh 存在性与语法。"""

from __future__ import annotations

import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "verify_release_candidate.sh"


def test_verify_release_candidate_script_exists() -> None:
    assert SCRIPT.is_file()
    assert os.access(SCRIPT, os.X_OK)


def test_verify_release_candidate_bash_syntax() -> None:
    subprocess.run(["bash", "-n", str(SCRIPT)], check=True)
