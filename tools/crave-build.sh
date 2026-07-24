#!/bin/bash -e
#
# YiuOS build script for Crave (foss.crave.io).
#
# GSI build (default):
#   crave run --no-patch -- "curl -s https://raw.githubusercontent.com/Ellosan/YiuOS/main/tools/crave-build.sh | bash"
#
# Device build (official LineageOS device trees, adapted to YiuOS on the fly):
#   crave run --no-patch -- "export YIUOS_DEVICE=laurel_sprout; curl -s https://raw.githubusercontent.com/Ellosan/YiuOS/main/tools/crave-build.sh | bash"
#
# Artifacts: GSI -> out/target/product/gsi_arm64/system.img
#            device -> out/target/product/<device>/YiuOS-*.zip (+ boot.img etc.)

BRANCH="${YIUOS_BRANCH:-main}"
RELEASE="${YIUOS_RELEASE:-bp4a}"
VARIANT="${YIUOS_VARIANT:-userdebug}"
DEVICE="${YIUOS_DEVICE:-}"

# 1. LineageOS 23.2 sources
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs

# 2. YiuOS vendor tree via local manifest
mkdir -p .repo/local_manifests
curl -so .repo/local_manifests/yiuos.xml \
    "https://raw.githubusercontent.com/Ellosan/YiuOS/${BRANCH}/manifests/yiuos.xml"

# 2b. Device repos (pinned; roomservice not needed)
if [ "$DEVICE" = "laurel_sprout" ]; then
    cat > .repo/local_manifests/yiuos-laurel_sprout.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="LineageOS/android_device_xiaomi_laurel_sprout" path="device/xiaomi/laurel_sprout" remote="github" revision="lineage-23.2" />
  <project name="LineageOS/android_device_xiaomi_sm6125-common" path="device/xiaomi/sm6125-common" remote="github" revision="lineage-23.2" />
  <project name="LineageOS/android_kernel_xiaomi_sm6125" path="kernel/xiaomi/sm6125" remote="github" revision="lineage-23.2" />
  <project name="LineageOS/android_hardware_xiaomi" path="hardware/xiaomi" remote="github" revision="lineage-23.2" />
  <project name="TheMuppets/proprietary_vendor_xiaomi_laurel_sprout" path="vendor/xiaomi/laurel_sprout" remote="github" revision="lineage-23.2" />
</manifest>
EOF
elif [ -n "$DEVICE" ]; then
    echo "No pinned manifest for device '$DEVICE' — add one to tools/crave-build.sh" >&2
    exit 1
fi

# 3. Sync (use Crave's accelerated resync when available)
if [ -x /opt/crave/resync.sh ]; then
    /opt/crave/resync.sh
else
    repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags
fi

# 3b. The manifest pins vendor/yiuos to main; when building from another
# branch of this repo, move the vendor checkout to that branch
if [ "$BRANCH" != "main" ]; then
    git -C vendor/yiuos fetch origin "$BRANCH"
    git -C vendor/yiuos checkout FETCH_HEAD
fi

# 4. Point the LineageOS build system at vendor/yiuos
bash vendor/yiuos/tools/apply-yiuos-buildsystem.sh

# 4b. Adapt the (unrebranded) LineageOS device trees to YiuOS
if [ -n "$DEVICE" ]; then
    grep -rl "vendor/lineage/" device/ hardware/xiaomi vendor/xiaomi 2>/dev/null | while read -r f; do
        sed -i 's|vendor/lineage/|vendor/yiuos/|g' "$f"
    done
    for mk in device/*/"$DEVICE"/lineage_"$DEVICE".mk; do
        [ -f "$mk" ] || continue
        dir=$(dirname "$mk")
        git -C "$dir" mv "lineage_${DEVICE}.mk" "yiuos_${DEVICE}.mk" 2>/dev/null || \
            mv "$mk" "$dir/yiuos_${DEVICE}.mk"
        sed -i "s|lineage_${DEVICE}|yiuos_${DEVICE}|g" \
            "$dir/yiuos_${DEVICE}.mk" "$dir/AndroidProducts.mk"
    done
fi

# 5. Build
source build/envsetup.sh
if [ -n "$DEVICE" ]; then
    lunch "yiuos_${DEVICE}-${RELEASE}-${VARIANT}"
    m bacon
else
    lunch "yiuos_gsi_arm64-${RELEASE}-${VARIANT}"
    m
fi
