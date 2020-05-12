//
//  BuyerTourViewController.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "TourViewController.h"
#import "UIButton+MiddleAligning.h"

typedef enum : NSUInteger {
    WaitingForShopperBuyersTourState = 0,
    DiscoveryBuyersTourState,
    ItemBuyersTourState
} BuyersTourState;

@class Product, InfoRequest;

@protocol BuyerTourViewControllerReactDelegate <NSObject>
-(void)onShowPDP;
-(void)onHidePDP;
-(void)onProductPopupShow;
@end

@protocol BuyerTourViewControllerDelegate <NSObject>

-(void)showRequestPopupViewForItem:(Product *)item;
-(void)showInfoPopupViewWithInfoRequest:(InfoRequest *)infoRequest;
-(void)hideInfoPopupViewWithInfoRequest:(InfoRequest *)infoRequest;
-(void)didClickFacebookButton:(NSString*)link;
-(void)showAddToWishlistController:(Product*)product;
-(void)didSelectItem:(Product*)item;
@end

extern NSString * const kTotalPriceWasChangedListenerKey;

@interface BuyerTourViewController : TourViewController
@property (nonatomic, strong) IBOutlet UIView *contentModeView;
@property (nonatomic, strong) IBOutlet UIImageView *videoView;
@property (nonatomic, strong) IBOutlet UIView *itemModeControlsView;
@property (nonatomic, strong) IBOutlet UIView *discoveryModeView;
@property (nonatomic) BOOL shouldRestartCoordinator;

@property (nonatomic, weak) id<BuyerTourViewControllerDelegate> delegate;
@property (nonatomic, weak) id<BuyerTourViewControllerReactDelegate> reactDelegate;
@property (nonatomic) BuyersTourState tourState;

@property (nonatomic, strong) IBOutlet UIButton* askButton;
@property (nonatomic, strong) IBOutlet UIButton* requestButton;
@property (nonatomic, strong) IBOutlet UIButton* buyButton;
@property (nonatomic, strong) IBOutlet UIButton* fullscreenButton;
@property (nonatomic, strong) IBOutlet UIButton* facebookButton;
@property (nonatomic, strong) IBOutlet UILabel* modeLabel;
@property (nonatomic, strong) IBOutlet UIImageView* tourImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoViewProportionalHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoViewFullscreenHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* videoViewNewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *typeViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *askViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftPanelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftPanelCenterYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightPanelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightPanelCenterYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *currentItemTopConstraint;

@property (nonatomic, strong) IBOutlet UIView* leftPanelView;
@property (nonatomic, strong) IBOutlet UIView* rightPanelView;
@property (nonatomic, strong) IBOutlet UILabel* totalPriceLabel;
@property (nonatomic, strong) UIView* pdpView;
-(IBAction)fullscreenActionClicked:(id)sender;
-(IBAction)buyCurrentItemAction:(id)sender;
-(void)startPlaying;
-(void)stopPlaying;
-(void)onShowPDP;
-(void)onHidePDP;
@end
