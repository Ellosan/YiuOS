# Inherit mobile full common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/common_mobile_full.mk)

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode?=true

$(call inherit-product, vendor/yiuos/config/telephony.mk)
