//
//  GetTourByIDAPIClient.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/7/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHAPIRequest.h"

@interface GetTourByIDAPIClient : CHAPIRequest
+ (void)getTourWithID:(NSString*)tourID success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;

@end
