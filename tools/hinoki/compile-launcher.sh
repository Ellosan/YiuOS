#!/usr/bin/env bash
set -euo pipefail

YIUOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_JAR="${ANDROID_JAR:-${ANDROID_HOME:-}/platforms/android-27/android.jar}"

if [[ ! -f "${ANDROID_JAR}" ]]; then
  echo "Android 8.1 android.jar not found: ${ANDROID_JAR}" >&2
  exit 1
fi

OUT="$(mktemp -d)"
trap 'rm -rf -- "${OUT}"' EXIT

javac \
  -source 8 \
  -target 8 \
  -Xlint:all \
  -cp "${ANDROID_JAR}" \
  -d "${OUT}" \
  "${YIUOS_ROOT}/tools/hinoki/test-stubs/org/yiuos/home/R.java" \
  "${YIUOS_ROOT}/legacy/hinoki/apps/YiuHome/src/org/yiuos/home/HomeActivity.java"

echo "YiuHome compiles against Android API 27"
