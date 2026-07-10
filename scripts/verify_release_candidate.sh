#!/usr/bin/env bash
# 发布候选一键预检：测试 / 质量 / 构建 / 隔离安装 / PyPI 版本碰撞提示
# 用法: bash scripts/verify_release_candidate.sh
# 环境变量（可选）:
#   PYTHON          默认 python3
#   DIST_DIR        构建输出目录（默认 $ROOT/.release-candidate-dist）
#   VENV_DIR        隔离安装 venv（默认 mktemp）
#   METRICS_SOFT    默认 1（与 CI 一致）
#   SKIP_ISOLATED   设为 1 跳过隔离安装冒烟（仅调试用）
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"
DIST_DIR="${DIST_DIR:-$ROOT/.release-candidate-dist}"
METRICS_SOFT="${METRICS_SOFT:-1}"
SKIP_ISOLATED="${SKIP_ISOLATED:-0}"

read_version() {
  "$PYTHON" -c "import sys; sys.path.insert(0, 'scripts'); from pyproject_util import project_version; print(project_version())"
}

VERSION="$(read_version)"
NEXT_VERSION="$("$PYTHON" -c "
import sys
sys.path.insert(0, 'scripts')
from pyproject_util import project_version
v = project_version()
parts = [int(x) for x in v.split('.')]
parts[-1] += 1
print('.'.join(str(p) for p in parts))
")"
echo "=== md2docx release candidate verify (pyproject ${VERSION}) ==="

echo ""
echo "=== release alignment ==="
bash scripts/verify_release_alignment.sh

echo ""
echo "=== PyPI version collision check ==="
if bash scripts/verify_pypi_version.sh "${VERSION}"; then
  echo ""
  echo "⚠️  PyPI 已存在 mddocx==${VERSION}。"
  echo "    后续 /release 必须升版（建议 ${NEXT_VERSION}），勿重复上传 ${VERSION}。"
else
  echo "ℹ️  PyPI 尚无 mddocx==${VERSION}（或网络不可达）；发布前仍须核对 CHANGELOG 与 tag。"
fi

echo ""
echo "=== pytest + coverage (≥85%) ==="
"$PYTHON" -m pytest tests/ src/mddocx/webui/tests/ \
  --cov=src \
  --cov-report=term-missing:skip-covered \
  --cov-fail-under=85

echo ""
echo "=== flake8 ==="
flake8 src tests

echo ""
echo "=== black ==="
black --check --diff src tests

echo ""
echo "=== mypy ==="
mypy src/mddocx/converter --config-file mypy.ini
mypy --follow-imports=skip src/mddocx/errors.py src/mddocx/webui/rate_limit.py --config-file mypy.ini

echo ""
echo "=== isort ==="
isort --check-only --diff src tests

echo ""
echo "=== ConvertMetrics baseline ==="
METRICS_SOFT="${METRICS_SOFT}" bash scripts/check_convert_metrics.sh

echo ""
echo "=== build + twine check ==="
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"
"$PYTHON" -m build --outdir "${DIST_DIR}"
twine check "${DIST_DIR}"/*

echo ""
echo "=== wheel hygiene ==="
WHEEL="$(ls -1 "${DIST_DIR}"/*.whl | head -1)"
"$PYTHON" -c "
import sys, zipfile
wheel = sys.argv[1]
with zipfile.ZipFile(wheel) as zf:
    bad = [n for n in zf.namelist() if 'webui/tests' in n.replace('\\\\', '/')]
if bad:
    raise SystemExit(f'wheel contains webui tests: {bad}')
print(f'OK: {wheel} has no webui/tests')
" "${WHEEL}"

echo ""
echo "=== runtime version vs pyproject ==="
"$PYTHON" -c "
import sys
sys.path.insert(0, 'scripts')
from pyproject_util import project_version
import mddocx
want = project_version()
got = mddocx.__version__
assert got == want, f'mddocx.__version__={got!r} != pyproject {want!r}'
print(f'OK: mddocx.__version__ == {want}')
"

if [[ "${SKIP_ISOLATED}" == "1" ]]; then
  echo ""
  echo "SKIP_ISOLATED=1 — 跳过隔离安装冒烟"
else
  echo ""
  echo "=== isolated install smoke ==="
  VENV_DIR="${VENV_DIR:-$(mktemp -d)/md2docx-rc-venv}"
  trap 'rm -rf "${VENV_DIR}"' EXIT
  "$PYTHON" -m venv "${VENV_DIR}"
  # shellcheck disable=SC1091
  source "${VENV_DIR}/bin/activate"
  python -m pip install --upgrade pip wheel >/dev/null
  pip install "${WHEEL}" >/dev/null
  pip check

  INSTALLED="$(python -c "import mddocx; print(mddocx.__version__)")"
  if [[ "${INSTALLED}" != "${VERSION}" ]]; then
    echo "❌ 隔离安装后版本 ${INSTALLED} != pyproject ${VERSION}" >&2
    exit 1
  fi
  echo "OK: isolated mddocx.__version__ == ${VERSION}"

  SAMPLE_MD="$(mktemp --suffix=.md)"
  SAMPLE_DOCX="$(mktemp --suffix=.docx)"
  printf '# RC\n\nhello **world**\n' >"${SAMPLE_MD}"
  mddocx "${SAMPLE_MD}" "${SAMPLE_DOCX}"
  test -s "${SAMPLE_DOCX}"
  echo "OK: mddocx CLI convert smoke"

  python -c "
from mddocx.webui.app import app
from pathlib import Path
import mddocx.webui
client = app.test_client()
resp = client.get('/')
assert resp.status_code == 200, resp.status_code
tpl = Path(mddocx.webui.__file__).resolve().parent / 'templates' / 'index.html'
assert tpl.is_file(), tpl
print('OK: WebUI app + templates smoke')
"
  deactivate || true
  trap - EXIT
  rm -rf "${VENV_DIR}"
fi

echo ""
echo "✅ release candidate verify passed (version ${VERSION})"
echo "   下一步：若 PyPI 已有 ${VERSION} → /release 升 ${NEXT_VERSION} · tag · push · PyPI"
