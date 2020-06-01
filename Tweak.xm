#import <AudioToolbox/AudioServices.h>

static bool alertShown = false;

static BOOL isEnabled = YES;
static float alertShowPercentage;

%hook SBLowPowerAlertItem

+(BOOL)_shouldIgnoreChangeToBatteryLevel:(unsigned)arg1 {
	HBLogDebug(@"_shouldIgnoreChangeToBatteryLevel has been called");

	if (!isEnabled) return %orig;

	UIDevice *myDevice = [UIDevice currentDevice];
	BOOL wasEnabled = myDevice.batteryMonitoringEnabled;
	[myDevice setBatteryMonitoringEnabled:YES];
	float myDeviceCharge = myDevice.batteryLevel;
	if (!wasEnabled) [myDevice setBatteryMonitoringEnabled:wasEnabled]; // restore it back to what it was

	float batteryThreshold = alertShowPercentage/100.00;

	if (myDeviceCharge <= batteryThreshold && !alertShown) {
		NSString* lowBatteryAlertstr = [NSString stringWithFormat:@"%d%% battery remaining.", (int)alertShowPercentage];
		AudioServicesPlaySystemSound(1503);
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Low Battery" message:lowBatteryAlertstr preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:confirmAction];
		[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:^{}];
		alertShown = true;
	} else if (myDeviceCharge > batteryThreshold && alertShown) {
		alertShown = false;
	}
	
	return %orig;
}

%end

static void refreshPrefs() {
	HBLogDebug(@"Refreshing preferences...");

	NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults]persistentDomainForName:@"com.popsicletreehouse.fivepercentalertprefs"];

	isEnabled = [([bundleDefaults objectForKey:@"isEnabled"] ?: @(YES)) boolValue];
	NSInteger alertShowPercentageInt = [([bundleDefaults objectForKey:@"whenAlertShows"] ?: @(5)) integerValue];
	alertShowPercentage = (float)alertShowPercentageInt;

	if (alertShowPercentage < 1.0){
		alertShowPercentage = 1.0;
	}
	if (alertShowPercentage > 100.0){
		alertShowPercentage = 100.0;
	}

	alertShown = false;

	HBLogDebug(@"isEnabled = %d, alertShowPercentage = %ld", isEnabled, (long)alertShowPercentageInt);
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    refreshPrefs();
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.popsicletreehouse.fivepercentalert.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}
