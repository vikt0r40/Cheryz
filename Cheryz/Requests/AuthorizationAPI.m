//
//  AuthorizationAPI.m
//  CheryzFramework
//
//  Created by Viktor Todorov on 28.04.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import "AuthorizationAPI.h"

@implementation AuthorizationAPI
+ (void)autorizeWithAPI:(NSString*)apiKey userID:(NSString*)userID fName:(NSString*)fName lName:(NSString*)lName success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {

    NSMutableDictionary* params = [NSMutableDictionary new];
    params[@"api_key"] = apiKey;
    params[@"user_id"] = userID;
    params[@"fname"] = fName;
    params[@"lname"] = lName;
    
    [self POST:@"users/auth" params:params success:^(CHAPIResponse *response) {
        success(response.body);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
@end
