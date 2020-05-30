//ignores deprecated warning									//reminder: Figure out whether you need firstAlert or not
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static bool alertShown = false;
static bool firstAlert = true;
static bool recharged = false;
%hook SBLowPowerAlertItem

+(BOOL)_shouldIgnoreChangeToBatteryLevel:(unsigned)arg1 {
    %orig;
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];

    float myDeviceCharge = myDevice.batteryLevel;
    float battery = 0.05;
    if (myDeviceCharge <= battery && alertShown == false) {
        //creates alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Power" message:@"5 battery remaining." delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil];
        //shows alert
        [alert show];
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
return %orig;
}
%end
