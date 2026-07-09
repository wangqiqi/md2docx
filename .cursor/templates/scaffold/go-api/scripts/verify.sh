#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
go mod tidy
bash ./scripts/test.sh
go build -o bin/server ./cmd/server
