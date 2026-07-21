# YiuOS arm64 GSI (Generic System Image)
# Flashable on any Project Treble device (system image only).

# Inherit the stock AOSP arm64 GSI
$(call inherit-product, build/make/target/product/gsi_release.mk)
$(call inherit-product, device/generic/common/gsi_arm64.mk)

# Inherit YiuOS branding
$(call inherit-product, vendor/yiuos/config/common.mk)

PRODUCT_NAME := yiuos_gsi_arm64
PRODUCT_DEVICE := generic_arm64
PRODUCT_BRAND := YiuOS
PRODUCT_MODEL := YiuOS GSI arm64
PRODUCT_MANUFACTURER := YiuOS Project
