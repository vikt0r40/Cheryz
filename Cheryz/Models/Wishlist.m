//
//  Wishlist.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/18/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Wishlist.h"
#import "Bid.h"
#import "NSDate+Server.h"
#import "Location.h"

@implementation Wishlist
-(instancetype)init {
    self = [super init];
    if(!self) return nil;
    
    self.accessLevel = @[NSLocalizedString(@"Public", nil),NSLocalizedString(@"Private", nil)];
    
    return self;
}
+(instancetype)wishlistFromDictionary:(NSDictionary*)dictionary {
    Wishlist* wishlist = [[Wishlist alloc] init];
    wishlist.wishlistId = dictionary[@"id"];
    wishlist.wishlistTitle = dictionary[@"wish_list_title"];
    wishlist.productComment = dictionary[@"comment"];
    wishlist.wishlistPrice = [Price priceFromDictionary:dictionary[@"max_price"]];
    wishlist.productCount = [dictionary[@"count"] intValue];
    wishlist.userId = dictionary[@"owner"][@"user_id"];
    wishlist.userName = [NSString stringWithFormat:@"%@ %@",dictionary[@"owner"][@"first_name"],dictionary[@"owner"][@"last_name"]];
    wishlist.userImageUrl = dictionary[@"owner"][@"photo"];
    wishlist.productImageUrl = dictionary[@"product_image"];
    wishlist.productVideo = dictionary[@"product_video"];
    wishlist.isOnlyDelivery = [dictionary[@"is_only_delivery"] boolValue];
    wishlist.deliveryDateFrom = [NSDate dateFromServerFormat:[dictionary[@"delivery_date_from"]doubleValue]];
    wishlist.deliveryDateTo = [NSDate dateFromServerFormat:[dictionary[@"delivery_date_to"]doubleValue]];
    wishlist.deliveryReward = [Price priceFromDictionary:dictionary[@"delivery_price"]];//[dictionary[@"delivery_price"] doubleValue];
    wishlist.productOwnerID = dictionary[@"product_owner_id"];
    wishlist.location = [Location locationFromDictionary:dictionary[@"product_location"]];
    wishlist.deliveryLocation = [Location locationFromDictionary:dictionary[@"delivery_location"]];
    wishlist.tourLocation = [Location locationFromDictionary:dictionary[@"tour_location"]];
    int visibility = [dictionary[@"visibility"] intValue];
    if(visibility == 2){
        wishlist.visibility = WishlistAccessTypePrivate;
    }else{
        wishlist.visibility = WishlistAccessTypePublic;
    }
    wishlist.countAlert = [dictionary[@"count_alert"] intValue];
    wishlist.bids = [NSMutableArray new];
    if([dictionary[@"bidsList"] isKindOfClass:[NSArray class]]){
        [dictionary[@"bidsList"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Bid* newBid = [Bid bidFromDictionary:obj];
            [wishlist.bids addObject:newBid];
        }];
    }
    wishlist.accessLevel = @[NSLocalizedString(@"Public", nil),NSLocalizedString(@"Private", nil)];
    NSLog(@"%@", dictionary);
    return wishlist;
}
-(NSString *)formattedDeliveryAddress{
    return self.deliveryLocation.formattedAddress;
//    NSMutableString *address = [[NSMutableString alloc] init];
//    if([_deliveryCity isKindOfClass:[NSString class]]){
//        [address appendString:_deliveryCity];
//    }
//    if([_deliveryRegion isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_deliveryRegion];
//    }
//    if([_deliveryCountry isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_deliveryCountry];
//    }
//    return address;
}
@end
