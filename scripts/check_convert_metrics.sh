#!/usr/bin/env bash
# ConvertMetrics 门禁：结构字段硬失败 + 耗时相对阈值（默认可 soft）
# 用法:
#   bash scripts/check_convert_metrics.sh
#   METRICS_SOFT=0 bash scripts/check_convert_metrics.sh   # 耗时也硬失败
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"
SOFT_FLAG=()
# 默认 soft：CI runner 抖动不红；显式 METRICS_SOFT=0 才硬失败耗时
if [[ "${METRICS_SOFT:-1}" != "0" ]]; then
  SOFT_FLAG=(--soft)
fi

MAX_RATIO="${METRICS_MAX_RATIO:-5.0}"
FLOOR_MS="${METRICS_FLOOR_MS:-200}"

echo "=== ConvertMetrics structural ==="
"$PYTHON" scripts/collect_convert_metrics.py --compare

echo "=== ConvertMetrics duration (ratio=${MAX_RATIO} floor=${FLOOR_MS}ms soft=${METRICS_SOFT:-1}) ==="
"$PYTHON" scripts/collect_convert_metrics.py \
  --check-duration \
  --max-ratio "$MAX_RATIO" \
  --floor-ms "$FLOOR_MS" \
  "${SOFT_FLAG[@]}"

echo "OK: check_convert_metrics passed"
