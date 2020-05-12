//
//  TourCoordinator.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "TourCoordinator.h"
#include <UIKit/UIKit.h>
#import "Router.h"
#import "TourViewController.h"
#import "LiveCommandClient+TourCommands.h"
#import "TourTabViewControllerProtocol.h"

@interface TourCoordinator() <TourViewControllerDatasource>

@property (nonatomic, strong) UIViewController *selectedController;

@end

@implementation TourCoordinator
-(instancetype)initWithTourViewController:(TourViewController *)tourViewController{
    self = [super init];
    
    if(!self) return nil;
    
    _tourViewController = tourViewController;
    _tourViewController.datasource = self;
    _router = [[Router alloc] initWithNavigationController:_tourViewController.navigationController];
    self.tabsArray = [NSMutableArray new];
    
    self.tourViewController.mContentView.hidden = YES;
    return self;
}
-(NSInteger)defaultTabIndex{
    return 0;
}
-(void)start{
    
    // We could change here the first selected tab.
    
    NSMutableArray *tabs = [NSMutableArray new];
    [self.tabs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tabs addObject:obj[@"Title"]];
        [self loadTabViewControllerFromDictionary:obj];
    }];
    self.tourViewController.typeView.buttonsArray = tabs;
    self.tourViewController.typeView.selectedIndex = [self defaultTabIndex];
    self.tourViewController.typeView.typeViewDelegate = self;

    [self typeViewDidPressedAtIndex:[self defaultTabIndex]];
    
    [[LiveCommandClient sharedInstance] startReceiveEventsFromTourWithID:self.tourViewController.tour.guid responseHandler:^(NSDictionary *response, BOOL success) {
        if(!success){
//            [self handleErrorDict:response];
        }
    }];
    
}
-(void)stop{
    [[LiveCommandClient sharedInstance] stopReceiveEventsFromTourWithID:self.tourViewController.tour.guid responseHandler:^(NSDictionary *response, BOOL success) {
        if(!success){
            //            [self handleErrorDict:response];
        }
    }];
    [self.tabsArray enumerateObjectsUsingBlock:^(id <TourTabViewControllerProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(willUnload)]){
            [obj willUnload];
        }
    }];
}
-(void)loadTabViewControllerFromDictionary:(NSDictionary *)tabDict{
    
    NSString *storyboardName = tabDict[@"StoryboardName"];
    storyboardName = storyboardName?storyboardName:@"Main";
    UIViewController *vc = [self loadContentViewControllerWithClassName:tabDict[@"ClassName"] fromStoryboard:storyboardName];
    if([vc respondsToSelector:@selector(setTour:)]){
        [vc performSelector:@selector(setTour:) withObject:self.tourViewController.tour];
    }
    if([vc respondsToSelector:@selector(setDelegate:)]){
        id delegate = tabDict[@"Delegate"];
        if(delegate) {
            [vc performSelector:@selector(setDelegate:) withObject:delegate];
        }
    }
    if(tabDict[@"ViewControllerCallback"]){
        void(^block)(id) = tabDict[@"ViewControllerCallback"];
        block(vc);
    }
    if([vc respondsToSelector:@selector(willLoad)]){
        [(UIViewController <TourTabViewControllerProtocol>*)vc willLoad];
    }
    
}

-(void)typeViewDidPressedAtIndex:(int)index{
    
    if(_selectedController != nil) {
        [_selectedController.view removeFromSuperview];
    }
    
    _selectedController = self.tabsArray[index];
    
    _selectedController.view.frame = _tourViewController.tabContentView.bounds;
    [_selectedController beginAppearanceTransition:YES animated:NO];
    [_tourViewController.tabContentView addSubview:_selectedController.view];
    [_selectedController endAppearanceTransition];
    [_selectedController didMoveToParentViewController:_tourViewController];
}
-(NSArray *)tabs{
    return @[];
}
-(UIViewController *)loadContentViewControllerWithClassName:(NSString*)className fromStoryboard:(NSString *)storyboard{
    
    Router *router = [Router new];
    UIViewController *newContentViewController = [router viewControllerWithClass:NSClassFromString(className) fromStoryboardWithName:storyboard];
    [self.tabsArray addObject:newContentViewController];
    
    return newContentViewController;
}

@end
