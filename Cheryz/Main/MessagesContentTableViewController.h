//
//  MessagesContentTableVIewController.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourTabViewControllerProtocol.h"
#import "LiveCommandClient+TourCommands.h"
//@class Tour;
//@class Bid;
@protocol MessagesContentTableViewControllerDelegate <NSObject>

-(BOOL)canSendMessages;

@end

@interface MessagesContentTableViewController : UIViewController<TourTabViewControllerProtocol>
//@property (nonatomic, strong) Tour *tour;
//@property (nonatomic, strong) Bid *bid;
@property (nonatomic, strong) NSString *messageGroupID;
@property (nonatomic, strong) NSString *toUserID;
@property (nonatomic, strong) NSString *chatTitle;
@property (nonatomic, weak) id <MessagesContentTableViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *msgFieldBottomConstraint;
@property (nonatomic, strong) NSMutableArray* messagesArray;
@property (nonatomic) BOOL isNewMessagesReceived;
//@property (nonatomic) BOOL isBid;
-(void)receiveNewMessages:(NSArray *)messages;
-(void)startReceivingMessages:(LCCResponseHandler)responseHandler;
-(void)stopReceivingMessages:(LCCResponseHandler)responseHandler;
@end
