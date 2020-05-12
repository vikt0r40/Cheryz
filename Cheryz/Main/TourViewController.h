//
//  TourViewController.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/27/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeView.h"
#import "Tour.h"

@protocol TourViewControllerDatasource <NSObject>

-(NSArray*)tabs;

@end

@class Tour, TourCoordinator;

@interface TourViewController : UIViewController

@property (nonatomic, strong) Tour *tour;

@property (nonatomic, strong) IBOutlet TypeView *typeView;
@property (nonatomic, strong) IBOutlet UIView *tabContentView;
@property (nonatomic, strong) IBOutlet UIView* mContentView;

@property (nonatomic, weak) id <TourViewControllerDatasource> datasource;
@property (nonatomic, strong) TourCoordinator *tourCoordinator;

-(IBAction)backAction:(id)sender;
-(void)setupCoordinator;
-(void)handleErrorDict:(NSDictionary *)dict;
@end
