#!/usr/bin/env bash
# 核对 PyPI 上 mddocx 是否已发布指定版本（JSON API）。
# 用法: bash scripts/verify_pypi_version.sh <version>
# 环境变量（可选）:
#   PYPI_PACKAGE   默认 mddocx
#   PYPI_RETRIES   默认 1（本地）；CI 可设 3
#   PYPI_RETRY_SLEEP  默认 5（秒）
set -euo pipefail

VERSION="${1:-}"
PACKAGE="${PYPI_PACKAGE:-mddocx}"
RETRIES="${PYPI_RETRIES:-1}"
SLEEP_SEC="${PYPI_RETRY_SLEEP:-5}"
API_URL="https://pypi.org/pypi/${PACKAGE}/json"

if [[ -z "${VERSION}" ]]; then
  echo "用法: $0 <version>   例: $0 0.5.47" >&2
  exit 2
fi

# 去掉可选的 v 前缀
VERSION="${VERSION#v}"

if ! command -v curl >/dev/null 2>&1; then
  echo "错误: 需要 curl" >&2
  exit 2
fi

attempt=1
while (( attempt <= RETRIES )); do
  echo "🔍 核对 PyPI ${PACKAGE}==${VERSION}（第 ${attempt}/${RETRIES} 次）…"
  body="$(curl -fsSL --max-time 30 "${API_URL}" 2>/dev/null || true)"
  if [[ -z "${body}" ]]; then
    echo "⚠️  无法拉取 ${API_URL}" >&2
  else
    # 在 releases 键中查找精确版本（避免子串误匹配）
    if printf '%s' "${body}" | python3 -c "
import json, sys
want = sys.argv[1]
data = json.load(sys.stdin)
releases = data.get('releases') or {}
sys.exit(0 if want in releases else 1)
" "${VERSION}"; then
      echo "✅ PyPI 已包含 ${PACKAGE}==${VERSION}"
      exit 0
    fi
    echo "⏳ 尚未在 PyPI 看到 ${PACKAGE}==${VERSION}"
  fi
  if (( attempt < RETRIES )); then
    sleep "${SLEEP_SEC}"
  fi
  attempt=$((attempt + 1))
done

echo "❌ PyPI 上未找到 ${PACKAGE}==${VERSION}（已重试 ${RETRIES} 次）" >&2
exit 1
