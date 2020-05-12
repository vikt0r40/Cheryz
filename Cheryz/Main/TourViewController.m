//
//  TourViewController.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/27/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "TourViewController.h"
//#import "TabController.h"
#import "Tour.h"
#import "LiveCommandClient+TourCommands.h"
#import "AlertView.h"
#import "CHUserToken.h"
#import "TourCoordinator.h"
#import "GetTourByIDAPIClient.h"

@interface TourViewController ()<TypeViewDelegate>

@end

@implementation TourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCoordinator];
    [self getTourFromServer];

}
-(void)setupCoordinator{
    self.tourCoordinator = [[TourCoordinator alloc] initWithTourViewController:self];
    
    // Start coordinator. This makes our tabs life.
    [self.tourCoordinator start];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
//    TabController* tabController = (TabController*)[self targetViewControllerForAction:@selector(hideTabBar) sender:self];
//    [tabController hideTabBar];
    
    //[self setStatusBarBackgroundColor:[UIColor colorWithRed:124.f/255.f green:124.f/255.f blue:124.f/255.f alpha:1]];
    
    [self setStatusBarBackgroundColor:[UIColor clearColor]];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    TabController* tabController = (TabController*)[self targetViewControllerForAction:@selector(showTabBar) sender:self];
//    [tabController showTabBar];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.tourCoordinator stop];
}


- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    if (@available(iOS 13.0, *)) {
        UIView *statusBar = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame];
        statusBar.backgroundColor = color;
        
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
        
    } else {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
    }
    
}

-(void)typeViewDidPressedAtIndex:(int)index {
    NSLog(@"Was pressed index %d", index);
}

-(IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)handleErrorDict:(NSDictionary *)dict{
    [AlertView showAlertViewWithTitle:@"Error" message:dict[@"data"][@"error"] controller:self];
}
-(void)getTourFromServer {
    [GetTourByIDAPIClient getTourWithID:self.tour.guid success:^(NSDictionary *response) {
//        NSLog(@"Tour loaded from server");
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
