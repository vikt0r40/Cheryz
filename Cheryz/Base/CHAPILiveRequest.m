//
//  CHAPILiveRequest.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/29/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHAPILiveRequest.h"

@implementation CHAPILiveRequest
+ (NSString *)apiURLAppendWithPath:(NSString*)path{
    return [NSString stringWithFormat:@"%@/%@",API_LIVE_URL,path];
}
@end
