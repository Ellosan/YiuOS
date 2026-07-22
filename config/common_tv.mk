# Inherit common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/common.mk)

# Include AOSP audio files
$(call inherit-product-if-exists, frameworks/base/data/sounds/AudioTv.mk)

# Inherit YiuOS atv device tree
$(call inherit-product, device/yiuos/atv/yiuos_atv.mk)

# AOSP packages
PRODUCT_PACKAGES += \
    LeanbackIME

# YiuOS packages
PRODUCT_PACKAGES += \
    Catapult \
    LineageCustomizer

PRODUCT_PACKAGE_OVERLAYS += vendor/yiuos/overlay/tv
