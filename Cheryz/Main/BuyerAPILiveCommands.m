//
//  BuyerAPILiveCommands.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/4/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "BuyerAPILiveCommands.h"
#import <UIKit/UIKit.h>
#import "LiveCommandClient.h"

@implementation BuyerAPILiveCommands
+ (void)askWithImageData:(NSData *)data
                  tourID:(NSString *)tourID
                   point:(CGPoint)point
                   storeProductID:(NSString *)storeProductID
                 success:(void (^)(NSDictionary *response))success
                 failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [[self getParams] mutableCopy];
    params[@"tour_id"] = tourID;
    params[@"transaction_uid"] = @"getinfo_transaction";
    
    params[@"salesforce_product_id"] = storeProductID;
    //params[@"point_x"] = @(point.x);
    //params[@"point_y"] = @(point.y);
    
    [self PUT:@"tour_show_requests" data:data filename:@"image.jpg" params:params success:^(CHAPIResponse *response) {
        success(response.body);
    } failure:failure];

}
+ (NSDictionary *)getParams{
    return @{
             @"token_id": [[CHUserToken sharedInstance] getAccessToken],
             @"ses_id": [LiveCommandClient sharedInstance].sessionID
             };
}
@end
