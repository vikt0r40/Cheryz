//
//  Order.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/18/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Order.h"
#import "NSDate+Server.h"

@implementation Order
-(instancetype)init{
    self = [super init];
    if(!self) return nil;
    
    self.availableStatusTitles = @[NSLocalizedString(@"Default", nil),
                                   NSLocalizedString(@"Waiting buyer payment", nil),
                                   NSLocalizedString(@"Buyer payment ok", nil),
                                   NSLocalizedString(@"Purchase in progress", nil),
                                   NSLocalizedString(@"Purchased", nil),
                                   NSLocalizedString(@"In transit", nil),
                                   NSLocalizedString(@"Delivered", nil),
                                   NSLocalizedString(@"Buyer received confirm", nil),
                                   NSLocalizedString(@"Buyer received failed", nil),
                                   NSLocalizedString(@"Closed", nil),
                                   NSLocalizedString(@"Canceled", nil)];
    
    self.availableOrderStatusAPITitles = @[NSLocalizedString(@"In progress", nil),
                                           NSLocalizedString(@"Finished", nil),
                                           NSLocalizedString(@"Canceled", nil)];
    return self;
}
+(instancetype)orderFromDictionary:(NSDictionary*)dictionary {
    Order* ord = [Order new];
    ord.count = [dictionary[@"count"] intValue];
    ord.productPrice = [Price priceFromDictionary:dictionary[@"price"]];
    ord.imageUrl = dictionary[@"product"][@"image"];
    ord.status = [dictionary[@"status"] intValue];
    ord.buyerPaymentStatus = [dictionary[@"buyer_payment_status"] intValue];
    ord.courierPaymentStatus = [dictionary[@"courier_payment_status"] intValue];
    ord.buyerDeliveryStatus = [dictionary[@"buyer_delivery_status"] intValue];
    ord.courierDeliveryStatus = [dictionary[@"courier_delivery_status"] intValue];
    ord.ownerID = dictionary[@"owner_id"];
    ord.orderID = dictionary[@"id"];
    ord.productVideo = dictionary[@"product"][@"video"];
    ord.productName = dictionary[@"product"][@"title"];
    ord.location = [Location locationFromDictionary:dictionary[@"location"]];
    ord.deliveryReward = [Price priceFromDictionary:dictionary[@"delivery_price"]];
    ord.totalPrice = [Price priceFromDictionary:dictionary[@"summary"]];
//    ord.courier_id = dictionary[@"courier"][@"user_id"];
    ord.userID = dictionary[@"user"][@"user_id"];
    ord.countAlert = [dictionary[@"count_alert"] intValue];
    ord.buyer = [User userFromDictionary:dictionary[@"user"]];
    ord.courier = [User userFromDictionary:dictionary[@"courier"]];
    NSLog(@"date %lld",[dictionary[@"delivery_date_to"] longLongValue]);
    if([dictionary[@"delivery_date_to"] longLongValue]>0)
        ord.delivery_date_to = [NSDate dateFromServerFormat:[dictionary[@"delivery_date_to"] doubleValue]];
    NSDate *date = [NSDate dateFromServerFormat:[dictionary[@"date_creation"] doubleValue]];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    ord.orderedDate = dateString;
    ord.deliveryLocation = [Location locationFromDictionary:dictionary[@"delivery_location"]];
    
    if([dictionary[@"delivery_date_to"] doubleValue] > 0) {
        ord.expectedDeliveryDate = [NSDate dateFromServerFormat:[dictionary[@"delivery_date_to"] doubleValue]];
    }
    return ord;
}
@end
