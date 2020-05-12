//
//  MessagesContentTableVIewController.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "MessagesContentTableViewController.h"
#import "MessageTextFieldView.h"
#import "ChatCell.h"

//#import "Tour.h"
#import "Message.h"
//#import "UIImageView+AFNetworking.h"
//#import <SDWebImage/UIImageView+WebCache.h>
//#import "Authorization.h"
//#import "TabController.h"
#import "UIImageView+AFNetworking.h"

@interface MessagesContentTableViewController () <UITableViewDelegate, UITableViewDelegate, MessageTextFieldViewDelegate> {
    BOOL isKeyboardVisible;
    CGFloat _currentKeyboardHeight;
    BOOL wasFieldFirstResponder;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet MessageTextFieldView* messageTextFieldView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageTextFieldHeightConstraint;
@end

@implementation MessagesContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Testing Comments
    self.title = self.chatTitle;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.messageTextFieldView.delegate = self;
    [self.messageTextFieldView.messageSendButton addTarget:self action:@selector(sendMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView setEstimatedRowHeight:80];
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    
    //Add just top border like a shadow for the text field
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 1.0);
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.messageTextFieldView.layer addSublayer:topBorder];
    
    [self scrollToTheBottomOfTableViewWithAnimation:NO];
    
}
-(void)willLoad{
    self.messagesArray = [NSMutableArray new];
    //[self startReceivingMessages:nil];
}
-(void)willUnload{
    //[self stopReceivingMessages:nil];
}
-(void)startReceivingMessages:(LCCResponseHandler)responseHandler {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNewMessages:)
                                                 name:kNewMessagesListenerKey object:nil];
    self.messageGroupID = @"453a524d-b9f0-4073-8b74-e57938344ab5";
    [[LiveCommandClient sharedInstance]
     startReceiveNewMessagesFromGroup:self.messageGroupID
     lastMessageID:(self.messagesArray.count>0?[NSNumber numberWithInteger: [((Message *)[self.messagesArray lastObject]).messageID integerValue]]:@0)
     limit:@100
     responseHandler:^(NSDictionary *response, BOOL success) {
         if(responseHandler){
             responseHandler(response,success);
         }
         
     }];

}
-(void)stopReceivingMessages:(LCCResponseHandler)responseHandler {
    [[LiveCommandClient sharedInstance] stopReceiveNewMessagesWithResponseHandler:^(NSDictionary *response, BOOL success) {
        if(responseHandler){
            responseHandler(response,success);
        }
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    TabController* tabController = (TabController*)[self targetViewControllerForAction:@selector(showTabBar) sender:self];
//    [tabController hideTabBar];
    if([self.delegate respondsToSelector:@selector(canSendMessages)]){
        if(![self.delegate canSendMessages]){
            self.messageTextFieldHeightConstraint.constant = 0;
            self.messageTextFieldView.hidden = YES;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification object:nil];
    
//    if(self.isBid) {
//        TabController* tabController = (TabController*)[self targetViewControllerForAction:@selector(hideTabBar) sender:self];
//        [tabController hideTabBar];
//        [self.view layoutIfNeeded];
//    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startReceivingMessages:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    TabController* tabController = (TabController*)[self targetViewControllerForAction:@selector(showTabBar) sender:self];
//    [tabController showTabBar];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    if(self.isBid) {
//        TabController* tabController = (TabController*)[self targetViewControllerForAction:@selector(showTabBar) sender:self];
//        [tabController showTabBar];
//    }
    [self stopReceivingMessages:nil];
}
-(void)receiveNewMessages:(NSNotification*)notification{
    NSArray *messages = notification.object;
    if([messages isKindOfClass:[NSArray class]]){
        [self.messagesArray addObjectsFromArray:messages];
        if(self.messagesArray.count==messages.count){
            [self.tableView reloadData];
        }else{
            NSMutableArray *indexPaths = [NSMutableArray new];
            [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:[self.messagesArray count]-1-idx inSection:0]];
            }];
            
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        }
    }
    [self scrollToTheBottomOfTableViewWithAnimation:NO];
    [[LiveCommandClient sharedInstance] updateMessagesSubscriptionWithGroupID:self.messageGroupID lastMessageID:[NSNumber numberWithInteger: [((Message *)[messages lastObject]).messageID integerValue]]];
}
-(void)viewDidLayoutSubviews {
    [self.view layoutIfNeeded];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.messageTextFieldView.messageField resignFirstResponder];
}
-(void)scrollToTheBottomOfTableViewWithAnimation:(BOOL)animated {
    if (self.messagesArray != nil && [self.messagesArray count] > 0) {
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messagesArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
#pragma mark - KEYBOARD NOTIFICATIONS
- (void) keyboardWillShow: (NSNotification*) aNotification
{
    if(_messageTextFieldView.messageField.isFirstResponder) {
        wasFieldFirstResponder = YES;
        CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        if(kbSize.height == 0) {
            return;
        }
        
        if (!isKeyboardVisible) {
            
            self.msgFieldBottomConstraint.constant += kbSize.height;

            [UIView animateWithDuration: 0.1 animations:^{
                [self.view layoutIfNeeded];
                isKeyboardVisible = true;
                [self scrollToTheBottomOfTableViewWithAnimation:NO];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void) keyboardWillDisappear: (NSNotification*) aNotification
{
    if(wasFieldFirstResponder) {
        wasFieldFirstResponder = NO;
        if(isKeyboardVisible) {
            CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            self.msgFieldBottomConstraint.constant -= kbSize.height;
            [UIView animateWithDuration: 0.1 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        }
        isKeyboardVisible = false;
    }
}
#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messagesArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message* chatMessage = self.messagesArray[indexPath.row];
    
    NSString* identifier;
//    if([[Authorization manager].userID isEqualToString:chatMessage.user.userID]){
//        identifier = @"UserChatCell";
//    }
//    else {
//        identifier = @"ChatCell";
//    }
    
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if ([self.messagesArray count] > 0) {
        
        //User Message
        cell.bubbleTextView.text = chatMessage.messageText;
        cell.bubbleTextView.textContainer.lineFragmentPadding = 12;
        cell.sentTime.text = [self getChatBubbleSentTime:chatMessage.createDate];

        //User Image
        if ([identifier isEqualToString:@"ChatCell"]) {
            NSString* url = [NSString stringWithFormat:@"%@?w=%i&h=%i",chatMessage.user.imageURL.absoluteString,(int)cell.userImage.frame.size.width*(int)[UIScreen mainScreen].scale,(int)cell.userImage.frame.size.height*(int)[UIScreen mainScreen].scale];
//            [cell.userImage setImageWithURL:[NSURL URLWithString:url]];
            [cell.userImage setImageWithURL:[NSURL URLWithString:url]];
        }
        cell.authorName.text = [NSString stringWithFormat:@"%@ %@", chatMessage.user.firstName,chatMessage.user.lastName];
        
        if([chatMessage.messageImageUrl isKindOfClass:[NSString class]]) {
            [cell.image setImageWithURL:[NSURL URLWithString:chatMessage.messageImageUrl]];
            cell.imageHeightConstraint.constant = 128;
            [self.view layoutIfNeeded];
        }
        else {
            cell.imageHeightConstraint.constant = 0;
            [self.view layoutIfNeeded];
        }
    }
    return cell;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString*)getChatBubbleSentTime:(NSDate*)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    BOOL isDateToday = [calendar isDateInToday:date];
    BOOL isDateYesterday = [calendar isDateInYesterday:date];
    
    if(isDateToday) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:NSDateFormatterNoStyle];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString* formattedString = [formatter stringFromDate:date];
        
        return formattedString;
    }
    else if(isDateYesterday) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:NSDateFormatterNoStyle];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString* formattedString = [formatter stringFromDate:date];
        
        return [NSString stringWithFormat:@"Yesterday %@",formattedString];

    }
    else {
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:NSDateFormatterNoStyle];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString* formattedString = [formatter stringFromDate:date];
        
        return formattedString;
    }
}
#pragma mark - ACTIONS
-(void)sendMessageAction:(id)sender {
    if([self.messageTextFieldView.messageField.text isEqualToString:@""]){
        return;
    }
    [[LiveCommandClient sharedInstance] sendTextMessage:self.messageTextFieldView.messageField.text
                                           toUserWithID:self.toUserID inMessageGroupID:self.messageGroupID responseHandler:^(NSDictionary *dictionary, BOOL success) {
                                               NSLog(@"Message was sent");
                                           }];
    
    [self.messageTextFieldView.messageField setText:@""];
}
-(void)didClickReturnKey {
    [self sendMessageAction:nil];
}
@end
