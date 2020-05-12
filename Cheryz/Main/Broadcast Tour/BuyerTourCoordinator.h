//
//  BuyerTourCoordinator.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "TourCoordinator.h"
#import "BuyerTourPopupsViewController.h"
#import "BuyerTourViewController.h"
#import "Product.h"

@interface BuyerTourCoordinator : TourCoordinator <BuyerTourPopupsViewControllerDelegate, BuyerTourViewControllerDelegate>
-(void)infoResponseInTourNotification:(NSNotification *)notification;
-(void)broadcastingWasStopped;
-(void)restart;
-(void)tourFinished:(NSNotification *)notification;
@property (nonatomic, strong) UIView* pdpView;
@end
