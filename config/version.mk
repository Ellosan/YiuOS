PRODUCT_VERSION_MAJOR = 23
PRODUCT_VERSION_MINOR = 2

ifeq ($(YIUOS_VERSION_APPEND_TIME_OF_DAY),true)
    YIUOS_BUILD_DATE := $(shell date -u +%Y%m%d_%H%M%S)
else
    YIUOS_BUILD_DATE := $(shell date -u +%Y%m%d)
endif

# Set YIUOS_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef YIUOS_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "YIUOS_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^YIUOS_||g')
        YIUOS_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(YIUOS_BUILDTYPE)),)
    YIUOS_BUILDTYPE := UNOFFICIAL
    YIUOS_EXTRAVERSION :=
endif

ifeq ($(YIUOS_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        YIUOS_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

YIUOS_VERSION_SUFFIX := $(YIUOS_BUILD_DATE)-$(YIUOS_BUILDTYPE)$(YIUOS_EXTRAVERSION)-$(YIUOS_BUILD)

# Internal version
YIUOS_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(YIUOS_VERSION_SUFFIX)

# Display version
YIUOS_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR)-$(YIUOS_VERSION_SUFFIX)

# YiuOS version properties
PRODUCT_PRODUCT_PROPERTIES += \
    ro.yiuos.version=$(YIUOS_VERSION) \
    ro.yiuos.display.version=$(YIUOS_DISPLAY_VERSION) \
    ro.yiuos.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.yiuos.releasetype=$(YIUOS_BUILDTYPE)
