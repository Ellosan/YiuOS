#!/bin/bash -e
#
# YiuOS build script for Crave (foss.crave.io).
#
# Run from inside a Crave project directory on your machine:
#
#   crave run --no-patch -- "curl -s https://raw.githubusercontent.com/Ellosan/YiuOS/main/tools/crave-build.sh | bash"
#
# then pull the artifacts when it finishes:
#
#   crave pull out/target/product/gsi_arm64/system.img
#
# Pick the "LineageOS 23" project (or any AOSP/Lineage project) when
# creating the Crave project so the sources land on a warm mirror.

TARGET="${YIUOS_LUNCH_TARGET:-yiuos_gsi_arm64}"
RELEASE="${YIUOS_RELEASE:-bp4a}"
VARIANT="${YIUOS_VARIANT:-userdebug}"

# 1. LineageOS 23.2 sources
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs

# 2. YiuOS vendor tree via local manifest
mkdir -p .repo/local_manifests
curl -so .repo/local_manifests/yiuos.xml \
    https://raw.githubusercontent.com/Ellosan/YiuOS/main/manifests/yiuos.xml

# 3. Sync (use Crave's accelerated resync when available)
if [ -x /opt/crave/resync.sh ]; then
    /opt/crave/resync.sh
else
    repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags
fi

# 4. Point the LineageOS build system at vendor/yiuos
bash vendor/yiuos/tools/apply-yiuos-buildsystem.sh

# 5. Build
source build/envsetup.sh
lunch "${TARGET}-${RELEASE}-${VARIANT}"
m
