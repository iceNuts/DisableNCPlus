GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TWEAK_NAME = DisableNC
DisableNC_FILES = Tweak.xm
DisableNC_FRAMEWORKS = UIKit
DisableNC_PRIVATE_FRAMEWORKS = AppSupport Preferences

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 6.0

include $(THEOS_MAKE_PATH)/tweak.mk
