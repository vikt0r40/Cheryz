//
//  Device.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/19/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Device.h"
#import <UIKit/UIKit.h>

@implementation Device
+(void)storePushToken:(NSString*)token {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"PUSH_DEVICE_TOKEN"];
    [defaults synchronize];
}
+(NSString*)getDevicePushToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"PUSH_DEVICE_TOKEN"];
}
+(NSString*)getDeviceUniqueID {
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    
    return currentDeviceId;
}
+(NSString*)getDeviceType {
    return @"iOS";
}
+(BOOL)isIphone5 {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 568)
        {
            return YES;
        }
        else {
            return NO;
        }
    }
    return NO;
}
@end
