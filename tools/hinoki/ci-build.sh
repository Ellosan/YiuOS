#!/usr/bin/env bash
set -euo pipefail

: "${ANDROID_ROOT:?ANDROID_ROOT is required}"
: "${YIUOS_CHECKOUT:?YIUOS_CHECKOUT is required}"

mkdir -p "${ANDROID_ROOT}"

if [[ ! -f "${ANDROID_ROOT}/.repo/manifest.xml" ]]; then
  (
    cd "${ANDROID_ROOT}"
    repo init \
      -u https://github.com/LineageOS/android.git \
      -b lineage-15.1 \
      --depth=1 \
      --no-clone-bundle
  )
fi

mkdir -p "${ANDROID_ROOT}/.repo/local_manifests"
cp \
  "${YIUOS_CHECKOUT}/manifests/hinoki-15.1.xml" \
  "${ANDROID_ROOT}/.repo/local_manifests/yiuos-hinoki.xml"

(
  cd "${ANDROID_ROOT}"
  repo sync \
    -c \
    --force-sync \
    --no-clone-bundle \
    --no-tags \
    --optimized-fetch \
    --prune \
    -j"${SYNC_JOBS:-8}"
)

mkdir -p "${ANDROID_ROOT}/vendor"
if [[ -e "${ANDROID_ROOT}/vendor/yiuos" && ! -L "${ANDROID_ROOT}/vendor/yiuos" ]]; then
  echo "${ANDROID_ROOT}/vendor/yiuos exists and is not a symlink; refusing to replace it." >&2
  exit 1
fi
ln -sfn "${YIUOS_CHECKOUT}" "${ANDROID_ROOT}/vendor/yiuos"

ANDROID_ROOT="${ANDROID_ROOT}" \
YIUOS_ROOT="${YIUOS_CHECKOUT}" \
BUILD_TARGET="${BUILD_TARGET:-bacon}" \
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}" \
USE_CCACHE="${USE_CCACHE:-1}" \
CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-50G}" \
  bash "${YIUOS_CHECKOUT}/tools/hinoki/build.sh"
