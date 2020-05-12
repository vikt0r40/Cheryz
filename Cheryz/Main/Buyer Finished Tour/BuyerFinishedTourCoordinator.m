//
//  BuyerFinishedTourCoordinator.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/6/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "BuyerFinishedTourCoordinator.h"
#import "AboutContentTableViewController.h"
#import "MessagesContentTableViewController.h"
//#import "OrdersContentTableViewController.h"
#import "ShareFacebook.h"
#import "BuyerFinishedTourViewController.h"
#import "LiveCommandClient+TourCommands.h"
#import "Product.h"
//#import "ItemsFinishedContentCollectionViewController.h"
//#import "AddToWishlistTableViewController.h"
//#import "ProductViewController.h"
#import "RequestPrivateTourViewController.h"
#import "PDPViewController.h"

@interface BuyerFinishedTourCoordinator ()

typedef enum : NSUInteger {
    VideoNotReadyFinishedTourState,
    VideoReadyFinishedTourState
} FinishedTourState;

@property (nonatomic) FinishedTourState state;

@end

@implementation BuyerFinishedTourCoordinator
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
-(NSInteger)defaultTabIndex{
    return 1;
}
-(void)start{
    
    self.state = VideoNotReadyFinishedTourState;
    
    __weak BuyerFinishedTourCoordinator *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReadyNotification:) name:kTourIsFinishedListenerKey object:nil];
    
    [[LiveCommandClient sharedInstance] getStreamingConfigForTourID:self.tourViewController.tour.guid
                                                    responseHandler:^(NSDictionary *dict, BOOL success) {
                                                        if([dict[@"data"][@"status"] intValue]==4){
                                                            // tour is finished
                                                            if(weakSelf.state != VideoReadyFinishedTourState){
                                                                [[NSNotificationCenter defaultCenter] removeObserver:weakSelf name:kTourIsFinishedListenerKey object:nil];
                                                                
                                                                weakSelf.state = VideoReadyFinishedTourState;
                                                            }
                                                        }
                                                    }];
    [super start];
}
-(void)videoReadyNotification:(NSNotification *)notification{
    self.state = VideoReadyFinishedTourState;
}
-(void)stop{
    [super stop];
}
-(void)setState:(FinishedTourState)state{
    _state = state;
    switch (state) {
        case VideoNotReadyFinishedTourState:
            NSLog(@"State video not ready");
            break;
            
        case VideoReadyFinishedTourState:
            NSLog(@"State video ready");
            [((BuyerFinishedTourViewController *) self.tourViewController) loadTour];
            break;
            
        default:
            break;
    }
}

-(void)startVideoWithURL:(NSURL *)videoURL {
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    
    BuyerFinishedTourViewController* currentController = (BuyerFinishedTourViewController*)self.tourViewController;
    
    currentController.playerController = [[AVPlayerViewController alloc]init];
    currentController.playerController.player = player;
    
    [currentController addChildViewController:currentController.playerController];
    [currentController.videoView addSubview:currentController.playerController.view];
    currentController.playerController.view.frame = currentController.videoView.frame;
    [currentController.playerController.player play];
}
-(void)didClickFacebookButton:(NSString *)link {
    [ShareFacebook shareTourToFacebook:self.tourViewController link:link];
}
-(void)showAddToWishlistController:(Product *)product {
//    [self.router viewControllerWithClass:[AddToWishlistTableViewController class] fromStoryboardWithName:@"WishlistStoryboard" controllerHandler:^(id viewController) {
//        
//        AddToWishlistTableViewController* controller = viewController;
//        controller.product = product;
//        [self.router.navigationController pushViewController:controller animated:YES];
//    }];
}
-(void)didSelectItem:(Product *)item {
//    [self.router viewControllerWithClass:[ProductViewController class] fromStoryboardWithName:@"ProductStoryboard" controllerHandler:^(id viewController) {
//
//        ProductViewController* controller = viewController;
//        controller.product = item;
//        [self.router.navigationController pushViewController:controller animated:YES];
//    }];
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
-(void)didSelectCheckWithImage:(UIImage *)image{
    [self showPopupView];
    
    TourPop *tourPop = [TourPop new];
    tourPop.type = CheckViewerPopupType;
    tourPop.model = image;
    
    [self.popupViewController addTourPopup:tourPop];
    
}
@end
