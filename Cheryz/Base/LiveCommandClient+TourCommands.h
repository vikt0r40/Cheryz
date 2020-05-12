//
//  LiveCommandClient+TourCommands.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "LiveCommandClient.h"

extern NSString * const kNewMessagesListenerKey;
extern NSString * const kStartTourBroadcastingListenerKey;
extern NSString * const kStopTourBroadcastingListenerKey;
extern NSString * const kFinishTourListenerKey;
extern NSString * const kItemBuyRequestListenerKey;
extern NSString * const kItemBuyResponseListenerKey;
extern NSString * const kItemCreatedInTourListenerKey;
extern NSString * const kDiscoveryStartedInTourListenerKey;
extern NSString * const kItemListCreatedInTourListenerKey;
extern NSString * const kInfoRequestInTourListenerKey;
extern NSString * const kInfoStartInTourListenerKey;
extern NSString * const kInfoResponseInTourListenerKey;
extern NSString * const kOrderCreatedInTourListenerKey;
extern NSString * const kOrderListCreatedInTourListenerKey;
extern NSString * const kUsersInTourListenerKey;
extern NSString * const kChecksInTourListenerKey;
extern NSString * const kTourIsFinishedListenerKey;
extern NSString * const kTourCurrentProductPriceIsUpdatedListenerKey;

@interface LiveCommandClient (TourCommands)

-(void)sendTextMessage:(NSString *)message toUserWithID:(NSString *)userID inMessageGroupID:(NSString *)messageGroupID responseHandler:(LCCResponseHandler)responseHandler;

-(void)startReceiveNewMessagesFromGroup:(NSString *)groupID
                          lastMessageID:(NSNumber *)lastMessageID
                                  limit:(NSNumber *)limit
                        responseHandler:(LCCResponseHandler)responseHandler;

-(void)stopReceiveNewMessagesWithResponseHandler:(LCCResponseHandler)responseHandler;
-(void)updateMessagesSubscriptionWithGroupID:(NSString *)groupID lastMessageID:(NSNumber *)lastMessageID;
-(void)getStreamingConfigForTourID:(NSString *)tourID responseHandler:(LCCResponseHandler)responseHandler;
-(void)startReceiveEventsFromTourWithID:(NSString *)tourID responseHandler:(LCCResponseHandler)responseHandler;
-(void)stopReceiveEventsFromTourWithID:(NSString *)tourID responseHandler:(LCCResponseHandler)responseHandler;

@end
