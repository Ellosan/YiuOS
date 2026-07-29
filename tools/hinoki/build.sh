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

# The Sony MT6757 kernel has its own Android.mk integration, while LineageOS
# 15.1 also builds TARGET_KERNEL_SOURCE through vendor/lineage. Loading both
# creates two rules for Image.gz-dtb and a cycle through system's file list.
# Hide the kernel-side integration and let LineageOS own the kernel build.
KERNEL_ANDROID_MK="${ANDROID_ROOT}/kernel/sony/mt6757/Android.mk"
KERNEL_ANDROID_MK_DISABLED="${KERNEL_ANDROID_MK}.yiuos-disabled"
KERNEL_ANDROID_MK_HIDDEN=0

# Android automatically includes vendor/*/build/core/*.mk and
# vendor/*/build/tasks/*.mk. YiuOS's current fragments target a much newer
# Android build system and conflict with LineageOS 15.1's core, kernel and
# packaging tasks, so isolate them for this legacy product. Android 8.1's Soong
# parser also cannot parse the Android 16 Blueprint syntax in the main vendor
# tree.
HIDDEN_CORE_LIST="$(mktemp)"
HIDDEN_TASK_LIST="$(mktemp)"
HIDDEN_BP_LIST="$(mktemp)"
restore_build_inputs() {
  if [[ "${KERNEL_ANDROID_MK_HIDDEN}" == "1" && -f "${KERNEL_ANDROID_MK_DISABLED}" ]]; then
    mv -f -- "${KERNEL_ANDROID_MK_DISABLED}" "${KERNEL_ANDROID_MK}"
  fi
  while IFS= read -r -d '' core_fragment; do
    mv -f -- "${core_fragment}.hinoki-disabled" "${core_fragment}"
  done < "${HIDDEN_CORE_LIST}"
  while IFS= read -r -d '' task; do
    mv -f -- "${task}.hinoki-disabled" "${task}"
  done < "${HIDDEN_TASK_LIST}"
  while IFS= read -r -d '' blueprint; do
    mv -f -- "${blueprint}.hinoki-disabled" "${blueprint}"
  done < "${HIDDEN_BP_LIST}"
  rm -f -- "${HIDDEN_CORE_LIST}" "${HIDDEN_TASK_LIST}" "${HIDDEN_BP_LIST}"
}
trap restore_build_inputs EXIT

if [[ -e "${KERNEL_ANDROID_MK_DISABLED}" ]]; then
  echo "Stale disabled kernel build file exists: ${KERNEL_ANDROID_MK_DISABLED}" >&2
  exit 1
fi
if [[ -f "${KERNEL_ANDROID_MK}" ]]; then
  mv -- "${KERNEL_ANDROID_MK}" "${KERNEL_ANDROID_MK_DISABLED}"
  KERNEL_ANDROID_MK_HIDDEN=1
fi

while IFS= read -r -d '' core_fragment; do
  if [[ -e "${core_fragment}.hinoki-disabled" ]]; then
    echo "Stale disabled YiuOS build core fragment exists: ${core_fragment}.hinoki-disabled" >&2
    exit 1
  fi
  mv -- "${core_fragment}" "${core_fragment}.hinoki-disabled"
  printf '%s\0' "${core_fragment}" >> "${HIDDEN_CORE_LIST}"
done < <(find "${YIUOS_ROOT}/build/core" -maxdepth 1 -type f -name '*.mk' -print0)

while IFS= read -r -d '' task; do
  if [[ -e "${task}.hinoki-disabled" ]]; then
    echo "Stale disabled YiuOS build task exists: ${task}.hinoki-disabled" >&2
    exit 1
  fi
  mv -- "${task}" "${task}.hinoki-disabled"
  printf '%s\0' "${task}" >> "${HIDDEN_TASK_LIST}"
done < <(find "${YIUOS_ROOT}/build/tasks" -maxdepth 1 -type f -name '*.mk' -print0)

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
