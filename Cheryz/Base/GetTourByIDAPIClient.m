//
//  GetTourByIDAPIClient.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/7/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "GetTourByIDAPIClient.h"

@implementation GetTourByIDAPIClient
+ (void)getTourWithID:(NSString*)tourID success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    NSString* path = [NSString stringWithFormat:@"tours/%@",tourID];
    [self GET:path params:nil success:^(CHAPIResponse *response) {
        success(response.body);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
@end
