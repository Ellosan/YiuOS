# Inherit mobile full common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/common_mobile_full.mk)

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode?=true

# Inherit tablet common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/tablet.mk)

$(call inherit-product, vendor/yiuos/config/telephony.mk)

PRODUCT_PACKAGE_OVERLAYS += vendor/yiuos/overlay/foldable_book
