# YiuOS common configuration
# Inherited by all YiuOS product makefiles.

# --- Versioning ---
YIUOS_VERSION_MAJOR := 1
YIUOS_VERSION_MINOR := 0
YIUOS_CODENAME := Origin
YIUOS_VERSION := $(YIUOS_VERSION_MAJOR).$(YIUOS_VERSION_MINOR)

# --- Branding properties baked into build.prop ---
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.yiuos.version=$(YIUOS_VERSION) \
    ro.yiuos.codename=$(YIUOS_CODENAME) \
    ro.yiuos.releasetype=UNOFFICIAL

PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_DISPLAY_ID="YiuOS $(YIUOS_VERSION) ($(YIUOS_CODENAME))" \
    PRODUCT_BRAND=YiuOS

# Shown in Settings > About phone on many bases
PRODUCT_PRODUCT_PROPERTIES += \
    ro.build.flavor.yiuos=$(YIUOS_VERSION)-$(YIUOS_CODENAME)

# --- Resource overlays (rebrands "Android" strings in the UI) ---
PRODUCT_PACKAGE_OVERLAYS += vendor/yiuos/overlay/common

# --- Boot animation ---
# Drop a bootanimation.zip into vendor/yiuos/prebuilt/common/bootanimation/
# and uncomment the line below.
# PRODUCT_COPY_FILES += \
#     vendor/yiuos/prebuilt/common/bootanimation/bootanimation.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip

# --- Stock AOSP behavior: no extra apps, no gapps ---
# Intentionally empty. YiuOS 1.0 is a clean AOSP base.
