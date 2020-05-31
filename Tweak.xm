#import <AudioToolbox/AudioServices.h>

%hook SBLowPowerAlertItem
+(BOOL)_shouldIgnoreChangeToBatteryLevel:(unsigned)arg1 {
//ignores deprecated warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static bool alertShown = false;
static bool firstAlert = true;
static bool recharged = false;
//connects Root.plist to Tweak.xm
NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults]persistentDomainForName:@"com.popsicletreehouse.fivepercentalertprefs"];
id isEnabled = [bundleDefaults valueForKey:@"isEnabled"];
float whenAlertShow = [[[NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.popsicletreehouse.fivepercentalertprefs.plist"] objectForKey:@"whenAlertShows"] floatValue];

if ([isEnabled isEqual:@0]) {
		%orig;
}
else{
	%orig;
	UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
	float myDeviceCharge = myDevice.batteryLevel;

    float battery = whenAlertShow/100.00;
	int batRemaining = (int) whenAlertShow;
    if (myDeviceCharge <= battery && alertShown == false) {
		NSString* lowBatteryAlertstr = [NSString stringWithFormat:@"%i battery remaining.", batRemaining];
		AudioServicesPlaySystemSound(1503);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Low Power" message:lowBatteryAlertstr preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:confirmAction];
		[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:^{}];
        alertShown = true;
        firstAlert = false;
    }
	//in case battery recharged
    if(myDeviceCharge > battery && !firstAlert) {
        recharged = true;
    }
	//in case battery recharged but back to low health again allows looping back to first if statement
    else if (!firstAlert && myDeviceCharge < battery && recharged){
        alertShown = false;
    }
}
return %orig;
}
%end
