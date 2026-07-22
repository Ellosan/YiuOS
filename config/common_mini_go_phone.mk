# Set YiuOS specific identifier for Android Go enabled products
PRODUCT_TYPE := go

# Inherit mini common YiuOS stuff
$(call inherit-product, vendor/yiuos/config/common_mini_phone.mk)
