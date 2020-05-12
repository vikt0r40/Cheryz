//
//  TourCoordinator.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeView.h"
#import "TourViewController.h"
#import "Router.h"

@interface TourCoordinator : NSObject <TypeViewDelegate>
-(instancetype)initWithTourViewController:(TourViewController *)tourViewController;

-(void)start;
-(void)stop;

-(NSInteger)defaultTabIndex;
-(UIViewController *)loadContentViewControllerWithClassName:(NSString*)className fromStoryboard:(NSString *)storyboard;
@property (nonatomic, weak) TourViewController *tourViewController;
@property (nonatomic, strong) Router *router;
@property (nonatomic, strong, readonly) NSArray *tabs;
@property (nonatomic, strong) NSMutableArray* tabsArray;

@end
