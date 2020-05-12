//
//  Cheryz.h
//  CheryzSDK
//
//  Created by Viktor Todorov on 29.04.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CheryzSDK : NSObject

@property (nonatomic, strong) UIViewController* tourController;

//Start the video player by passing the controller and the tour id.
+(void)startVideoPlayerOnController:(UIViewController*)controller tour:(NSString*)tourID;
+(void)startVideoPlayerOnController:(UIViewController*)controller tour:(NSString*)tourID pdpView:(UIView*)pdpView;
+(void)startBroadcastingOnController:(UIViewController*)controller tour:(NSString*)tourID pdpView:(UIView*)pdpView;

+(UIView* )startVideoBroadcastingWithTour:(NSString*)tourID pdpView:(UIView*)pdpView delegate:(id)delegate;
+(UIView* )startVideoPlayerWithTour:(NSString*)tourID pdpView:(UIView*)pdpView delegate:(id)delegate;
+(UIView* )startRequestPrivateTour:(NSString*)tourID;

//Initialize SDK by passing API Key, User ID, First Name and Last Name
+(void)initializeWithAPIKey: (NSString*)apiKey userID:(NSString*)userID fName:(NSString*)fName lName:(NSString*)lName;

//Load available tours for you
+(void)loadTours:(void (^)(BOOL success, NSDictionary* result))block;

//Return the pdpView in block
+(UIView*)setupPDPView;

+ (instancetype)sharedInstance;
@end

