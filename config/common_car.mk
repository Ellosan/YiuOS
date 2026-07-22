# Inherit common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/common.mk)

# Inherit YiuOS car device tree
$(call inherit-product, device/yiuos/car/yiuos_car.mk)
