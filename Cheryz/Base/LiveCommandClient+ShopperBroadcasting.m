//
//  LiveCommandClient+ShopperBroadcasting.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/25/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "LiveCommandClient+ShopperBroadcasting.h"

@implementation LiveCommandClient (ShopperBroadcasting)

-(void)startBroadcastTourWithID:(NSString*)tourID responseHandler:(LCCResponseHandler)responseHandler{
    [self sendCommand:@"start_tour_broadcast" parameters:@{@"tour_id":tourID} responseHandler:responseHandler];
}

-(void)stopBroadcastTourWithID:(NSString*)tourID responseHandler:(LCCResponseHandler)responseHandler{
    [self sendCommand:@"stop_tour_broadcast" parameters:@{@"tour_id":tourID} responseHandler:responseHandler];
}

-(void)finishTourWithID:(NSString*)tourID responseHandler:(LCCResponseHandler)responseHandler{
    [self sendCommand:@"finish_tour" parameters:@{@"tour_id":tourID} responseHandler:responseHandler];
}

-(void)responseToBuyRequestWithID:(NSString *)requestID andStatus:(BuyRequestStatus)status responseHandler:(LCCResponseHandler)responseHandler{
    [self sendCommand:@"buy_product_reply" parameters:@{@"request_id":requestID, @"status":@(status)} responseHandler:responseHandler];
}
-(void)responseToInfoRequestWithID:(NSString *)requestID andStatus:(InfoRequestStatus)status responseHandler:(LCCResponseHandler)responseHandler{
    [self sendCommand:@"product_info_reply" parameters:@{@"request_id":requestID, @"status":@(status)} responseHandler:responseHandler];
}
-(void)updatePriceForCurrentProduct:(NSNumber *)price responseHandler:(LCCResponseHandler)responseHandler{
    [self sendCommand:@"change_price_of_current_product" parameters:@{@"price":price} responseHandler:responseHandler];
}
@end
