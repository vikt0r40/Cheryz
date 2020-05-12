//
//  RealtimeManagerHelper.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 2/20/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "RealtimeManagerHelper.h"

@implementation RealtimeManagerHelper
+(instancetype) sharedInstance{
    static RealtimeManagerHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [RealtimeManagerHelper new];
    });
    return helper;
}
+(void)updateSipState:(NSInteger)state{
    if([RealtimeManagerHelper sharedInstance].sipStateUpdater){
        [RealtimeManagerHelper sharedInstance].sipStateUpdater(state);
    }
}
+(void)updateMainWssState:(NSInteger)state{
    if([RealtimeManagerHelper sharedInstance].mainWssStateUpdater){
        [RealtimeManagerHelper sharedInstance].mainWssStateUpdater(state);
    }
    NSLog(@"MainWss state updated to %ld",state);
}
+(void)updateVideoBroadcastState:(NSInteger)state{
    if([RealtimeManagerHelper sharedInstance].videoBroadcastStateUpdater){
        [RealtimeManagerHelper sharedInstance].videoBroadcastStateUpdater(state);
    }
}
+(void)updateVideoWssState:(NSInteger)state{
    if([RealtimeManagerHelper sharedInstance].videoWssStateUpdater){
        [RealtimeManagerHelper sharedInstance].videoWssStateUpdater(state);
    }
    NSLog(@"VideoWSS state updated to %ld",state);
}
@end
