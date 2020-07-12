#import <AudioToolbox/AudioServices.h>
#import <UserNotifications/UserNotifications.h>
#include <dlfcn.h>

@interface CPNotification : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId;
@end

static float alertShowPercentage;
static bool alertShown = false;
static bool setLowPowerMode = false;

NSString* lowBatteryAlertTitle = [NSString stringWithFormat:@"Low Battery"];
NSString* lowBatteryAlertMessage = [NSString stringWithFormat:@"%d%% battery remaining.", (int)alertShowPercentage];

%hook SBLowPowerAlertItem

+(BOOL)_shouldIgnoreChangeToBatteryLevel:(unsigned)arg1 {
	NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults]persistentDomainForName:@"com.popsicletreehouse.fivepercentalertprefs"];
	bool showAsNotiff = [[bundleDefaults objectForKey:@"showAsNotiff"]boolValue];
	bool isEnabledf = [[bundleDefaults objectForKey:@"isEnabledf"]boolValue];
	NSInteger alertShowPercentageInt = [([bundleDefaults objectForKey:@"whenAlertShows"] ?: @(5)) integerValue];
	alertShowPercentage = (float)alertShowPercentageInt;
	if (isEnabledf == false) return %orig;

	UIDevice *myDevice = [UIDevice currentDevice];
	BOOL wasEnabled = myDevice.batteryMonitoringEnabled;
	//if (!wasEnabled) [myDevice setBatteryMonitoringEnabled:YES];
	float myDeviceCharge = myDevice.batteryLevel;
	if (!wasEnabled) [myDevice setBatteryMonitoringEnabled:NO]; // restore it back to what it was

	float batteryThreshold = alertShowPercentage/100.00;

	if (alertShowPercentage < 1.0) {
		alertShowPercentage = 1.0;
	}
	if (alertShowPercentage > 100.0) {
		alertShowPercentage = 100.0;
	}
	if (myDeviceCharge <= batteryThreshold && !alertShown && showAsNotiff == false) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:lowBatteryAlertTitle message:lowBatteryAlertMessage preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		UIAlertAction *lowPowerMode = [UIAlertAction actionWithTitle:@"Low Power Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {setLowPowerMode = true;}];
		[alertController addAction:lowPowerMode];
		[alertController addAction:confirmAction];
		[alertController setPreferredAction:confirmAction];
		[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:^{}];
		alertShown = true;
	} else if (myDeviceCharge <= batteryThreshold && !alertShown && showAsNotiff == true) {
		void *handle = dlopen("/usr/lib/libnotifications.dylib", RTLD_LAZY);
		if (handle != NULL) {                                            
    	[objc_getClass("CPNotification") showAlertWithTitle:lowBatteryAlertTitle
                                                message:lowBatteryAlertMessage
                                               userInfo:@{@"" : @""}
                                             badgeCount:1
                                              soundName:@"can be nil.caff" //research UNNotificationSound
                                                  delay:1.00 //cannot be zero & cannot be < 60 if repeats is YES
                                                repeats:NO
                                               bundleId:@"com.apple.Preferences"];                                     
											dlclose(handle);
}
		alertShown = true;
	} else if (myDeviceCharge > batteryThreshold && alertShown) {
		alertShown = false;
	}
	
	return %orig;
}
-(void)_enableLowPowerMode {
	if(setLowPowerMode) {
	%orig;
	} else {
		return;
	}
}
%end