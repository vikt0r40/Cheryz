//
//  BuyerTourCoordinator.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "BuyerTourCoordinator.h"
#import "AboutContentTableViewController.h"
#import "MessagesContentTableViewController.h"
#import "BuyerTourPopupsViewController.h"
#import "LiveCommandClient+TourCommands.h"
#import "LiveCommandClient+BuyerBroadcasting.h"
#import "BuyRequest.h"
#import "AlertView.h"
#import "InfoRequest.h"
#import "ItemsContentCollectionViewController.h"
#import "ShareFacebook.h"
#import "BuyerFinishedTourViewController.h"
#import "PDPViewController.h"
#import "RequestPrivateTourViewController.h"

@interface BuyerTourCoordinator ()<MessagesContentTableViewControllerDelegate>

@property (nonatomic, strong) BuyerTourPopupsViewController* popupViewController;
@property (nonatomic, strong) InfoRequest* currentInfoRequest;
@property (nonatomic) BOOL isPDPPageVisible;
@end

@implementation BuyerTourCoordinator

-(void)start{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoRequestStarted:) name:kInfoStartInTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tourFinished:) name:kFinishTourListenerKey object:nil];
    
    [super start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBuyResponse:) name:kItemBuyResponseListenerKey object:nil];
}
- (void)receiveBuyResponse: (NSNotification *)notification{
    NSDictionary *dict = notification.object;
    if([dict[@"data"][@"status"] intValue]==1){
        // user buy product
        self.tourViewController.typeView.selectedIndex=2;
        [self typeViewDidPressedAtIndex:2];
    }
}
-(void)stop{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super stop];
}
-(void)restart {
    [self start];
    [self.tabsArray enumerateObjectsUsingBlock:^(id <TourTabViewControllerProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(willLoad)]){
            [obj willLoad];
        }
    }];
}
-(NSArray *)tabs{
    return @[
             @{
                 @"Title" : NSLocalizedString(@"Product Page", nil),
                 @"ClassName" : NSStringFromClass([PDPViewController class]),
                 @"StoryboardName" : @"MainStoryboard",
                 @"ViewControllerCallback" : ^(PDPViewController *viewController){
                     viewController.customView = self.pdpView;
                  }
                 },
             @{
                 @"Title" : NSLocalizedString(@"Chat", nil),
                 @"ClassName" : NSStringFromClass([MessagesContentTableViewController class]),
                 @"StoryboardName" : @"TourTabsStoryboard",
                 @"ViewControllerCallback" : ^(MessagesContentTableViewController *viewController){
                     viewController.messageGroupID = self.tourViewController.tour.messageGroupID;
                     viewController.toUserID = self.tourViewController.tour.ownerID;
                 }
                 },
                @{
                @"Title" : NSLocalizedString(@"Request Private", nil),
                @"ClassName" : NSStringFromClass([RequestPrivateTourViewController class]),
                @"StoryboardName" : @"MainStoryboard"
                }];
    
}
-(BOOL)canSendMessages{
    return YES;
}
-(NSInteger)defaultTabIndex{
    return 1;
}
-(void)showRequestPopupViewForItem:(Product *)item{
    BuyerTourViewController *vc = (BuyerTourViewController *)self.tourViewController;
    if(vc.tourState==WaitingForShopperBuyersTourState){
        [AlertView showAlertViewWithTitle:@"Error" message:@"Shopper is offline." controller:vc];
        return;
    }
    [self showPopupView];
    
    BuyRequest *buyRequest = [BuyRequest new];
    buyRequest.comment = @"";
    buyRequest.quantity = 1;
    buyRequest.imageURL = item.productImageUrl;
    buyRequest.productID = item.productID;
    buyRequest.tourID = item.productTourID;
    
    TourPop *tourPop = [TourPop new];
    tourPop.type = BuyerBuyRequestPopupType;
    tourPop.model = buyRequest;
    
    [self.popupViewController addTourPopup:tourPop];
    
}
-(void)infoRequestStarted:(NSNotification *)notification{
    [self showInfoPopupViewWithInfoRequest:notification.object];
}
-(void)showInfoPopupViewWithInfoRequest:(InfoRequest *)infoRequest{
    
    NSUInteger index = [self.popupViewController.popupsArray indexOfObjectPassingTest:^BOOL(TourPop * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.type==BuyerItemInfoRequestPopupType;
    }];
    if(index==NSNotFound || !self.popupViewController.popupsArray){
        
        [self showPopupView];
        
        TourPop *tourPop = [TourPop new];
        tourPop.type = BuyerItemInfoRequestPopupType;
        tourPop.model = infoRequest;
        [self.popupViewController addTourPopup:tourPop];
    }
}

-(void)haveRequestsToDisplay{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tourViewController.mContentView.hidden = NO;
    });
}
-(void)haveNoRequestsToDisplay{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tourViewController.mContentView.hidden = YES;
    });
}
-(BuyerTourPopupsViewController *)showPopupView {
    self.tourViewController.mContentView.hidden = NO;
    if(self.popupViewController)
        return self.popupViewController;
    
    self.popupViewController = (BuyerTourPopupsViewController *) [self loadRequestContentViewController:NSStringFromClass([BuyerTourPopupsViewController class]) fromStoryboard:@"BuyersTourStoryboard"];
    return self.popupViewController;
}
-(UIViewController *)loadRequestContentViewController:(NSString*)className fromStoryboard:(NSString *)storyboard{
    
    BuyerTourPopupsViewController *newContentViewController = (BuyerTourPopupsViewController*)[self.router viewControllerWithClass:NSClassFromString(className) fromStoryboardWithName:storyboard];
    
    newContentViewController.delegate = self;
    [self.tourViewController addChildViewController:newContentViewController];
    newContentViewController.view.frame = self.tourViewController.mContentView.bounds;
    [self.tourViewController.mContentView addSubview:newContentViewController.view];
    [newContentViewController didMoveToParentViewController:self.tourViewController];
    
    return newContentViewController;
}
-(void)broadcastingWasStopped {
    
        [self hideInfoPopup];
    
}
#pragma mark - Delegates
-(void)sendBuyRequest:(BuyRequest *)request {
    //Process the request
    [[LiveCommandClient sharedInstance] sendBuyRequestWithTourID:self.tourViewController.tour.guid
                                                          itemID:request.productID
                                                        quantity:@(request.quantity) comment:request.comment responseHandler:^(NSDictionary *response, BOOL success) {
                                                            if(!success){
                                                                [AlertView showAlertViewWithTitle:@"Error" message:response[@"data"][@"error"] controller:self.tourViewController];
                                                            }
                                                          }];
}

-(void)infoResponseInTourNotification:(NSNotification *)notification{
    self.currentInfoRequest = notification.object;
    //[self.popupViewController removeInfoPopup];
}
-(void)hideInfoPopup{
    [self.popupViewController removeInfoPopup];
}
-(void)didClickFacebookButton:(NSString *)link {
    [ShareFacebook shareTourToFacebook:self.tourViewController link:link];
}
-(void)didSelectCheckWithImage:(UIImage *)image{
    [self showPopupView];
    
    TourPop *tourPop = [TourPop new];
    tourPop.type = CheckViewerPopupType;
    tourPop.model = image;
    
    [self.popupViewController addTourPopup:tourPop];

}
-(void)tourFinished:(NSNotification *)notification{
    [self.router viewControllerWithClass:[BuyerFinishedTourViewController class] fromStoryboardWithName:@"BuyersTourStoryboard" controllerHandler:^(id viewController) {
        
        BuyerFinishedTourViewController *vc = viewController;
        vc.tour = self.tourViewController.tour;
        
        NSMutableArray *array = [self.router.navigationController.viewControllers mutableCopy];
        [array insertObject:vc atIndex:array.count-1];
        self.router.navigationController.viewControllers = array;
        [self.router.navigationController popViewControllerAnimated:YES];
    }];
}
-(void)showAddToWishlistController:(Product *)product {
    [((BuyerTourViewController*)self.tourViewController) stopPlaying];
    ((BuyerTourViewController*)self.tourViewController).shouldRestartCoordinator = YES;
    
//    [self.router viewControllerWithClass:[AddToWishlistTableViewController class] fromStoryboardWithName:@"WishlistStoryboard" controllerHandler:^(id viewController) {
//        
//        AddToWishlistTableViewController* controller = viewController;
//        controller.product = product;
//        [self.router.navigationController pushViewController:controller animated:YES];
//    }];
}
-(void)typeViewDidPressedAtIndex:(int)index{
    
    [super typeViewDidPressedAtIndex:index];
    
    if(index == 0) {
        self.isPDPPageVisible = true;
        [((BuyerTourViewController*)self.tourViewController)  onShowPDP];
        
    } else {
        if(self.isPDPPageVisible == true) {
            self.isPDPPageVisible = false;
            [((BuyerTourViewController*)self.tourViewController)  onHidePDP];
        }
    }
}
#pragma mark - Did Select Product
-(void)didSelectItem:(Product *)item {
    [((BuyerTourViewController*)self.tourViewController) stopPlaying];
    ((BuyerTourViewController*)self.tourViewController).shouldRestartCoordinator = YES;
    
//    ProductViewController* productController = (ProductViewController*)[self.router viewControllerWithClass:[ProductViewController class] fromStoryboardWithName:@"ProductStoryboard"];
//    productController.product = item;
//    [self.router.navigationController pushViewController:productController animated:YES];
}
@end
