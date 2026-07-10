"""ConvertMetrics 基线采集与结构字段回归（E-METRICS-01 / TASK-001）。"""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "collect_convert_metrics.py"
BASELINE = ROOT / "tests" / "baselines" / "convert_metrics.json"


def _load_collector():
    import sys

    # dataclass + from __future__ annotations 需要模块先挂到 sys.modules
    name = "collect_convert_metrics"
    spec = importlib.util.spec_from_file_location(name, SCRIPT)
    assert spec is not None and spec.loader is not None
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


@pytest.fixture(scope="module")
def collector():
    return _load_collector()


def test_baseline_file_exists_and_schema():
    assert BASELINE.is_file(), f"missing baseline: {BASELINE}"
    doc = json.loads(BASELINE.read_text(encoding="utf-8"))
    assert doc.get("version") == 1
    cases = doc.get("cases")
    assert isinstance(cases, list) and len(cases) >= 2
    ids = {c["id"] for c in cases}
    assert "small_headings" in ids
    assert "large_chunked" in ids
    for c in cases:
        assert "duration_ms" in c and isinstance(c["duration_ms"], (int, float))
        assert "input_bytes" in c and isinstance(c["input_bytes"], int)
        assert "chunked" in c and isinstance(c["chunked"], bool)
        assert c["input_bytes"] > 0


def test_collect_matches_baseline_structural(collector):
    live = collector.collect_all()
    baseline = collector.load_baseline(BASELINE)
    errors = collector.compare_structural(live, baseline)
    assert errors == [], errors


def test_large_chunked_case_reports_chunked_true(collector):
    snap = next(c for c in collector.collect_all() if c.id == "large_chunked")
    assert snap.force_chunked is True
    assert snap.chunked is True
    assert snap.source.endswith("large/chunked.md")


def test_small_case_not_chunked(collector):
    snap = next(c for c in collector.collect_all() if c.id == "small_headings")
    assert snap.force_chunked is False
    assert snap.chunked is False
