# YiuOS generic x86_64 target (Android Emulator)
# Good first target: builds and boots without real hardware.

# Inherit the stock AOSP emulator product
$(call inherit-product, device/generic/goldfish/64bitonly/product/sdk_phone64_x86_64.mk)

# Inherit YiuOS branding
$(call inherit-product, vendor/yiuos/config/common.mk)

PRODUCT_NAME := yiuos_sdk_phone64_x86_64
PRODUCT_DEVICE := emu64x
PRODUCT_BRAND := YiuOS
PRODUCT_MODEL := YiuOS Emulator
PRODUCT_MANUFACTURER := YiuOS Project
