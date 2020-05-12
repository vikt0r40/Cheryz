//
//  CHAPIRequests.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/11/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHAPISettings.h"
#import "CHAPIResponse.h"
#import "CHUserToken.h"

#define SAFETY_PARAM(obj) \
(!obj)?[NSNull null]:obj

@interface CHAPIRequest : NSObject
+ (instancetype)sharedInstance;
+ (void)GET:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure;
+ (void)POST:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure;
+ (void)DELETE:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure;
+ (void)PUT:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure;
+ (void)PUT:(NSString*)path data:(NSData*)data filename:(NSString*)filename params:(NSDictionary *)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure;
+ (void)cancel;
+ (NSInteger)httpStatusCodeFromError:(NSError*)error;
+ (NSString *)apiURLAppendWithPath:(NSString*)path;
@end
