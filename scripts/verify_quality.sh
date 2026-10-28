#!/usr/bin/env bash
# 与 .github/workflows/ci.yml · job quality 同序（打 tag / push 前建议先跑）
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== flake8 ==="
flake8 src tests

echo "=== black ==="
black --check --diff src tests

echo "=== mypy (converter) ==="
mypy src/mddocx/converter --config-file mypy.ini

echo "=== mypy (standalone modules) ==="
mypy --follow-imports=skip \
  src/mddocx/__init__.py \
  src/mddocx/cli.py \
  src/mddocx/errors.py \
  src/mddocx/mcp/convert.py \
  src/mddocx/mcp/server.py \
  src/mddocx/webui/app.py \
  src/mddocx/webui/batch.py \
  src/mddocx/webui/config.py \
  src/mddocx/webui/converter_pool.py \
  src/mddocx/webui/rate_limit.py \
  src/mddocx/webui/start_webui.py \
  --config-file mypy.ini

echo "=== isort ==="
isort --check-only --diff src tests

echo "=== ConvertMetrics baseline ==="
METRICS_SOFT="${METRICS_SOFT:-0}" bash scripts/check_convert_metrics.sh

echo "=== release alignment ==="
bash scripts/verify_release_alignment.sh

echo "✅ verify_quality passed (matches CI quality job)"
