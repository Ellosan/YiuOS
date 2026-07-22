# Inherit mobile full common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/common_mobile_full.mk)

# Inherit tablet common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/tablet.mk)

$(call inherit-product, vendor/yiuos/config/telephony.mk)
