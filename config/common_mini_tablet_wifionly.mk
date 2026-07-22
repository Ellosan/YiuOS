# Inherit mobile mini common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/common_mobile_mini.mk)

# Inherit tablet common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/tablet.mk)

$(call inherit-product, vendor/yiuos/config/wifionly.mk)
