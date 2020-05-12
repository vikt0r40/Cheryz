//
//  BuyerTourViewController.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "BuyerTourViewController.h"
#import "BuyerTourCoordinator.h"
#import "CHVideoPlayer.h"
#import "LiveCommandClient+TourCommands.h"
#import "Tour.h"
#import "SipSettings.h"
#import "LiveCommandClient+BuyerBroadcasting.h"
#import "Product.h"
#import "AlertView.h"
#import "UIColor+Cheryz.h"
//#import <VCPreviewView.h>
#import "BuyerAPILiveCommands.h"
#import "InfoRequest.h"
#import "GetTourByIDAPIClient.h"
#import <UIImageView+AFNetworking.h>
#import "Device.h"
#import "GetTourByIDAPIClient.h"
#import "SipManager.h"

NSString * const kTotalPriceWasChangedListenerKey = @"TotalPriceWasChangedListenerKey";

@interface BuyerTourViewController ()<SipManagerDelegte>
@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) CHVideoPlayer *videoPlayer;
@property (nonatomic, strong) Product *item;
@property (nonatomic, strong) NSMutableArray *itemList;
@property (nonatomic, strong) IBOutlet UILabel *askLabel;
@property (nonatomic, strong) IBOutlet UIImageView *askImageView;
@property (nonatomic) BOOL isAskButtonActive;
@property (nonatomic, strong) CALayer *fingerprintLayer;
@property (strong, nonatomic) IBOutlet UILabel *waitingForShopperLabel;
@property (strong, nonatomic) IBOutlet UIButton *muteButton;
@property (strong, nonatomic) IBOutlet UIButton *unmuteButton;
@property (nonatomic, strong) IBOutlet UIImageView *currentItemImageView;
@property (nonatomic, strong) UIImage *currentItemImage;
@property (nonatomic, strong) IBOutlet UILabel *currentItemPriceLabel;
@property (nonatomic, strong) IBOutlet UIButton* currentBuyButton;
@property (nonatomic) BOOL isMute;
@property (nonatomic) BOOL isFullscreen;
@end

@implementation BuyerTourViewController

-(void)onShowPDP {
    if([self.reactDelegate respondsToSelector:@selector(onShowPDP)]) {
        [self.reactDelegate onShowPDP];
    }
}
-(void)onHidePDP {
    if([self.reactDelegate respondsToSelector:@selector(onHidePDP)]) {
        [self.reactDelegate onHidePDP];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFullscreen = NO;
    // Do any additional setup after loading the view.
    self.isMute = YES;
    self.itemList = [NSMutableArray new];
    self.tourState = WaitingForShopperBuyersTourState;
    [self useWaitingForShopperInterface];
    self.fingerprintLayer = [CALayer layer];
    self.fingerprintLayer.cornerRadius = 15;
    self.fingerprintLayer.frame = CGRectMake(0, 0, 30, 30);
    self.fingerprintLayer.backgroundColor = [UIColor cheryzRed].CGColor;
    self.fingerprintLayer.opacity = 0.5;
    self.fingerprintLayer.hidden = YES;
    [self.askImageView.layer addSublayer:self.fingerprintLayer];
    self.shouldRestartCoordinator = NO;
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.totalPriceLabel.hidden = YES;
    self.currentBuyButton.hidden = YES;
    [self loadTourWithID:self.tour.guid];

    if(self.tour.status == TourStatusDefault) {
        NSURL* link = [self.tour.imagesURLArray objectAtIndex:0];
        [self.tourImage setImageWithURL:link];
    }
}
-(void)viewDidLayoutSubviews{
//    [self.muteButton middleAlignButtonWithSpacing:2];
//    [self.unmuteButton middleAlignButtonWithSpacing:2];
//    //[self.askButton middleAlignButtonWithSpacing:2];
//    [self.buyButton middleAlignButtonWithSpacing:2];
//    [self.facebookButton middleAlignButtonWithSpacing:2];
//    [self.fullscreenButton middleAlignButtonWithSpacing:2];
}
-(void)setupCoordinator{
    self.tourCoordinator = [[BuyerTourCoordinator alloc] initWithTourViewController:self];
    
    // Start coordinator. This makes our tabs life.
    ((BuyerTourCoordinator*)self.tourCoordinator).pdpView = self.pdpView;
    [self.tourCoordinator start];
    self.delegate = (BuyerTourCoordinator *) self.tourCoordinator;
    
}
- (void)setTourState:(BuyersTourState )tourState{
    
    if(_tourState==tourState)
        return;
    
    _tourState = tourState;
    
    switch (_tourState) {
        case WaitingForShopperBuyersTourState:{
            [self useWaitingForShopperInterface];
        }break;
        
        case DiscoveryBuyersTourState:{
            [self useDiscoveryInterface];
        }break;
            
        case ItemBuyersTourState:{
            [self useItemInterface];
        }break;
    }
}

- (void)useWaitingForShopperInterface{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waitingForShopperLabel.hidden = NO;
        self.itemModeControlsView.hidden = YES;
        self.discoveryModeView.hidden = YES;
        self.isAskButtonActive = NO;
        self.modeLabel.text = @"";
        [self clearCurrentItemDetails];
    });
}

- (void)useDiscoveryInterface{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waitingForShopperLabel.hidden = YES;
        self.itemModeControlsView.hidden = YES;
        self.discoveryModeView.hidden = NO;
        self.isAskButtonActive = NO;
        self.modeLabel.text = NSLocalizedString(@"Discovery mode", nil);
        [self clearCurrentItemDetails];
    });
}

- (void)useItemInterface{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.waitingForShopperLabel.hidden = YES;
        self.itemModeControlsView.hidden = NO;
        self.discoveryModeView.hidden = YES;
        self.isAskButtonActive = NO;
        self.modeLabel.text = NSLocalizedString(@"Product mode", nil);
        Product *product = self.item;
        [self.currentItemImageView setImageWithURL:[NSURL URLWithString:product.productImageUrl]];
        self.currentItemImageView.layer.borderWidth = 3.;
        self.currentItemImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.currentItemImageView.backgroundColor = [UIColor whiteColor];
        if(self.isFullscreen) {
            self.currentBuyButton.hidden = NO;
        }
        else {
            self.currentBuyButton.hidden = YES;
        }
        if(product.price){
            self.currentItemPriceLabel.text = product.price.formattedString;
            self.currentItemPriceLabel.backgroundColor = [UIColor whiteColor];
        }
    });
}
- (void)clearCurrentItemDetails{
    self.currentItemImageView.image = nil;
    self.currentItemImageView.backgroundColor = [UIColor clearColor];
    self.currentItemImageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.currentItemImageView.layer.borderWidth = 0;
    self.currentItemPriceLabel.backgroundColor = [UIColor clearColor];
    self.currentItemPriceLabel.text = @"";
    self.currentBuyButton.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.shouldRestartCoordinator) {
        [self.navigationController setNavigationBarHidden:YES];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(broadcastingWasStarted:)
                                                 name:kStartTourBroadcastingListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(broadcastingWasStoped:)
                                                 name:kStopTourBroadcastingListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tourWasFinished:)
                                                 name:kFinishTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kItemCreatedInTourListenerKey:)
                                                 name:kItemCreatedInTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(discoveryStartedInTourNotification:)
                                                 name:kDiscoveryStartedInTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemListCreatedInTourNotification:)
                                                 name:kItemListCreatedInTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tourCoordinator
                                             selector:@selector(infoResponseInTourNotification:)
                                                 name:kInfoResponseInTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wssDidConnect)
                                                 name:kWebSocketConnectionSuccesfull
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(priceUpdatedNotification:) name:kTourCurrentProductPriceIsUpdatedListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalPriceNotification:) name:kTotalPriceWasChangedListenerKey object:nil];
    
    [super viewWillAppear:animated];
    
    if(self.shouldRestartCoordinator) {
        [(BuyerTourCoordinator*)self.tourCoordinator restart];
        self.shouldRestartCoordinator = NO;
    }
    
    [[LiveCommandClient sharedInstance] connect:nil];
    
   
}

-(void)wssDidConnect {
    __weak BuyerTourViewController *weakSelf = self;
    [[LiveCommandClient sharedInstance] getStreamingConfigForTourID:self.tour.guid responseHandler:^(NSDictionary *settings, BOOL success) {
        weakSelf.settings = settings;
        
        
        if(settings[@"data"]){
            if(settings[@"data"][@"tour_status"]) {
                weakSelf.tour.status = [settings[@"data"][@"tour_status"] intValue];
            }
            else if(settings[@"data"][@"status"]) {
                weakSelf.tour.status = [settings[@"data"][@"status"] intValue];
            }
            else {
                return ;
            }
            
            switch (weakSelf.tour.status) {
                case TourStatusDefault:
                case TourStatusBroadcast:{
                    weakSelf.tourState = WaitingForShopperBuyersTourState;
                    
                    [weakSelf setupPlayer];
                    
                    break;
                }
                    
                case TourStatusLive:{
                    if(self.item){
                        self.tourState = ItemBuyersTourState;
                    }else{
                        self.tourState = DiscoveryBuyersTourState;
                    }
                    [weakSelf startPlaying];
                }break;
                    
                case TourStatusFinish: {
                    self.tourState = WaitingForShopperBuyersTourState;
                    [(BuyerTourCoordinator*)self.tourCoordinator tourFinished:nil];
                }
                    break;
                case TourStatusFinishInProgress: {
                    self.tourState = WaitingForShopperBuyersTourState;
                    [(BuyerTourCoordinator*)self.tourCoordinator tourFinished:nil];
                }
                    break;
                default:
                    break;
            }
        }
    }];
}
#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification*)aNotification {
   
    NSDictionary *info  = aNotification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    if(self.contentModeView.frame.size.height - keyboardFrame.size.height < 50) {
        self.videoViewNewConstraint.priority = 999;
        self.videoViewProportionalHeight.active = NO;
        self.videoViewNewConstraint.active = YES;
        [UIView animateWithDuration: 0.1 animations:^{
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
        }];
    }
}
-(void)keyboardWillHide:(NSNotification*)aNotification {
    
    //if([Device isIphone5]) {
        self.videoViewNewConstraint.priority = 600;
        self.videoViewProportionalHeight.active = YES;
        self.videoViewNewConstraint.active = NO;
        
        [UIView animateWithDuration: 0.1 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    //}
}

-(void)setupPlayer{
    self.tourImage.hidden = YES;
    if(!self.videoPlayer){
        self.videoPlayer = [[CHVideoPlayer alloc] initWithURL:[NSURL URLWithString:self.settings[@"data"][@"wss_h264_video_url"]]];
        self.videoPlayer.view = self.videoView;
    }
    [SipManager sharedInstance].settingsDictionary = self.settings[@"data"];
    [SipManager sharedInstance].delegate = self;
    [SipManager sharedInstance].targetState = SipStateReadyForCall;
    
//    if(!self.sipClient){
//        self.sipClient = [[SipClient alloc] initWithSettings:[SipSettings settingsFromDictionary:self.settings[@"data"]] delegate:self];
//        self.sipClient.mute = self.isMute;
//    }
}
-(void)broadcastingWasStarted:(NSNotification *)notification{
    self.tourImage.hidden = YES;
    NSString *tourID = notification.object;
    if([self.tour.guid isEqualToString:tourID]){
        NSLog(@"Broadcasting was started");
        self.tourState = DiscoveryBuyersTourState;
        [self startPlaying];
    }
}

-(void)broadcastingWasStoped:(NSNotification *)notification{
    NSString *tourID = notification.object;
    if([self.tour.guid isEqualToString:tourID]){
        NSLog(@"Broadcast was stoped");
        self.tourState = WaitingForShopperBuyersTourState;
        [self stopPlaying];
        [((BuyerTourCoordinator*)self.tourCoordinator) broadcastingWasStopped];
    }
}

-(void)tourWasFinished:(NSNotification *)notification{
    NSString *tourID = notification.object;
    if([self.tour.guid isEqualToString:tourID]){
        self.tourState = WaitingForShopperBuyersTourState;
        NSLog(@"Broadcast was finished");
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self stopPlaying];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.tourCoordinator];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
-(IBAction)backAction:(id)sender{
    [self stopPlaying];
    [super backAction:sender];
}
-(void)startPlaying{
    NSLog(@"start play");
    [self setupPlayer];
    [self.videoPlayer play];
    [SipManager sharedInstance].targetState = SipStateOnCall;
//    if(!self.sipClient.isOnCall){
//        [self.sipClient start];
//    }
    
}

-(void)stopPlaying{
    NSLog(@"stop play");
    [self.videoPlayer stop];
    [SipManager sharedInstance].targetState = SipStateReadyForCall;
//    if(self.sipClient.isOnCall){
//        [self.sipClient stop];
//    }
}
-(void)sipClientError:(NSError *)error {
    NSLog(@"Sip Call Error %@", error);
//    [self.sipClient stop];
}
-(void)sipClientWasEnded{
    NSLog(@"Sip was ended");
}
-(void)sipClientWasStarted{
    NSLog(@"Sip was started");
}
-(void)sipStateIsChangedFrom:(SipState)oldState
                          to: (SipState)newState{
    
}

-(void)kItemCreatedInTourListenerKey:(NSNotification*)notification {
    Product* product = notification.object;
    NSMutableDictionary* params = [NSMutableDictionary new];
    params[@"product_id"] = product.storeProductID;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveProduct" object:nil userInfo:[params copy]];
}
-(void)itemListCreatedInTourNotification:(NSNotification *)notification{
    self.itemList = [notification.object mutableCopy];
    __block BuyersTourState tourState = DiscoveryBuyersTourState;
    [self.itemList enumerateObjectsUsingBlock:^(Product*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.isCurrent){
            *stop = YES;
            self.item = obj;
            NSMutableDictionary* params = [NSMutableDictionary new];
            params[@"product_id"] = self.item.storeProductID;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveProduct" object:nil userInfo:[params copy]];
            tourState = ItemBuyersTourState;
        }
    }];
    self.tourState = tourState;
}
-(void)itemCreatedInTourNotification:(NSNotification *)notification{
    self.item = notification.object;
    [self.itemList insertObject:self.item atIndex:0];
    self.tourState = ItemBuyersTourState;
    NSLog(@"Created item %@", self.item);
    
}
-(void)discoveryStartedInTourNotification:(NSNotification *)notification{
    self.item = nil;
    if(self.tourState == ItemBuyersTourState){
        self.tourState = DiscoveryBuyersTourState;
    }
    NSLog(@"Discovery mode");
}
-(IBAction)buyItemButtonClicked:(id)sender{
    self.contentModeView.userInteractionEnabled = NO;
    if(self.item){
        if([self.delegate respondsToSelector:@selector(showRequestPopupViewForItem:)]){
            self.contentModeView.userInteractionEnabled = YES;
            [self.delegate showRequestPopupViewForItem:self.item];
        }
        NSLog(@"Buy request was sent");
        
    }else{
    }
}
-(IBAction)fullscreenActionClicked:(id)sender {
    if(!self.isFullscreen) {
        [self showFullScreen];
    }
    else {
        [self showNormal];
    }
    [UIView animateWithDuration: 0.1 animations:^{
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
    }];

}
-(void)showFullScreen {
    self.videoViewFullscreenHeight.priority = 999;
    self.typeViewHeightConstraint.constant = 1;
    self.typeView.hidden = YES;
    self.tabContentView.hidden = YES;
    self.askViewTopConstraint.priority = 900;
    self.isFullscreen = YES;
    self.buyButton.hidden = YES;
    if(self.tourState == ItemBuyersTourState) {
        self.currentBuyButton.hidden = NO;
    }
    self.totalPriceLabel.hidden = NO;
    [self.view endEditing:YES];
    //[self.fullscreenButton setImage:[UIImage imageNamed:@"offscreen"] forState:UIControlStateNormal];
    //[self.fullscreenButton middleAlignButtonWithSpacing:2];
    self.leftPanelTopConstraint.active = NO;
    self.leftPanelCenterYConstraint.active = YES;
    self.rightPanelTopConstraint.active = NO;
    self.rightPanelCenterYConstraint.active = YES;
    self.currentItemTopConstraint.constant = 3;
    if([Device isIphone5]) {
        self.rightPanelCenterYConstraint.constant = 30;
    }
}
-(void)showNormal {
    self.videoViewFullscreenHeight.priority = 700;
    self.typeViewHeightConstraint.constant = 49;
    self.askViewTopConstraint.priority = 700;
    self.typeView.hidden = NO;
    self.isFullscreen = NO;
    self.tabContentView.hidden = NO;
    self.buyButton.hidden = NO;
    if(self.tourState == ItemBuyersTourState) {
        self.currentBuyButton.hidden = YES;
    }
    self.totalPriceLabel.hidden = YES;
   // [self.fullscreenButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    //[self.fullscreenButton middleAlignButtonWithSpacing:2];
    self.leftPanelTopConstraint.active = YES;
    self.leftPanelCenterYConstraint.active = NO;
    self.rightPanelTopConstraint.active = YES;
    self.rightPanelCenterYConstraint.active = NO;
    self.currentItemTopConstraint.constant = 45;
    if([Device isIphone5]) {
        self.rightPanelCenterYConstraint.constant = 0;
    }
}
-(IBAction)askButtonClicked:(id)sender{
    self.isAskButtonActive = !self.isAskButtonActive;
}
-(void)setIsAskButtonActive:(BOOL)isAskButtonActive{
    
    _isAskButtonActive = isAskButtonActive;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle* bundle = [NSBundle bundleForClass:[self class]];
        if(_isAskButtonActive){
            [self.requestButton setBackgroundImage:[UIImage imageNamed:@"requestHighlighted.png" inBundle:bundle withConfiguration:nil]  forState:UIControlStateNormal];
            self.askImageView.hidden = NO;
        }else{
            [self.requestButton setBackgroundImage:[UIImage imageNamed:@"request.png" inBundle:bundle withConfiguration:nil] forState:UIControlStateNormal];
            self.askImageView.hidden = YES;
            self.askImageView.image = nil;
        }
        //[self.askButton middleAlignButtonWithSpacing:2];
    });
}
-(IBAction)tapOnAskImageView:(id)sender{
    self.contentModeView.userInteractionEnabled = NO;
    
    CGPoint touchPoint = [sender locationInView: self.askImageView];
    //UIImage *image = ((VCPreviewView *) self.videoView).captureImage;
    UIImage *image = self.videoView.image;
    if(!image){
        [AlertView showAlertViewWithTitle:@"Error" message:@"Please wait for video broadcasting." controller:self];
        return;
    }
    float k = image.size.width/self.askImageView.bounds.size.width;
    CGPoint scaledPoint = CGPointMake(round(touchPoint.x*k), round(touchPoint.y*k));
    
    [self askWithImage:image andPoint:scaledPoint];
}
-(void)askWithImage:(UIImage*)image andPoint: (CGPoint)point{
    image = [self imageByDrawingCircleOnImage:image atPoint:point];
    [BuyerAPILiveCommands askWithImageData:UIImageJPEGRepresentation(image, 0.9) tourID:self.tour.guid point:point storeProductID:nil success:^(NSDictionary *response) {
            NSLog(@"asdked");
            self.contentModeView.userInteractionEnabled = YES;
            
        } failure:^(NSError *error) {
            NSLog(@"failed");
    //        if([self.delegate respondsToSelector:@selector(hideInfoPopupViewWithInfoRequest:)]){
    //            [self.delegate hideInfoPopupViewWithInfoRequest:infoRequest];
    //        }
            [AlertView showAlertViewWithTitle:@"Error" message:@"Request was not send" controller:self];
            self.contentModeView.userInteractionEnabled = YES;
        }];
}
- (UIImage *)imageByDrawingCircleOnImage:(UIImage *)image atPoint:(CGPoint)point
{
    
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);
 
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
 
    // get the context for CoreGraphics
    CGContextRef ctx = UIGraphicsGetCurrentContext();
 
    // set stroking color and draw circle
    
    [[UIColor cheryzRed] setFill];
 
    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(point.x-image.size.width/20, point.y-image.size.width/20,
                image.size.width/10,
                image.size.width/10);
    //circleRect = CGRectInset(circleRect, 5, 5);
 
    // draw circle
    CGContextFillEllipseInRect(ctx, circleRect);
 
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
 
    // free the context
    UIGraphicsEndImageContext();
 
    return retImage;
}
-(IBAction)didClickFacebookButton:(id)sender {
    if([self.delegate respondsToSelector:@selector(didClickFacebookButton:)]) {
        NSString* link = [NSString stringWithFormat:@"https://cheryz.com/tour/%@",self.tour.guid];
        [self.delegate didClickFacebookButton:link];
    }
}

-(IBAction)muteButtonClicked:(id)sender{
    self.isMute = YES;
}

-(IBAction)unmuteButtonClicked:(id)sender{
    self.isMute = NO;
}
-(void)setIsMute:(BOOL)isMute{
    _isMute = isMute;
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        self.sipClient.mute = self.isMute;
        
        self.muteButton.hidden = _isMute;
        self.unmuteButton.hidden = !_isMute;
        
    });
    [SipManager sharedInstance].mute = isMute;
}
- (void)priceUpdatedNotification:(NSNotification *)notification{
    NSDictionary *updateDict = notification.object;
    if([updateDict[@"product_id"] isKindOfClass:[NSString class]]){
        Price *price = [Price priceFromDictionary:updateDict[@"price"]];
        if(price){
//            self.currentItemPriceLabel.text = [NSString stringWithFormat:@"USD %.02f",price];
            self.currentItemPriceLabel.text = price.formattedString;
            self.currentItemPriceLabel.backgroundColor = [UIColor whiteColor];
        }
    }
}
-(IBAction)buyCurrentItemAction:(id)sender {
    self.contentModeView.userInteractionEnabled = NO;
    if(self.item){
        if([self.delegate respondsToSelector:@selector(showRequestPopupViewForItem:)]){
            self.contentModeView.userInteractionEnabled = YES;
            [self.delegate showRequestPopupViewForItem:self.item];
        }
        NSLog(@"Buy request was sent");
        
    }else{
    }

}
-(void)updateTotalPriceNotification:(NSNotification*)notification {
    NSString* priceText = notification.object;
    self.totalPriceLabel.text = priceText;
}
-(void)loadTourWithID:(NSString*)tourID {
    [GetTourByIDAPIClient getTourWithID:tourID success:^(NSDictionary *response) {
        NSLog(@"Tour Loaded");
    } failure:^(NSError *error) {
        
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
