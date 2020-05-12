//
//  Order.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/18/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Location.h"
#import "Price.h"

typedef enum : NSInteger {
    OrderStatusDefault = 0,
    OrderStatusWaitBuyer,
    OrderStatusBuyerPaymentOk,
    OrderStatusPurchaseInProgress,
    OrderStatusPurchased,
    OrderStatusInTransit,
    OrderStatusDelivered,
    OrderStatusBuyerReceivedConfirm,
    OrderStatusBuyerReceivedFailed,
    OrderStatusClosed,
    OrderStatusCanceled
} OrderStatus;

typedef enum : NSInteger {
    OrderStatusAPIInProgress = 0,
    OrderStatusAPIFinished,
    OrderStatusAPICanceled
} OrderStatusAPI;


@interface Order : NSObject
@property (nonatomic, strong) User *buyer;
@property (nonatomic, strong) User *courier;
//@property (nonatomic) NSString* buyerName;
@property (nonatomic) NSString* comment;
//@property (nonatomic) NSString* member_id;
//@property (nonatomic) NSString* courier_id;
@property (nonatomic) NSString* product_id;
@property (nonatomic, strong) Price *productPrice;
@property (nonatomic, strong) NSString* productVideo;
//@property (nonatomic) double price; // Depricated,  use "productPrice" instead;
@property (nonatomic) double tax;
@property (nonatomic) NSDate* delivery_date_from;
@property (nonatomic) NSDate* delivery_date_to;
//@property (nonatomic) NSString* delivery_location_city;
//@property (nonatomic) NSString* delivery_location_country;
//@property (nonatomic) NSString* delivery_location_region;
@property (nonatomic) Location* deliveryLocation;
@property (nonatomic) Location* location;
@property (nonatomic) int status;
@property (nonatomic) NSString* number;
//@property (nonatomic) NSString* total;
@property (nonatomic) NSString* orderedDate;
@property (nonatomic) NSString* imageUrl;
@property (nonatomic) NSArray* availableStatusTitles;
@property (nonatomic) NSArray* availableOrderStatusAPITitles;
@property (nonatomic) int buyerPaymentStatus;
@property (nonatomic) int buyerDeliveryStatus;
@property (nonatomic) int courierPaymentStatus;
@property (nonatomic) int courierDeliveryStatus;
@property (nonatomic) int count;
@property (nonatomic) Price *deliveryReward;
@property (nonatomic) Price *totalPrice;
@property (nonatomic) NSString* ownerID;
@property (nonatomic) NSString* orderID;
@property (nonatomic) NSString* productName;
@property (nonatomic) NSString* userID;
@property (nonatomic) int countAlert;
@property (nonatomic) NSDate* expectedDeliveryDate;
+(instancetype)orderFromDictionary:(NSDictionary*)dictionary;
@end
