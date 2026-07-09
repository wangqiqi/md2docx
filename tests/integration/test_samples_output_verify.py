"""
tests/samples DOCX 程序化验收（pytest 入口，CI 可跑）。
"""

from pathlib import Path

import pytest

from sample_output_checks import (  # isort: skip
    EXPECTATIONS,
    check_docx_against_expectation,
    list_sample_md_files,
    rel_sample_key,
)

SAMPLES_ROOT = Path(__file__).resolve().parents[1] / "samples"


@pytest.fixture(scope="module")
def fresh_docx_dir(tmp_path_factory):
    """现场 convert_file 生成 docx，不依赖 gitignore 的 output/。"""
    from mddocx.converter.base import BaseConverter

    out_root = tmp_path_factory.mktemp("samples_docx")
    converter = BaseConverter()
    mapping = {}
    for md_path in list_sample_md_files(SAMPLES_ROOT):
        key = rel_sample_key(md_path, SAMPLES_ROOT)
        rel = Path(key)
        docx_path = out_root / rel.parent / f"{md_path.stem}.docx"
        docx_path.parent.mkdir(parents=True, exist_ok=True)
        doc = converter.convert_file(md_path)
        doc.save(str(docx_path))
        mapping[key] = (md_path, docx_path)
    return mapping


@pytest.mark.parametrize("sample_key", sorted(EXPECTATIONS.keys()))
def test_fresh_sample_docx_meets_expectations(fresh_docx_dir, sample_key):
    md_path, docx_path = fresh_docx_dir[sample_key]
    failures = check_docx_against_expectation(docx_path, md_path, EXPECTATIONS[sample_key])
    assert not failures, "\n".join(failures)


def test_output_dir_docx_if_present():
    """若本地已生成 output/，同样跑一遍规则（可选，失败仅 warn）。"""
    output_root = SAMPLES_ROOT / "output"
    if not output_root.is_dir():
        pytest.skip("tests/samples/output 未生成")

    missing = []
    failures_all = []
    for md_path in list_sample_md_files(SAMPLES_ROOT):
        key = rel_sample_key(md_path, SAMPLES_ROOT)
        exp = EXPECTATIONS.get(key)
        if not exp:
            continue
        rel = Path(key)
        docx_path = output_root / rel.parent / f"{md_path.stem}.docx"
        if not docx_path.is_file():
            missing.append(key)
            continue
        failures = check_docx_against_expectation(docx_path, md_path, exp)
        if failures:
            failures_all.append((key, failures))

    assert not missing, f"output 缺少 docx: {missing}"
    assert not failures_all, "\n".join(f"{k}: " + "; ".join(v) for k, v in failures_all)
