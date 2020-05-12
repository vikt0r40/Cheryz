//
//  Cheryz.m
//  CheryzSDK
//
//  Created by Viktor Todorov on 29.04.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import "CheryzSDK.h"
#import "BuyerFinishedTourViewController.h"
#import "AuthorizationAPI.h"
#import "CHUserToken.h"
#import "ToursAPI.h"
#import "PDPViewController.h"
#import "BuyerTourViewController.h"
#import "RequestPrivateTourViewController.h"

@implementation CheryzSDK

+ (instancetype)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static CheryzSDK * _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        
    });
    
    // returns the same object each time
    return _sharedObject;
}


+(void)startVideoPlayerOnController:(UIViewController*)controller tour:(NSString*)tourID {
    NSBundle* bundle = [NSBundle bundleForClass:self];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:bundle];
    BuyerFinishedTourViewController *add =
               [storyboard instantiateViewControllerWithIdentifier:@"BuyerFinishedTourViewController"];
    add.tour = [Tour new];
    add.tour.guid = tourID;
    [controller presentViewController:add
                       animated:YES
                     completion:nil];
}
+(void)startVideoPlayerOnController:(UIViewController*)controller tour:(NSString*)tourID pdpView:(UIView*)pdpView {
    NSBundle* bundle = [NSBundle bundleForClass:self];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:bundle];
    BuyerFinishedTourViewController *add =
               [storyboard instantiateViewControllerWithIdentifier:@"BuyerFinishedTourViewController"];
    add.tour = [Tour new];
    add.tour.guid = tourID;
    add.pdpView = pdpView;
    [controller presentViewController:add
                       animated:YES
                     completion:nil];
}
+(UIView* )startVideoPlayerWithTour:(NSString*)tourID pdpView:(UIView*)pdpView delegate:(id)delegate {
    NSBundle* bundle = [NSBundle bundleForClass:self];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:bundle];
    BuyerFinishedTourViewController *add =
               [storyboard instantiateViewControllerWithIdentifier:@"BuyerFinishedTourViewController"];
    add.tour = [Tour new];
    add.tour.guid = tourID;
    add.pdpView = pdpView;
    [CheryzSDK sharedInstance].tourController = add;
    return add.view;
}
+(UIView* )startVideoBroadcastingWithTour:(NSString*)tourID pdpView:(UIView*)pdpView delegate:(id)delegate {
    NSBundle* bundle = [NSBundle bundleForClass:self];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:bundle];
    BuyerTourViewController *add =
               [storyboard instantiateViewControllerWithIdentifier:@"BuyerTourViewController"];
    add.tour = [Tour new];
    add.tour.guid = tourID;
    //add.pdpView = pdpView;
    add.reactDelegate = delegate;
    [CheryzSDK sharedInstance].tourController = add;
    return add.view;
}
+(UIView* )startRequestPrivateTour:(NSString*)tourID  {
    NSBundle* bundle = [NSBundle bundleForClass:self];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:bundle];
    RequestPrivateTourViewController *add =
               [storyboard instantiateViewControllerWithIdentifier:@"RequestPrivateTourViewController"];

    return add.view;
}
+(void)startBroadcastingOnController:(UIViewController*)controller tour:(NSString*)tourID pdpView:(UIView*)pdpView {
    NSBundle* bundle = [NSBundle bundleForClass:self];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                         bundle:bundle];
    BuyerTourViewController *add =
               [storyboard instantiateViewControllerWithIdentifier:@"BuyerTourViewController"];
    add.tour = [Tour new];
    add.tour.guid = tourID;
    add.pdpView = pdpView;
    [controller presentViewController:add
                       animated:YES
                     completion:nil];
}
+(void)initializeWithAPIKey: (NSString*)apiKey userID:(NSString*)userID fName:(NSString*)fName lName:(NSString*)lName {
    
    [AuthorizationAPI autorizeWithAPI:apiKey userID:userID fName:fName lName:lName success:^(NSDictionary *response) {
        NSLog(@"CheryzSDK Initialization Success");
        BOOL isAgent = response[@"is_agent"] == [NSNull class] ? NO : YES;
        [[CHUserToken sharedInstance] storeAccessToken:response[@"token"] forUserID:userID isAgent:isAgent];
    } failure:^(NSError *error) {
        NSLog(@"CheryzSDK Failed to Initialized");
    }];
    
}
+(void)loadTours:(void (^)(BOOL success, NSDictionary* result))block {
    [ToursAPI loadTours:^(NSDictionary *response) {
        block(true, response);
    } failure:^(NSError *error) {
        block(false, nil);
    }];
}

+(UIView*)setupPDPView {
    NSBundle* bundle = [NSBundle bundleForClass:self];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"BuyersFinishedTourStoryboard"
                                                        bundle:bundle];
    PDPViewController *add =
              [storyboard instantiateViewControllerWithIdentifier:@"PDPViewController"];
    
    return add.view;
}
@end
