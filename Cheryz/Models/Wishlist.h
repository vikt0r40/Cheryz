//
//  Wishlist.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/18/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Bid;
@class Location;
#import "Price.h"

typedef enum : NSUInteger {
    WishlistAccessTypePublic = 0,
    WishlistAccessTypePrivate = 2
} WishlistAccessType;

@interface Wishlist : NSObject

+(instancetype)wishlistFromDictionary:(NSDictionary*)dictionary;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) Location *deliveryLocation;
@property (nonatomic, strong) Location *tourLocation;
@property (nonatomic) NSString* wishlistId;
@property (nonatomic) NSString* tour_id;
@property (nonatomic) NSString* product_id;
@property (nonatomic) Price *wishlistPrice;
@property (nonatomic) Price *deliveryReward;

@property (nonatomic, strong) NSArray* accessLevel;
@property (nonatomic) WishlistAccessType visibility;

@property (nonatomic) NSString* delivery_location_place_id;
@property (nonatomic) NSString* userId;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* userImageUrl;

@property (nonatomic) NSArray* tours;
@property (nonatomic) NSDate* deliveryDateFrom;
@property (nonatomic) NSDate* deliveryDateTo;
@property (nonatomic) NSString* productComment;
@property (nonatomic) NSString* productImageUrl;
@property (nonatomic) NSString* productOwnerID;
@property (nonatomic) NSString* productTitle;
@property (nonatomic) NSString* productVideo;
@property (nonatomic) NSString* productDescription;
@property (nonatomic) NSString* wishlistTitle;
@property (nonatomic) int productCount;
@property (nonatomic) NSMutableArray<Bid *> *bids;
@property (nonatomic) int numberOfBids;
@property (nonatomic) BOOL isOnlyDelivery;
@property (nonatomic) int countAlert;
-(NSString *)formattedDeliveryAddress;
@end
