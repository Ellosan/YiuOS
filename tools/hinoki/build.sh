#!/usr/bin/env bash
set -euo pipefail

ANDROID_ROOT="${ANDROID_ROOT:-$PWD}"
YIUOS_ROOT="${YIUOS_ROOT:-${ANDROID_ROOT}/vendor/yiuos}"
BUILD_TARGET="${BUILD_TARGET:-bacon}"

if [[ ! -f "${ANDROID_ROOT}/build/envsetup.sh" ]]; then
  echo "ANDROID_ROOT must point to a synced LineageOS 15.1 checkout." >&2
  exit 1
fi
if [[ ! -f "${YIUOS_ROOT}/legacy/hinoki/yiuos_hinoki.mk" ]]; then
  echo "YIUOS_ROOT must point to this repository." >&2
  exit 1
fi

bash "${YIUOS_ROOT}/tools/hinoki/prepare-assets.sh"

cd "${ANDROID_ROOT}"
# Android 8.1's envsetup uses array expansions that are not nounset-safe.
set +u
# shellcheck disable=SC1091
source build/envsetup.sh
lunch yiuos_hinoki-userdebug

export USE_CCACHE="${USE_CCACHE:-1}"
export CCACHE_EXEC="${CCACHE_EXEC:-$(command -v ccache || true)}"
if [[ "${USE_CCACHE}" == "1" && -n "${CCACHE_EXEC}" ]]; then
  ccache -M "${CCACHE_MAXSIZE:-50G}"
fi

mka -j"${BUILD_JOBS:-$(nproc)}" "${BUILD_TARGET}"

if [[ "${BUILD_TARGET}" == "bacon" ]]; then
  PRODUCT_OUT="${ANDROID_ROOT}/out/target/product/hinoki"
  for ota in "${PRODUCT_OUT}"/lineage-*-hinoki.zip; do
    [[ -e "${ota}" ]] || continue
    cp -f -- "${ota}" \
      "${PRODUCT_OUT}/YiuOS-0.3-$(date -u +%Y%m%d)-UNOFFICIAL-hinoki.zip"
    break
  done
fi
