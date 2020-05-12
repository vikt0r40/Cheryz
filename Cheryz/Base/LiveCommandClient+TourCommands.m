//
//  LiveCommandClient+TourCommands.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "LiveCommandClient+TourCommands.h"
#import "Message.h"
#import "Product.h"
#import "InfoRequest.h"
#import "BuyRequest.h"
#import "Order.h"
#import "User.h"

NSInteger const kAllMessagessByGroupReplyCode = 0x1003;
NSInteger const kNewMessageByGroupReplyCode = 0x1000;
NSString * const kNewMessagesListenerKey = @"NewMessagesListenerKey";

NSInteger const kStartTourBroadcastingReplyCode = 0x2000;
NSString * const kStartTourBroadcastingListenerKey = @"StartTourBroadcastingListenerKey";

NSInteger const kStopTourBroadcastingReplyCode = 0x2001;
NSString * const kStopTourBroadcastingListenerKey = @"StopTourBroadcastingListenerKey";

NSInteger const kItemCreatedInTourReplyCode = 0x2005;
NSString * const kItemCreatedInTourListenerKey = @"ItemCreatedInTourListenerKey";

NSInteger const kDiscoveryStartedInTourReplyCode = 0x2006;
NSString * const kDiscoveryStartedInTourListenerKey = @"DiscoveryStartedInTourListenerKey";


NSInteger const kFinishTourReplyCode = 0x2007;
NSString * const kFinishTourListenerKey = @"FinishTourListenerKey";

NSInteger const kItemBuyRequestReplyCode = 0x2010;
NSString * const kItemBuyRequestListenerKey = @"ItemBuyRequestListenerKey";

NSInteger const kItemBuyResponseReplyCode = 0x2011;
NSString * const kItemBuyResponseListenerKey = @"ItemBuyResponseListenerKey";

NSInteger const kItemListCreatedInTourReplyCode = 0x2100;
NSString * const kItemListCreatedInTourListenerKey = @"ItemListCreatedInTourListenerKey";


NSInteger const kInfoRequestInTourReplyCode = 0x2012;
NSString * const kInfoRequestInTourListenerKey = @"InfoRequestInTourListenerKey";

NSInteger const kInfoStartInTourReplyCode = 0x2034;
NSString * const kInfoStartInTourListenerKey = @"InfoStartInTourListenerKey";

NSInteger const kInfoResponseInTourReplyCode = 0x2034;
NSString * const kInfoResponseInTourListenerKey = @"InfoResponseInTourListenerKey";

NSInteger const kOrderListCreatedInTourReplyCode = 0x2200;
NSString * const kOrderListCreatedInTourListenerKey = @"OrderListCreatedInTourListenerKey";

NSInteger const kOrderCreatedInTourReplyCode = 0x2201;
NSString * const kOrderCreatedInTourListenerKey = @"OrderCreatedInTourListenerKey";

NSInteger const kUsersInTourReplyCode = 0x2017;
NSString * const kUsersInTourListenerKey = @"UsersInTourListenerKey";

NSInteger const kChecksInTourReplyCode = 0x2018;
NSString * const kChecksInTourListenerKey = @"ChecksInTourListenerKey";

NSInteger const kTourIsFinishedReplyCode = 0x2019;
NSString * const kTourIsFinishedListenerKey = @"TourIsFinishedListenerKey";

NSInteger const kTourCurrentProductPriceIsUpdatedReplyCode = 0x2020;
NSString * const kTourCurrentProductPriceIsUpdatedListenerKey = @"TourCurrentProductPriceIsUpdatedListenerKey";

@implementation LiveCommandClient (TourCommands)

-(void)sendTextMessage:(NSString *)message
          toUserWithID:(NSString *)userID
      inMessageGroupID:(NSString *)messageGroupID
       responseHandler:(LCCResponseHandler)responseHandler;{
    [self sendCommand:@"send_msg" parameters:@{@"group_id":messageGroupID, @"to_id":userID, @"msg_text":message} responseHandler:responseHandler];
}

-(void)startReceiveNewMessagesFromGroup:(NSString *)groupID
                          lastMessageID:(NSNumber *)lastMessageID
                                  limit:(NSNumber *)limit
                        responseHandler:(LCCResponseHandler)responseHandler;{
    [self addNotification:kNewMessagesListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kAllMessagessByGroupReplyCode|| [dictionary[@"reply_code"] integerValue]==kNewMessageByGroupReplyCode;

    }
     andTransformResult:^id(NSDictionary *dictionary) {
         NSMutableArray *messages = [NSMutableArray new];
         if([dictionary[@"data"] isKindOfClass:[NSArray class]]){
             [dictionary[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 if([obj isKindOfClass:[NSDictionary class]]){
                     Message *msg = [Message messageFromDictionary:obj];
                     if([msg.messageText isKindOfClass:[NSString class]] && ![msg.messageText isEqualToString:@""]) {
                         [messages addObject:msg];
                     }
                 }
             }];
         }else if([dictionary[@"data"] isKindOfClass:[NSDictionary class]]){
             Message *msg = [Message messageFromDictionary:dictionary[@"data"]];
             if([msg.messageText isKindOfClass:[NSString class]] && ![msg.messageText isEqualToString:@""]) {
                 [messages addObject:msg];
             }
         }
         return messages;
     }
     ];

    NSDictionary * command = [self sendCommand:@"subscribe_to_msg_stream"
           parameters:@{
                        @"group_id":groupID,
                        @"last_msg_id":lastMessageID,
                        @"limit":limit
                        }
      responseHandler:^(NSDictionary *dictionary , BOOL success) {
          NSLog(@"Was subscribed %@",dictionary);
          responseHandler(dictionary, success);
      }];
    if(command){
        [self addSubscriptionCommand:command];
    }
}

-(void)updateMessagesSubscriptionWithGroupID:(NSString *)groupID lastMessageID:(NSNumber *)lastMessageID{
    [self updateSubscriptionCommandsPassedFilter:^BOOL(NSDictionary *command) {
        return [command[@"group_id"] isEqualToString:groupID]&&[command[@"request"] isEqualToString:@"subscribe_to_msg_stream"];
    } updateBlock:^NSDictionary *(NSDictionary *command) {
        NSMutableDictionary *updatedCommand = [command mutableCopy];
        updatedCommand[@"last_msg_id"] = lastMessageID;
        return updatedCommand;
    }];
}

-(void)stopReceiveNewMessagesWithResponseHandler:(LCCResponseHandler)responseHandler{
    [self removeNotification:kNewMessagesListenerKey];
    [self sendCommand:@"unsubscribe_all_msg_stream" parameters:@{} responseHandler:^(NSDictionary *dictionary , BOOL success) {
        //NSLog(@"Was unsubscribed %@",dictionary);
        responseHandler(dictionary, success);
    }];
    [self removeSubscriptionCommandPassedFilter:^BOOL(NSDictionary *command) {
        return [command[@"request"] isEqualToString:@"subscribe_to_msg_stream"];
    }];
}
-(void)getStreamingConfigForTourID:(NSString *)tourID responseHandler:(LCCResponseHandler)responseHandler{
    [self sendCommand:@"get_tour_stream_config" parameters:@{@"tour_id":tourID} responseHandler:responseHandler];
}


-(void)startReceiveEventsFromTourWithID:(NSString *)tourID responseHandler:(LCCResponseHandler)responseHandler{
    
    [self addNotification:kStartTourBroadcastingListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kStartTourBroadcastingReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           return tourID;
       }
     ];
    
    [self addNotification:kStopTourBroadcastingListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kStopTourBroadcastingReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           return tourID;
       }
     ];
    
    [self addNotification:kFinishTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kFinishTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           return tourID;
       }
     ];
    [self addNotification:kItemBuyResponseListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kItemBuyResponseReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           return dictionary;
       }
     ];
    
    [self addNotification:kItemBuyRequestListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kItemBuyRequestReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           BuyRequest *buyRequest = [[BuyRequest alloc] init];
           buyRequest.comment = dictionary[@"data"][@"buy_request"][@"comment"];
           buyRequest.requestID = dictionary[@"data"][@"buy_request"][@"request_id"];
           buyRequest.quantity = [dictionary[@"data"][@"buy_request"][@"count"] intValue];
           buyRequest.imageURL = dictionary[@"data"][@"buy_request"][@"product_photo"];
           buyRequest.username = [NSString stringWithFormat:@"%@ %@",dictionary[@"data"][@"buy_request"][@"fname"],dictionary[@"data"][@"buy_request"][@"lname"]];
           
           return buyRequest;
       }
     ];
    
    [self addNotification:kItemCreatedInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kItemCreatedInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           Product *item = [Product new];
           item.productImageUrl = dictionary[@"data"][@"image"];
           item.productID = dictionary[@"data"][@"id"];
           item.isCurrent = YES;
           item.storeProductID = dictionary[@"data"][@"salesforce_product_id"];
        
           return item;
       }
     ];
    
    [self addNotification:kDiscoveryStartedInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kDiscoveryStartedInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           return dictionary;
       }
     ];
    
    [self addNotification:kItemListCreatedInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kItemListCreatedInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           NSMutableArray *items = [NSMutableArray new];
           [dictionary[@"data"][@"products"] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               Product *item = [Product new];
               item.isPurchased = [obj[@"is_buyed"] boolValue];
               item.productImageUrl = obj[@"image"];
               item.productID = obj[@"product_id"];
               item.storeProductID = obj[@"salesforce_product_id"];
               item.isCurrent = [item.productID isEqualToString:dictionary[@"data"][@"current_product"]];
               //item.productPrice = [NSString stringWithFormat:@"%@",obj[@"price"]];
               item.price = [Price priceFromDictionary:obj[@"price"]];
               item.visibility = [obj[@"visible_type"] intValue];
               item.productName = obj[@"title"];
               [items addObject:item];
           }];
           return [items copy];
       }
     ];
    
    [self addNotification:kInfoResponseInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kInfoResponseInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           NSDictionary *infoRequestDict = dictionary[@"data"];
           InfoRequest *infoRequest = [[InfoRequest alloc] init];
           infoRequest.requestID = infoRequestDict[@"request_id"];
           return infoRequest;
       }
     ];
    
    
    [self addNotification:kInfoRequestInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kInfoRequestInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           NSDictionary *infoRequestDict = dictionary[@"data"][@"tour_show_requests"];
           InfoRequest *infoRequest = [[InfoRequest alloc] init];
           infoRequest.requestID = infoRequestDict[@"request_id"];
           infoRequest.username = [NSString stringWithFormat:@"%@ %@",infoRequestDict[@"user_fname"],infoRequestDict[@"user_lname"]];
           infoRequest.imageURL = infoRequestDict[@"image_url"];
           infoRequest.point = CGPointMake([infoRequestDict[@"point_x"] floatValue], [infoRequestDict[@"point_y"] floatValue]);
           return infoRequest;
       }
     ];

    [self addNotification:kInfoStartInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kInfoStartInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           NSDictionary *infoRequestDict = dictionary[@"data"][@"tour_show_requests"];
           InfoRequest *infoRequest = [[InfoRequest alloc] init];
           //infoRequest.requestID = infoRequestDict[@"request_id"];
           infoRequest.username = [NSString stringWithFormat:@"%@ %@",infoRequestDict[@"user_fname"],infoRequestDict[@"user_lname"]];
           infoRequest.imageURL = infoRequestDict[@"image_url"];
           //infoRequest.point = CGPointMake([infoRequestDict[@"point_x"] floatValue], [infoRequestDict[@"point_y"] floatValue]);
           return infoRequest;
       }
     ];
    
    [self addNotification:kOrderListCreatedInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kOrderListCreatedInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           NSMutableArray *array = [NSMutableArray new];
           if(dictionary[@"data"] && [dictionary[@"data"] isKindOfClass:[NSDictionary class]]){
               NSDictionary *data = dictionary[@"data"];
           
               if(data[@"orders"]){
                   if([data[@"orders"] isKindOfClass:[NSArray class]]){
                       [data[@"orders"] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                           Order *order = [Order new];
                           order.buyer = [User new];
                           order.buyer.firstName = obj[@"user_fname"];
                           order.buyer.lastName = obj[@"user_lname"];
                           order.orderID = obj[@"order_id"];
    //                       order.buyerName = [NSString stringWithFormat:@"%@ %@", obj[@"user_fname"], obj[@"user_lname"]];
                           order.imageUrl = obj[@"product_photo"];
                           order.productPrice = [Price priceFromDictionary:obj[@"price"]];
                           order.deliveryReward = [Price priceFromDictionary:obj[@"delivery_price"]];
                           order.number = [NSString stringWithFormat:@"%@",obj[@"count"]];
                           order.count = [obj[@"count"] intValue];
                           order.product_id = obj[@"product_id"];
                           [array addObject:order];
                       }];
                   }
               }
           }
           return array;
           //return dictionary;
       }
     ];
    
    [self addNotification:kChecksInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kChecksInTourReplyCode;
  } andTransformResult:^id(NSDictionary *dictionary) {
      NSMutableArray *array = [NSMutableArray new];
      if([dictionary[@"data"][@"tour_checks"] isKindOfClass:[NSArray class]]){
          [dictionary[@"data"][@"tour_checks"] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
              [array addObject:obj[@"image"]];
          }];
      }
      
      return [array copy];
  }];
    
    [self addNotification:kOrderCreatedInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kOrderCreatedInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           NSDictionary *obj = dictionary[@"data"];
           Order *order = [Order new];
//           order.buyerName = [NSString stringWithFormat:@"%@ %@", obj[@"user_fname"], obj[@"user_lname"]];
           order.buyer = [User new];
           order.buyer.firstName = obj[@"user_fname"];
           order.buyer.lastName = obj[@"user_lname"];
           order.imageUrl = obj[@"product_photo"];
           order.productPrice = [Price priceFromDictionary:obj[@"price"]];
//           order.price = [obj[@"price"] doubleValue];
           order.number = [NSString stringWithFormat:@"%@",obj[@"count"]];
           order.count = [obj[@"count"] intValue];
           order.product_id = obj[@"product_id"];
           return order;
//           return dictionary;
       }
     ];
    
    [self addNotification:kUsersInTourListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kUsersInTourReplyCode;
  }
       andTransformResult:^id(NSDictionary *dictionary) {
           NSArray *array = dictionary[@"data"][@"online_users"];
           NSMutableArray *users = [NSMutableArray new];
           
           [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               User *user = [User new];
               user.firstName = obj[@"user_fname"];
               user.lastName = obj[@"user_lname"];
               user.imageURL = [NSURL URLWithString:obj[@"user_photo"]];
               user.userID = obj[@"user_id"];
               [users addObject:user];
           }];
           return users;
           //           return dictionary;
       }
     ];
    
    [self addNotification:kTourIsFinishedListenerKey
  forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
      return [dictionary[@"reply_code"] integerValue]==kTourIsFinishedReplyCode;
  } andTransformResult:^id(NSDictionary *dictionary) {
      return dictionary;
  }
     ]
    ;
    
    [self addNotification:kTourCurrentProductPriceIsUpdatedListenerKey forMessagesPassedFilter:^BOOL(NSDictionary *dictionary) {
        return [dictionary[@"reply_code"] integerValue]==kTourCurrentProductPriceIsUpdatedReplyCode;
    } andTransformResult:^id(NSDictionary *dictionary) {
        return dictionary[@"data"];
    }];
    NSDictionary * command = [self sendCommand:@"subscribe_to_brodcast_tour"
                                    parameters:@{
                                                 @"tour_id":tourID
                                                 }
                               responseHandler:responseHandler];
    [self addSubscriptionCommand:command];
}
-(void)stopReceiveEventsFromTourWithID:(NSString *)tourID responseHandler:(LCCResponseHandler)responseHandler;{
    
    [self removeNotification:kStartTourBroadcastingListenerKey];
    [self removeNotification:kStopTourBroadcastingListenerKey];
    [self removeNotification:kFinishTourListenerKey];
    [self removeNotification:kItemBuyRequestListenerKey];
    [self removeNotification:kItemBuyResponseListenerKey];
    [self removeNotification:kItemCreatedInTourListenerKey];
    [self removeNotification:kDiscoveryStartedInTourListenerKey];
    [self removeNotification:kItemListCreatedInTourListenerKey];
    [self removeNotification:kInfoRequestInTourListenerKey];
    [self removeNotification:kInfoResponseInTourListenerKey];
    [self removeNotification:kOrderListCreatedInTourListenerKey];
    [self removeNotification:kOrderCreatedInTourListenerKey];
    [self removeNotification:kInfoStartInTourListenerKey];
    [self removeNotification:kChecksInTourListenerKey];
    [self removeNotification:kTourCurrentProductPriceIsUpdatedListenerKey];
    
    [self sendCommand:@"unsubscribe_from_brodcast_tour"
           parameters:@{
                        @"tour_id":tourID
                        }
      responseHandler:responseHandler];
    [self removeSubscriptionCommandPassedFilter:^BOOL(NSDictionary *command) {
        return [command[@"request"] isEqualToString:@"subscribe_to_brodcast_tour"];
    }];
}
@end
