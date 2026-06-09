#!/usr/bin/env python3
"""
验证 tests/samples 导出 DOCX 是否符合期望。

用法:
  # 现场转换并验收（推荐，不依赖 output/ 是否过期）
  python scripts/verify_samples_output.py

  # 仅验收已生成的 tests/samples/output/*.docx
  python scripts/verify_samples_output.py --use-output

  # 两者都做并对比媒体数/体积
  python scripts/verify_samples_output.py --compare-output
"""

from __future__ import annotations

import argparse
import sys
import tempfile
from pathlib import Path

script_dir = Path(__file__).resolve().parent
project_root = script_dir.parent
sys.path.insert(0, str(project_root / "src"))
sys.path.insert(0, str(project_root / "tests" / "integration"))

from mddocx.converter.base import BaseConverter  # noqa: E402
from sample_output_checks import (  # noqa: E402
    EXPECTATIONS,
    check_docx_against_expectation,
    extract_media_bytes,
    list_sample_md_files,
    rel_sample_key,
)


def convert_sample(md_path: Path, out_path: Path) -> None:
    doc = BaseConverter().convert_file(md_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    doc.save(str(out_path))


def run_verify(
    samples_root: Path,
    docx_resolver,
    label: str,
) -> tuple[int, int, list[str]]:
    passed = 0
    failed = 0
    lines: list[str] = []

    for md_path in list_sample_md_files(samples_root):
        key = rel_sample_key(md_path, samples_root)
        exp = EXPECTATIONS.get(key)
        if exp is None:
            lines.append(f"SKIP [{label}] {key} — 无期望规则")
            continue

        docx_path = docx_resolver(md_path, key)
        reasons = check_docx_against_expectation(docx_path, md_path, exp)
        if reasons:
            failed += 1
            lines.append(f"FAIL [{label}] {key}")
            for r in reasons:
                lines.append(f"       · {r}")
        else:
            passed += 1
            media_n = len(extract_media_bytes(docx_path))
            size = docx_path.stat().st_size
            lines.append(
                f"OK   [{label}] {key} — {size:,} B, media={media_n}"
            )

    return passed, failed, lines


def main() -> int:
    parser = argparse.ArgumentParser(description="验收 tests/samples DOCX")
    parser.add_argument(
        "--use-output",
        action="store_true",
        help="只检查 tests/samples/output 下已有 docx",
    )
    parser.add_argument(
        "--compare-output",
        action="store_true",
        help="新鲜转换 vs output 目录对比",
    )
    args = parser.parse_args()

    samples_root = project_root / "tests" / "samples"
    output_root = samples_root / "output"

    use_fresh = not args.use_output or args.compare_output
    use_existing = args.use_output or args.compare_output

    total_fail = 0
    all_lines: list[str] = []

    if use_fresh:
        with tempfile.TemporaryDirectory(prefix="md2docx_verify_") as tmp:
            tmp_root = Path(tmp)

            def fresh_resolver(md_path: Path, key: str) -> Path:
                rel = Path(key)
                return tmp_root / rel.parent / f"{md_path.stem}.docx"

            converter = BaseConverter()
            for md_path in list_sample_md_files(samples_root):
                out = fresh_resolver(md_path, rel_sample_key(md_path, samples_root))
                out.parent.mkdir(parents=True, exist_ok=True)
                doc = converter.convert_file(md_path)
                doc.save(str(out))

            p, f, lines = run_verify(samples_root, fresh_resolver, "fresh")
            total_fail += f
            all_lines.extend(lines)
            all_lines.append(
                f"\n--- fresh 转换: {p} 通过, {f} 失败 / {p + f} 项 ---"
            )

    if use_existing:
        if not output_root.is_dir():
            print(f"WARN: output 目录不存在: {output_root}", file=sys.stderr)
        else:

            def output_resolver(md_path: Path, key: str) -> Path:
                rel = Path(key)
                return output_root / rel.parent / f"{md_path.stem}.docx"

            p, f, lines = run_verify(samples_root, output_resolver, "output")
            total_fail += f
            all_lines.extend(lines)
            all_lines.append(
                f"\n--- output 目录: {p} 通过, {f} 失败 / {p + f} 项 ---"
            )

    if args.compare_output and use_fresh and output_root.is_dir():
        all_lines.append("\n--- fresh vs output 快照对比 ---")
        with tempfile.TemporaryDirectory(prefix="md2docx_cmp_") as tmp:
            tmp_root = Path(tmp)
            for md_path in list_sample_md_files(samples_root):
                key = rel_sample_key(md_path, samples_root)
                rel = Path(key)
                fresh = tmp_root / rel.parent / f"{md_path.stem}.docx"
                fresh.parent.mkdir(parents=True, exist_ok=True)
                BaseConverter().convert_file(md_path).save(str(fresh))
                existing = output_root / rel.parent / f"{md_path.stem}.docx"
                if not existing.is_file():
                    all_lines.append(f"DIFF {key}: output 缺失")
                    total_fail += 1
                    continue
                fm = len(extract_media_bytes(fresh))
                om = len(extract_media_bytes(existing))
                fs, os_ = fresh.stat().st_size, existing.stat().st_size
                if fm != om or abs(fs - os_) > fs * 0.15:
                    all_lines.append(
                        f"DIFF {key}: fresh={fs}B/m{fm} vs output={os_}B/m{om}"
                    )
                    total_fail += 1
                else:
                    all_lines.append(f"MATCH {key}: {fs:,} B, media={fm}")

    print("\n".join(all_lines))
    print(
        f"\n{'✅ 全部通过' if total_fail == 0 else f'❌ 共 {total_fail} 项失败'}"
    )
    return 0 if total_fail == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
