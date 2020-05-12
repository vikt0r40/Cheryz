//
//  ToursAPI.m
//  CheryzFramework
//
//  Created by Viktor Todorov on 29.04.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import "ToursAPI.h"

@implementation ToursAPI
+ (void)loadTours:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    [self GET:@"tours/my_tours" params:nil success:^(CHAPIResponse *response) {
        success(response.body);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
+ (void)loadRequestTranslation:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    params[@"without_time"] = @(false);
    [self POST:@"tours/get_requests_translation" params:params success:^(CHAPIResponse *response) {
        success(response.body);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
@end
