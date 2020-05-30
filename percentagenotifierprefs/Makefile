include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = percentagenotifierprefs

percentagenotifierprefs_FILES = BYDRootListController.m
percentagenotifierprefs_INSTALL_PATH = /Library/PreferenceBundles
percentagenotifierprefs_FRAMEWORKS = UIKit
percentagenotifierprefs_PRIVATE_FRAMEWORKS = Preferences
percentagenotifierprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/percentagenotifierprefs.plist$(ECHO_END)
