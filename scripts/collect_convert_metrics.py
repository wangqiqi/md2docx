#!/usr/bin/env python3
"""采集 ConvertMetrics 性能基线（E-METRICS-01）。

用法:
  python scripts/collect_convert_metrics.py              # 打印当前快照
  python scripts/collect_convert_metrics.py --write       # 写入 tests/baselines/convert_metrics.json
  python scripts/collect_convert_metrics.py --compare     # 与基线比对结构字段（input_bytes/chunked）
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from mddocx.converter.base import BaseConverter  # noqa: E402

BASELINE_PATH = ROOT / "tests" / "baselines" / "convert_metrics.json"

# 固定用例：小样例 + large/chunked 强制分块路径
CASES = (
    {
        "id": "small_headings",
        "source": "tests/samples/basic/headings.md",
        "force_chunked": False,
    },
    {
        "id": "large_chunked",
        "source": "tests/samples/large/chunked.md",
        "force_chunked": True,
    },
)


@dataclass(frozen=True)
class CaseSnapshot:
    id: str
    source: str
    force_chunked: bool
    duration_ms: float
    input_bytes: int
    chunked: bool


def repo_path(rel: str) -> Path:
    return ROOT / rel


def collect_case(case: Dict[str, Any]) -> CaseSnapshot:
    path = repo_path(case["source"])
    if not path.is_file():
        raise FileNotFoundError(f"missing sample: {path}")
    text = path.read_text(encoding="utf-8")
    converter = BaseConverter()
    force = bool(case["force_chunked"])
    converter.convert(
        text,
        base_path=str(path),
        chunked=True if force else None,
    )
    m = converter.last_metrics
    if m is None:
        raise RuntimeError(f"no metrics after convert: {case['id']}")
    return CaseSnapshot(
        id=case["id"],
        source=case["source"],
        force_chunked=force,
        duration_ms=round(m.duration_ms, 3),
        input_bytes=m.input_bytes,
        chunked=m.chunked,
    )


def collect_all() -> List[CaseSnapshot]:
    return [collect_case(c) for c in CASES]


def baseline_document(cases: List[CaseSnapshot]) -> Dict[str, Any]:
    return {
        "version": 1,
        "schema": [
            "id",
            "source",
            "force_chunked",
            "duration_ms",
            "input_bytes",
            "chunked",
        ],
        "cases": [asdict(c) for c in cases],
    }


def load_baseline(path: Path = BASELINE_PATH) -> Dict[str, Any]:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def write_baseline(cases: List[CaseSnapshot], path: Path = BASELINE_PATH) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    doc = baseline_document(cases)
    path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return path


def compare_structural(
    live: List[CaseSnapshot],
    baseline: Dict[str, Any],
) -> List[str]:
    """比对 input_bytes / chunked / force_chunked / source；忽略 duration_ms。"""
    errors: List[str] = []
    by_id = {c["id"]: c for c in baseline.get("cases", [])}
    for snap in live:
        ref = by_id.get(snap.id)
        if ref is None:
            errors.append(f"{snap.id}: missing in baseline")
            continue
        for key, got, want in (
            ("source", snap.source, ref.get("source")),
            ("force_chunked", snap.force_chunked, ref.get("force_chunked")),
            ("input_bytes", snap.input_bytes, ref.get("input_bytes")),
            ("chunked", snap.chunked, ref.get("chunked")),
        ):
            if got != want:
                errors.append(f"{snap.id}.{key}: live={got!r} baseline={want!r}")
    return errors


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Collect ConvertMetrics baselines")
    parser.add_argument(
        "--write",
        action="store_true",
        help="write tests/baselines/convert_metrics.json",
    )
    parser.add_argument(
        "--compare",
        action="store_true",
        help="compare structural fields against committed baseline",
    )
    parser.add_argument(
        "--baseline",
        type=Path,
        default=BASELINE_PATH,
        help="baseline JSON path",
    )
    args = parser.parse_args(argv)

    cases = collect_all()
    for c in cases:
        print(
            f"{c.id}: duration_ms={c.duration_ms:.3f} "
            f"input_bytes={c.input_bytes} chunked={c.chunked} "
            f"force_chunked={c.force_chunked} source={c.source}"
        )

    if args.write:
        out = write_baseline(cases, args.baseline)
        print(f"wrote {out}")

    if args.compare:
        if not args.baseline.is_file():
            print(f"FAIL: baseline missing: {args.baseline}", file=sys.stderr)
            return 1
        errs = compare_structural(cases, load_baseline(args.baseline))
        if errs:
            for e in errs:
                print(f"FAIL: {e}", file=sys.stderr)
            return 1
        print("OK: structural fields match baseline")

    return 0


if __name__ == "__main__":
    sys.exit(main())
