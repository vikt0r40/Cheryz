//
//  Bid.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/16/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Bid.h"
#import "Wishlist.h"
#import "Product.h"
#import "User.h"
#import "Location.h"
#import "NSDate+Server.h"

@implementation Bid
+(instancetype)bidInWishlistFromDictionary:(NSDictionary *)dictionary{
    Bid* bid = [[Bid alloc] init];
    bid.courier = [User new];
    bid.courier.firstName = dictionary[@"owner"][@"first_name"];
    bid.courier.lastName = dictionary[@"owner"][@"last_name"];
    bid.courier.userID = dictionary[@"owner"][@"user_id"];
    bid.courier.imageURL = [NSURL URLWithString:dictionary[@"owner"][@"photo"]];
    bid.bidID = dictionary[@"id"];
    bid.bidDeliveryPrice = [Price priceFromDictionary:dictionary[@"delivery_price"]];
    bid.bidDeliveryDate = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"delivery_date_to"] doubleValue]/1000.];
    bid.messageGroupID = dictionary[@"msg_group_uid"];
    return bid;
}

+(instancetype)myBidInListFromDictionary:(NSDictionary *)dictionary{
    Bid* bid = [[Bid alloc] init];
    
    return bid;
}
+(instancetype)bidFromDictionary:(NSDictionary*)dictionary {
    Bid* bid = [[Bid alloc] init];
    bid.messageGroupID = dictionary[@"msg_group_uid"];
    bid.bidID = dictionary[@"id"];
    bid.bidComment = dictionary[@"comment"];
    bid.count = [dictionary[@"count"] intValue];
    
    bid.bidDeliveryPrice = [Price priceFromDictionary:dictionary[@"delivery_price"]];
    
    bid.wishlist = [Wishlist new];
    bid.wishlist.wishlistId = dictionary[@"whish_list"][@"id"];
    bid.wishlist.wishlistPrice = [Price priceFromDictionary:dictionary[@"max_price"]];
    bid.wishlist.wishlistTitle = dictionary[@"whish_list"][@"title"];
    bid.wishlist.isOnlyDelivery = [dictionary[@"whish_list"][@"is_only_delivery"] boolValue];
    bid.courier = [User new];
    bid.courier.userID = dictionary[@"courier"][@"id"];
    bid.courier.firstName = dictionary[@"courier"][@"first_name"];
    bid.courier.lastName = dictionary[@"courier"][@"last_name"];
    bid.courier.imageURL = [NSURL URLWithString:dictionary[@"courier"][@"photo"]];

    bid.wishlist.location = [Location locationFromDictionary:dictionary[@""]];
    
    bid.buyer = [User new];
    bid.buyer.userID = dictionary[@"user"][@"id"];
    bid.buyer.firstName = dictionary[@"user"][@"first_name"];
    bid.buyer.lastName = dictionary[@"user"][@"last_name"];
    bid.buyer.imageURL = [NSURL URLWithString:dictionary[@"user"][@"photo"]];
    
    bid.product = [Product new];
    bid.product.productImageUrl = dictionary[@"product"][@"image"];
    bid.product.productVideoUrl = dictionary[@"product"][@"video"];
    
    bid.deliveryLocation = [Location locationFromDictionary:dictionary[@"delivery_location"]];
    bid.productLocation = [Location locationFromDictionary:dictionary[@"location"]];
    bid.bidDeliveryDate = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"delivery_date_to"] doubleValue]/1000.];
    return bid;
}

@end
