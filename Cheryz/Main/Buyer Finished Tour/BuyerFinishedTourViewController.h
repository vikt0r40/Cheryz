//
//  BuyerFinishedTourViewController.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/6/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol BuyerFinishedTourViewControllerDelegate <NSObject>

@required
-(void)startVideoWithURL:(NSURL*)videoURL;
-(void)didClickFacebookButton:(NSString*)link;
@end

@interface BuyerFinishedTourViewController : TourViewController
@property (nonatomic, strong) IBOutlet UIView* videoView;
@property (nonatomic, strong) AVPlayerViewController* playerController;
@property (nonatomic, strong) UIView* pdpView;
@property (nonatomic, weak) id <BuyerFinishedTourViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoViewProportionalHeight;
@property (strong, nonatomic) NSLayoutConstraint* videoViewNewConstraint;
-(void)loadTour;
@end
