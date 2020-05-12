//
//  LiveCommandClient.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/17/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "LiveCommandClient.h"
#import "CHAPISettings.h"
#import <SocketRocket/SocketRocket.h>
#import "CHUserToken.h"
#import "Currency.h"
#import "SessionSettings.h"

//NSString *const kWebSocketConnectionSuccesfull = @"WebSocketConnectionSuccesfull";
//NSString *const kWebSocketConnectionFailed = @"WebSocketConnectionFailed";
//NSString *const kWebSocketDidReceivedMessage = @"WebSocketDidReceivedMessage";
NSString *const kWebSocketConnectionSuccesfull = @"WebSocketConnectionSuccesfull";
NSString *const kWebSocketConnectionFailed = @"WebSocketConnectionFailed";

@interface ResponseBlockContainer : NSObject;
@property (nonatomic, copy) BOOL(^filter)(NSDictionary *);
@property (nonatomic, copy) id(^transform)(NSDictionary *);
@end

@implementation ResponseBlockContainer

@end

@interface LiveCommandClient()<SRWebSocketDelegate>

@property (nonatomic,strong) SRWebSocket* webSocket;
@property (nonatomic) BOOL reconnectRequired;
@property (nonatomic, strong) NSTimer *reconnectTimer;
@property (nonatomic) BOOL isFirstRequest;
@property (nonatomic) NSMutableDictionary *responseHandlers;
@property (nonatomic, copy) void (^connectionHandler)(BOOL);
@property (nonatomic) NSMutableDictionary *serverEventHandlers;
@property (nonatomic, strong) NSMutableSet *subscriptionCommands;

@end

@implementation LiveCommandClient
+ (instancetype)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static LiveCommandClient * _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        _sharedObject.reconnectRequired = NO;
        [_sharedObject setup];
    });
    
    // returns the same object each time
    return _sharedObject;
}
-(void)setup{
    self.subscriptionCommands = [NSMutableSet new];
    self.responseHandlers = [NSMutableDictionary new];
    self.serverEventHandlers = [NSMutableDictionary new];
    self.sessionID = nil;
    _isConnected = NO;
    __weak LiveCommandClient *weakSelf = self;
    self.connectionHandler = ^(BOOL success){
        _isConnected = success;
//        if(complitionHandler)
//            complitionHandler(success);
        if(success){
            if(weakSelf.subscriptionCommands.count>0){
                [weakSelf.subscriptionCommands enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, BOOL * _Nonnull stop) {
                    [weakSelf sendCommand:obj[@"request"] parameters:obj responseHandler:nil];
                }];
            }
        }else{
            [weakSelf.responseHandlers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                void (^handler)(NSDictionary *, BOOL)  = obj;
                handler(nil, NO);
            }];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:success? kWebSocketConnectionSuccesfull:kWebSocketConnectionFailed object:nil];
        
    };
}

-(void)connect:(void (^)(BOOL))complitionHandler{
    self.reconnectRequired = YES;
    if([self.reconnectTimer isValid]){
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
    }
    NSString *token = [[CHUserToken sharedInstance] getAccessToken];
    self.sessionID = nil;
    [SessionSettings defaultSettings].currency.currencyID = @"usd";
    NSString *urlString = SOCKET_URL;
    if(token && token.length>0){
        urlString = [urlString stringByAppendingString:token];
        urlString = [NSString stringWithFormat:@"%@?currency=%@", urlString, @"usd"];
        if([SessionSettings defaultSettings].wssSessionID){
            urlString = [NSString stringWithFormat:@"%@&kill_sess=%@", urlString, [SessionSettings defaultSettings].wssSessionID];
        }
    }
    NSLog(@"Connect with token %@",token);
    NSLog(@"Connect to WSS URL: %@",urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.];
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.webSocket.delegate = self;
    
    self.isFirstRequest = YES;
    
    
    [self.webSocket open];
}
-(void)reconnect{
    self.reconnectRequired = YES;
    [self.webSocket close];
    _isConnected = NO;
    self.webSocket = nil;
    self.sessionID = nil;
}
-(void)disconnect{
    NSLog(@"socket disconnect");
    self.reconnectRequired = NO;
    [self.webSocket close];
    _isConnected = NO;
    self.webSocket = nil;
    self.sessionID = nil;
}

-(void)addSubscriptionCommand:(NSDictionary *)command{
    [self.subscriptionCommands addObject:command];
}
-(void)removeSubscriptionCommandPassedFilter:(BOOL (^)(NSDictionary *))filter{
    [self.subscriptionCommands enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if(filter(obj)){
            [self.subscriptionCommands removeObject:obj];
        }
    }];
}
-(void)removeAllSubscriptionCommands{
    [self.subscriptionCommands removeAllObjects];
}

-(void)updateSubscriptionCommandsPassedFilter:(BOOL(^)(NSDictionary *))filter updateBlock:(NSDictionary *(^)(NSDictionary *))update{
    __weak LiveCommandClient *weakSelf = self;
    [self.subscriptionCommands enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if(filter(obj)){
            NSDictionary * newDict = update(obj);
            [weakSelf.subscriptionCommands removeObject:obj];
            [weakSelf.subscriptionCommands addObject:newDict];
            
        }
    }];
}

-(NSDictionary *)sendCommand:(NSString *)command parameters:(NSDictionary *)parameters responseHandler:(void (^)(NSDictionary *, BOOL))responseHandler{
    
    NSString *newCommandGUID = [self generateCommandGUID];
    if(responseHandler){
        self.responseHandlers[newCommandGUID] = responseHandler;
    }
    NSMutableDictionary *requestDict = [parameters mutableCopy];
    requestDict[@"request"] = command;
    requestDict[@"version"] = @1;
    requestDict[@"transaction_uid"] = newCommandGUID;
    if((!_isConnected)||(self.webSocket.readyState!=SR_OPEN)){
        
        if(responseHandler)
            responseHandler(nil,NO);
    
        return requestDict;
    }
    
    [self.webSocket send:[self jsonStringFromDictionay:requestDict]];
    
    return requestDict;
}
- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"socket failed");
    if(self.reconnectRequired){
        NSLog(@"reconnectRequired = YES");
        if(self.connectionHandler)
            self.connectionHandler(NO);
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(connect:) userInfo:nil repeats:NO];
        //[self performSelector:@selector(connect:) withObject:self.connectionHandler afterDelay:1.];
    }else{
        NSLog(@"reconnectRequired = NO");
        self.sessionID = nil;
        if(self.connectionHandler)
            self.connectionHandler(NO);
    }
}
- (void)tryReconnect{
    [self connect:nil];
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"socket closed");
    if(self.reconnectRequired){
        NSLog(@"reconnectRequired = YES");
        if(self.connectionHandler)
            self.connectionHandler(NO);
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(tryReconnect) userInfo:nil repeats:NO];
    }else{
        NSLog(@"reconnectRequired = NO");
        self.sessionID = nil;
        if(self.connectionHandler)
            self.connectionHandler(NO);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSDictionary *response = [self dictionaryFromJSONString:message];
    /*if(response){
        printf("\n/--------WSS-START--------\\\n%s\n\\--------WSS-END-------/\n",[response.description UTF8String]);
    }else{
        printf("\n/--------!!!!WSS-START-JSON-ERROR!!!!--------\\\n%s\n\\--------!!!!WSS-END-JSON-ERROR!!!!--------/\n",[message UTF8String]);
    }*/
    if(self.isFirstRequest){
        if([response[@"status"] intValue] == 200){
            NSLog(@"ses_id: %@",response[@"data"][@"ses_id"]);
            if(response[@"data"] && response[@"data"][@"ses_id"]){
                self.sessionID = response[@"data"][@"ses_id"];
                NSLog(@"self.sessionID = %@",self.sessionID);
                [SessionSettings defaultSettings].wssSessionID = self.sessionID;
                if(self.connectionHandler)
                    self.connectionHandler(YES);
            }
            
        }else{
           // [[Authorization manager] signOut];
            if(self.connectionHandler)
                self.connectionHandler(NO);
        }
//        self.connectionHandler = nil;
    }else{
        if(response[@"transaction_uid"]){
            if(self.responseHandlers[response[@"transaction_uid"]]){
                
                [self responseWasDetected:response];
            }
            
            [self serverEventWasDetected:response];
        }
    }
    self.isFirstRequest = NO;
}

- (NSString *)generateCommandGUID{
    return [[NSUUID UUID] UUIDString];
}
- (NSString *)jsonStringFromDictionay:(NSDictionary *)dictionary{
    /*printf("\n//---------WSS Request START--------\\\n%s\n//---------WSS Request END-------\\\n",[dictionary.description UTF8String]);*/
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    if (err) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (NSDictionary *)dictionaryFromJSONString:(NSString *)string{
    NSError * err;
    return (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
}

-(void)responseWasDetected:(NSDictionary *)response{
    LCCResponseHandler responseHandler = self.responseHandlers[response[@"transaction_uid"]];
    BOOL isSuccess = !([response[@"data"] isKindOfClass:[NSDictionary class]] && [response[@"data"] objectForKey:@"error"]);
    responseHandler(response, isSuccess);
    [self.responseHandlers removeObjectForKey:response[@"transaction_uid"]];
}
-(void)serverEventWasDetected:(NSDictionary *)serverEvent{
    NSLog(@"%@",serverEvent);
    [self.serverEventHandlers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ResponseBlockContainer * _Nonnull obj, BOOL * _Nonnull stop) {
        if(obj.filter&&obj.filter(serverEvent)){
            id response = serverEvent;
            if(obj.transform){
                response = obj.transform(serverEvent);
            }
//            NSLog(@"Have notification %@ \n\n\n\n%@",key, response);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:key object:response];
            
        }
    }];
}
-(void)addNotification:(NSString*)notification forMessagesPassedFilter:(BOOL(^)(NSDictionary *))filter andTransformResult:(id(^)(NSDictionary *))transform{
    ResponseBlockContainer *container = [ResponseBlockContainer new];
    container.filter = filter;
    container.transform = transform;
    self.serverEventHandlers[notification] = container;
}
//-(void)addNotification:(NSString*)notification forMessagesPassedFilter:(BOOL(^)(NSDictionary *))filter{
//    self.serverEventHandlers[notification] = filter;
//
//}
-(void)removeNotification:(NSString*)notification{
    [self.serverEventHandlers removeObjectForKey:notification];
}


@end
