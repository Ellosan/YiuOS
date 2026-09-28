# YiuOS for Sony Xperia XA1 (hinoki).
#
# The available hinoki hardware stack is based on Android 8.1, so this product
# deliberately inherits the proven LineageOS 15.1 device configuration rather
# than pretending that the Android 16 vendor tree can boot on the MT6757.

$(call inherit-product, device/sony/hinoki/lineage.mk)
$(call inherit-product, vendor/yiuos/legacy/hinoki/product.mk)

PRODUCT_NAME := yiuos_hinoki
PRODUCT_DEVICE := hinoki
PRODUCT_BRAND := YiuOS
PRODUCT_MODEL := Xperia XA1
PRODUCT_MANUFACTURER := Sony

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=hinoki \
    PRIVATE_BUILD_DESC="YiuOS-hinoki 8.1.0 OPM7 userdebug"

BUILD_FINGERPRINT := YiuOS/hinoki/hinoki:8.1.0/OPM7/yiuos:userdebug/test-keys
