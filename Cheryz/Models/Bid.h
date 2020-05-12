//
//  Bid.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/16/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Wishlist, Product, User, Location;
#import "Price.h"

typedef enum : NSUInteger {
    BidStatusNew = 0,
    BidStatusAccepted,
    BidStatusDeclined
} BidStatus;

@interface Bid : NSObject
+(instancetype)bidInWishlistFromDictionary:(NSDictionary *)dictionary;
+(instancetype)bidFromDictionary:(NSDictionary*)dictionary;
@property (nonatomic, strong) NSString* bidID;
@property (nonatomic) Price *bidDeliveryPrice;
@property (nonatomic, strong) NSDate* bidDeliveryDate;
@property (nonatomic) int bidStatus;
@property (nonatomic, strong) NSString* bidComment;
@property (nonatomic, strong) Wishlist* wishlist;
@property (nonatomic, strong) Product* product;
@property (nonatomic, strong) User *buyer;
@property (nonatomic, strong) User *courier;
@property (nonatomic, strong) Location* productLocation;
@property (nonatomic, strong) Location* deliveryLocation;
@property (nonatomic, strong) NSString* messageGroupID;
@property (nonatomic) int count;
//@property (nonatomic) int userRating;
//@property (nonatomic, strong) NSString* wishlistTitle;
//@property (nonatomic) int numberOfBids;
//@property (nonatomic, strong) NSString* userImageUrl;
//@property (nonatomic) double bidPrice;
@end
