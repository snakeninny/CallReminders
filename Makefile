ARCHS = armv7
TARGET = iphone:latest:4.3

include theos/makefiles/common.mk

TWEAK_NAME = CallReminders
CallReminders_FILES = Tweak.xm CallRemindersDelegates.m
CallReminders_FRAMEWORKS = UIKit EventKit AddressBook

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)cp -r PreferenceBundles $(THEOS_STAGING_DIR)/Library$(ECHO_END)
	$(ECHO_NOTHING)cp -r PreferenceLoader $(THEOS_STAGING_DIR)/Library$(ECHO_END)
