//
//  ToursAPI.h
//  CheryzFramework
//
//  Created by Viktor Todorov on 29.04.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import "CHAPIRequest.h"

@interface ToursAPI : CHAPIRequest
+ (void)loadTours:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
+ (void)loadRequestTranslation:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
@end

