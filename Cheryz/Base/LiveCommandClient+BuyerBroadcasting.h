//
//  LiveCommandClient+BuyerBroadcasting.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/30/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "LiveCommandClient.h"

@interface LiveCommandClient (BuyerBroadcasting)
-(void)sendBuyRequestWithTourID:(NSString *)tourID
                         itemID:(NSString *)itemID
                       quantity:(NSNumber *)quantity
                        comment:(NSString *)comment
                responseHandler:(LCCResponseHandler)responseHandler;
@end
