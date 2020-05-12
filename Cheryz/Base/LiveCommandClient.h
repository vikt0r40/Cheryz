//
//  LiveCommandClient.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/17/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kWebSocketConnectionSuccesfull;
extern NSString *const kWebSocketConnectionFailed;


typedef void (^LCCResponseHandler)(NSDictionary *, BOOL);

typedef BOOL(^ServerResponseDictionaryFilter)(NSDictionary *);
@interface LiveCommandClient : NSObject
@property (nonatomic, strong) NSString *sessionID;
+(instancetype)sharedInstance;
-(void)setup;
-(void)connect:(void(^)(BOOL))complitionHandler;
-(void)disconnect;
-(void)reconnect;

@property (nonatomic) BOOL isConnected;

-(NSDictionary *)sendCommand:(NSString *)command parameters:(NSDictionary *)parameters responseHandler:(void (^)(NSDictionary *, BOOL))responseHandler;

-(void)addNotification:(NSString*)notification forMessagesPassedFilter:(BOOL(^)(NSDictionary *))filter andTransformResult:(id(^)(NSDictionary *))transform;
-(void)removeNotification:(NSString*)notification;

-(void)addSubscriptionCommand:(NSDictionary *)command;
-(void)removeSubscriptionCommandPassedFilter:(BOOL(^)(NSDictionary *))filter;
-(void)removeAllSubscriptionCommands;
-(void)updateSubscriptionCommandsPassedFilter:(BOOL(^)(NSDictionary *))filter updateBlock:(NSDictionary *(^)(NSDictionary *))update;
@end
