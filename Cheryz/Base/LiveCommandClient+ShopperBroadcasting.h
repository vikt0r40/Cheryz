//
//  LiveCommandClient+ShopperBroadcasting.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/25/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "LiveCommandClient.h"

typedef enum : NSUInteger {
    DefaultBuyRequestStatus,
    AcceptedBuyRequestStatus,
    DeclinedBuyRequestStatus,
} BuyRequestStatus;

typedef enum : NSUInteger {
    DefaultInfoRequestStatus,
    AcceptedInfoRequestStatus,
    DeclinedInfoRequestStatus,
} InfoRequestStatus;

@interface LiveCommandClient (ShopperBroadcasting)
-(void)startBroadcastTourWithID:(NSString*)tourID responseHandler:(LCCResponseHandler)responseHandler;
-(void)stopBroadcastTourWithID:(NSString*)tourID responseHandler:(LCCResponseHandler)responseHandler;
-(void)finishTourWithID:(NSString*)tourID responseHandler:(LCCResponseHandler)responseHandler;
-(void)responseToBuyRequestWithID:(NSString *)requestID andStatus:(BuyRequestStatus)status responseHandler:(LCCResponseHandler)responseHandler;
-(void)responseToInfoRequestWithID:(NSString *)requestID andStatus:(InfoRequestStatus)status responseHandler:(LCCResponseHandler)responseHandler;
-(void)updatePriceForCurrentProduct:(NSNumber *)price responseHandler:(LCCResponseHandler)responseHandler;
@end
