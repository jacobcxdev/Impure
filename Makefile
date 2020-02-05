FINALPACKAGE = 1

ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = Pure

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Impure

Impure_FILES = Tweak.x
Impure_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
