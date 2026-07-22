# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

$(call inherit-product, device/google/cuttlefish/vsoc_arm64/phone/aosp_cf.mk)

include vendor/yiuos/build/target/product/yiuos_generic_target.mk

TARGET_DISABLE_EPPE := true
TARGET_NO_KERNEL_OVERRIDE := true

# Overrides
PRODUCT_NAME := yiuos_cf_phone_arm64
PRODUCT_MODEL := YiuOS Cuttlefish phone built for arm64
