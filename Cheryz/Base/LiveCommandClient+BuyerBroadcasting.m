//
//  LiveCommandClient+BuyerBroadcasting.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/30/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "LiveCommandClient+BuyerBroadcasting.h"

@implementation LiveCommandClient (BuyerBroadcasting)
-(void)sendBuyRequestWithTourID:(NSString *)tourID
                         itemID:(NSString *)itemID
                       quantity:(NSNumber *)quantity
                        comment:(NSString *)comment
                responseHandler:(LCCResponseHandler)responseHandler{

    [self sendCommand:@"buy_product_request" parameters:@{@"tour_id":tourID, @"product_id":itemID, @"comment":comment, @"count":quantity} responseHandler:responseHandler];

}
@end
