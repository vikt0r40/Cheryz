//
//  AuthorizationAPI.h
//  CheryzFramework
//
//  Created by Viktor Todorov on 28.04.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import "CHAPIRequest.h"

@interface AuthorizationAPI : CHAPIRequest
+ (void)autorizeWithAPI:(NSString*)apiKey userID:(NSString*)userID fName:(NSString*)fName lName:(NSString*)lName success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
@end

