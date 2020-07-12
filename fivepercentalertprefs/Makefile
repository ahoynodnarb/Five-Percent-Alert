include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = fivepercentalertprefs

fivepercentalertprefs_FILES = PTFRootListController.m
fivepercentalertprefs_INSTALL_PATH = /Library/PreferenceBundles
fivepercentalertprefs_FRAMEWORKS = UIKit
fivepercentalertprefs_PRIVATE_FRAMEWORKS = Preferences
fivepercentalertprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/fivepercentalertprefs.plist$(ECHO_END)
