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

# Android 8.1's Soong parser cannot parse the Android 16 Blueprint syntax in
# the main vendor tree. The legacy product uses Android.mk modules exclusively,
# so hide modern Blueprint files for this build and restore them on exit.
HIDDEN_BP_LIST="$(mktemp)"
restore_blueprints() {
  while IFS= read -r -d '' blueprint; do
    mv -f -- "${blueprint}.hinoki-disabled" "${blueprint}"
  done < "${HIDDEN_BP_LIST}"
  rm -f -- "${HIDDEN_BP_LIST}"
}
trap restore_blueprints EXIT
while IFS= read -r -d '' blueprint; do
  mv -f -- "${blueprint}" "${blueprint}.hinoki-disabled"
  printf '%s\0' "${blueprint}" >> "${HIDDEN_BP_LIST}"
done < <(find "${YIUOS_ROOT}" -type f -name Android.bp -print0)

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
