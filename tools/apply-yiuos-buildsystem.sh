#!/bin/bash -e
#
# Run from the top of a LineageOS source tree after `repo sync`.
#
# LineageOS's build/make fork hardcodes a few paths to vendor/lineage.
# This repo lives at vendor/yiuos instead, so point the build system there.

if [ ! -f build/make/envsetup.sh ] || [ ! -d vendor/yiuos ]; then
    echo "Run this from the top of a synced tree with vendor/yiuos in place." >&2
    exit 1
fi

sed -i \
    -e 's|vendor/lineage/build|vendor/yiuos/build|g' \
    build/make/envsetup.sh

sed -i \
    -e 's|vendor/lineage/config/BoardConfigLineage.mk|vendor/yiuos/config/BoardConfigYiuOS.mk|g' \
    -e 's|vendor/lineage-priv|vendor/yiuos-priv|g' \
    build/make/core/config.mk

# The AOSP GSI system-image module depends on Calendar and Gallery2, but the
# LineageOS manifest drops those repos in favor of Etar and Glimpse. Swap the
# deps so soong analysis of GSI products succeeds.
sed -i \
    -e 's|"Calendar",|"Etar",|' \
    -e 's|"Gallery2",|"Glimpse",|' \
    build/make/target/product/gsi/Android.bp

echo "Build system now points at vendor/yiuos. Re-run: source build/envsetup.sh"
