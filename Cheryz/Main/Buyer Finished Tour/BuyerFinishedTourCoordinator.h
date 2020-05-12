//
//  BuyerFinishedTourCoordinator.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/6/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "TourCoordinator.h"
#import "BuyerFinishedTourViewController.h"
#import "BuyerTourPopupsViewController.h"
#import <UIKit/UIKit.h>

@interface BuyerFinishedTourCoordinator : TourCoordinator <BuyerFinishedTourViewControllerDelegate, BuyerTourPopupsViewControllerDelegate>
@property (nonatomic, strong) BuyerTourPopupsViewController* popupViewController;
@property (nonatomic, strong) UIView* pdpView;
@end
