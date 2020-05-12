//
//  TourPop.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/30/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    ShopperBuyRequestPopupType = 0,
    BuyerBuyRequestPopupType,
    ShopperPriceRequestPopupType,
    ShopperItemInfoRequestPopupType,
    BuyerItemInfoRequestPopupType,
    CheckViewerPopupType,
    PriceEditPopupType
} TourPopupType;

@interface TourPop : NSObject
@property (nonatomic) TourPopupType type;
@property (nonatomic, strong) id model;
@end
