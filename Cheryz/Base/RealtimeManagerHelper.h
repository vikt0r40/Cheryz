//
//  RealtimeManagerHelper.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 2/20/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RealtimeStateUpdater)(NSUInteger state);

@interface RealtimeManagerHelper : NSObject
+(instancetype) sharedInstance;
@property (nonatomic, copy) RealtimeStateUpdater sipStateUpdater;
@property (nonatomic, copy) RealtimeStateUpdater mainWssStateUpdater;
@property (nonatomic, copy) RealtimeStateUpdater videoBroadcastStateUpdater;
@property (nonatomic, copy) RealtimeStateUpdater videoWssStateUpdater;
+(void)updateSipState:(NSInteger)state;
+(void)updateMainWssState:(NSInteger)state;
+(void)updateVideoBroadcastState:(NSInteger)state;
+(void)updateVideoWssState:(NSInteger)state;
@end
