//
//  BuyerFinishedTourViewController.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/6/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "BuyerFinishedTourViewController.h"
#import "BuyerFinishedTourCoordinator.h"
#import "GetTourByIDAPIClient.h"
#import "Device.h"
#import "LiveCommandClient+TourCommands.h"
#import "Tour.h"
#import "SipSettings.h"
#import "LiveCommandClient+BuyerBroadcasting.h"
@interface BuyerFinishedTourViewController ()
@property (strong, nonatomic) IBOutlet UIView *videoActivityView;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

@end

@implementation BuyerFinishedTourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.videoActivityView setHidden:NO];
    [self loadTour];
    //[self.facebookButton middleAlignButtonWithSpacing:2];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[LiveCommandClient sharedInstance] connect:nil];
//    if(!self.playerController) {
//        if(![self.tour.videoURL isKindOfClass:[NSNull class]]) {
//            if([self.delegate respondsToSelector:@selector(startVideoWithURL:)]) {
//                [self.videoActivityView setHidden:YES];
//                [self.delegate startVideoWithURL:[NSURL URLWithString:self.tour.videoURL]];
//            }
//        }
//
//    }
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    if(self.playerController.player.rate != 0 && self.playerController.player.error == nil) {
        [self.playerController.player pause];
    }
}
-(void)loadTour{
    [GetTourByIDAPIClient getTourWithID:self.tour.guid success:^(NSDictionary *response) {
        self.tour.videoURL = response[@"video"];
        
        if(![self.tour.videoURL isKindOfClass:[NSNull class]]) {
            if([self.delegate respondsToSelector:@selector(startVideoWithURL:)]) {
                [self.videoActivityView setHidden:YES];
                [self.delegate startVideoWithURL:[NSURL URLWithString:self.tour.videoURL]];
            }
        }
    } failure:^(NSError *error) {
        [CHAPIRequest httpStatusCodeFromError:error];
    }];
}
-(void)setupCoordinator{
    self.tourCoordinator = [[BuyerFinishedTourCoordinator alloc] initWithTourViewController:self];
    
    // Start coordinator. This makes our tabs life.
    ((BuyerFinishedTourCoordinator*)self.tourCoordinator).pdpView = self.pdpView;
    [self.tourCoordinator start];
    
    self.delegate = (BuyerFinishedTourCoordinator*)self.tourCoordinator;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)didClickFacebookButton:(id)sender {
    if([self.delegate respondsToSelector:@selector(didClickFacebookButton:)]) {
        NSString* link = [NSString stringWithFormat:@"https://cheryz.com/tour/%@",self.tour.guid];
        [self.delegate didClickFacebookButton:link];
    }
}
#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification*)aNotification {
    
    NSDictionary *info  = aNotification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    if(self.tabContentView.frame.size.height - keyboardFrame.size.height < 70) {
        self.videoViewNewConstraint = [NSLayoutConstraint constraintWithItem:self.videoViewProportionalHeight.firstItem attribute:self.videoViewProportionalHeight.firstAttribute relatedBy:self.videoViewProportionalHeight.relation toItem:self.videoViewProportionalHeight.secondItem attribute:self.videoViewProportionalHeight.secondAttribute multiplier:0.3 constant:self.videoViewProportionalHeight.constant];
        
        self.videoViewProportionalHeight.active = NO;
        self.videoViewNewConstraint.active = YES;
        
        [UIView animateWithDuration: 0.1 animations:^{
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
        }];
    }
}
-(void)keyboardWillHide:(NSNotification*)aNotification {
    
    self.videoViewProportionalHeight.active = YES;
    self.videoViewNewConstraint.active = NO;
    
    [UIView animateWithDuration: 0.1 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}
@end
