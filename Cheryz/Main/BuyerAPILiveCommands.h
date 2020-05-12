//
//  BuyerAPILiveCommands.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/4/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHAPILiveRequest.h"
#import <UIKit/UIKit.h>

@interface BuyerAPILiveCommands : CHAPILiveRequest
+ (void)askWithImageData:(NSData *)data
                  tourID:(NSString *)tourID
                   point:(CGPoint)point
          storeProductID:(NSString *)storeProductID
                 success:(void (^)(NSDictionary *response))success
                 failure:(void (^)(NSError *error))failure;
@end
