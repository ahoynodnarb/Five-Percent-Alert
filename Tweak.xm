%hook SBLowPowerAlertItem
+(unsigned)_thresholdForLevel:(unsigned)level {
    %orig;
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    float myDeviceCharge = myDevice.batteryLevel;
    float battery = 5.0;
    if (myDeviceCharge <= battery) {
        //creates alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Power" message:@"5 battery remaining." delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil];
        //shows alert
        [alert show];
    }
return %orig;
}
%end