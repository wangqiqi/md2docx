#!/usr/bin/env bash
# Generate Gradle Wrapper (gradle-wrapper.jar + gradlew) when Gradle is on PATH.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -x "$ROOT/gradlew" && -f "$ROOT/gradle/wrapper/gradle-wrapper.jar" ]]; then
  echo "OK: Gradle Wrapper already present"
  exit 0
fi

if ! command -v gradle >/dev/null 2>&1; then
  echo "FAIL: install Gradle, then run: gradle wrapper --gradle-version 8.10.2" >&2
  echo "  Or copy gradle-wrapper.jar into gradle/wrapper/ from an existing Gradle project." >&2
  exit 1
fi

gradle wrapper --gradle-version 8.10.2
chmod +x gradlew
echo "OK: Gradle Wrapper generated"
