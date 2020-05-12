//
//  Device.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/19/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject
+(void)storePushToken:(NSString*)token;
+(NSString*)getDevicePushToken;
+(NSString*)getDeviceUniqueID;
+(NSString*)getDeviceType;
+(BOOL)isIphone5;
@end
