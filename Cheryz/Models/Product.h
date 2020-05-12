//
//  Product.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/15/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tour.h"
#import "Wishlist.h"
#import "Price.h"

typedef enum : NSInteger {
    ProducTypeNotSpecified = -1,
    ProducTypeFashion = 0,
    ProducTypeFootware,
    ProducTypeFood,
    ProducTypeAntique,
    ProducTypeGifts
} ProductType;

typedef enum : NSInteger {
    ProducLanguageNotSpecified=-1,
    ProducLanguageEnglish = 0,
    ProducLanguageRussian,
    ProducLanguageGerman,
    ProducLanguageFrench,
    ProducLanguageSpanish,
    ProducLanguageChinese,
    ProducLanguageItalian
} ProductLanguage;

typedef enum : NSUInteger {
    ProductAccessTypeAll = 0,
    ProductAccessTypeForFriends,
    ProductAccessTypePrivate
} ProductAccessType;

@interface Product : NSObject
@property (nonatomic) NSString* productID;
@property (nonatomic) NSString* productTourID;
@property (nonatomic) NSString* productVideoUrl;
@property (nonatomic) NSString* productName;
//@property (nonatomic) NSString* productPrice; // Depricated, use *price;
@property (nonatomic, strong) Price* price;
@property (nonatomic) NSString* productRating;
@property (nonatomic) NSString* productLocation;
//@property (nonatomic, strong) NSString* placeID;
//@property (nonatomic, strong) NSString* region;
//@property (nonatomic, strong) NSString* city;
//@property (nonatomic, strong) NSString* country;
//@property (nonatomic, strong) NSString* placename;
//@property (nonatomic, readonly) NSString *formattedPlacename;
//
//@property (nonatomic) NSNumber *latitude;
//@property (nonatomic) NSNumber *longitude;

@property (nonatomic, strong) Location* location;
@property (nonatomic, strong) Location* deliveryLocation;

@property (nonatomic) NSString* productCategory;
@property (nonatomic) NSString* productImageUrl;
@property (nonatomic) NSString* productDescription;
@property (nonatomic) NSString* productOwnerId;
@property (nonatomic) NSString* productPromoURL;
@property (nonatomic) NSString* storeProductID;
@property (nonatomic) TourType tourType;
@property (nonatomic) NSDate* date_from;
@property (nonatomic) NSDate* date_to;
@property (nonatomic) int access_type;
@property (nonatomic) NSString* language;
@property (nonatomic) NSDate* createdDate;
@property (nonatomic) NSDate* createdDateTo;
@property (nonatomic) NSArray* availableTypeImages;
@property (nonatomic) NSArray* availableFilterTypeImages;
//@property (nonatomic) NSString* delivery_region;
//@property (nonatomic) NSString* delivery_city;
//@property (nonatomic) NSString* delivery_country;
//@property (nonatomic) NSString* delivery_place_id;
@property (nonatomic) NSDate* delivery_date_from;
@property (nonatomic) NSDate* delivery_date_to;
@property (nonatomic) double min_price;
@property (nonatomic) double max_price;
@property (nonatomic) NSDate* last_update;
@property (nonatomic) int wishlistCount;
@property (nonatomic) BOOL onlyWishlist;
@property (nonatomic) double wishlistMinPrice;
@property (nonatomic) double wishlistMaxPrice;

@property (nonatomic) BOOL isBuyReceiceEnabled;
@property (nonatomic) NSDate* buyReceiveDeliveryDateFrom;
@property (nonatomic) NSDate* buyReceiveDeliveryDateTo;
@property (nonatomic, strong) Location* buyReceiveDeliveryLocation;

@property (nonatomic, strong) NSArray *wishlists;

@property (nonatomic) ProductLanguage pLanguage;
@property (nonatomic, strong) NSArray* availableLanguags;
@property (nonatomic, strong) NSString *languageTitle;

@property (nonatomic) ProductType pType;
@property (nonatomic, strong) NSArray* availableTypes;
@property (nonatomic, strong) NSArray* availableFilterTypes;
@property (nonatomic, strong) NSString *typeTitle;

@property (nonatomic, strong) NSArray* availableAccessTypes;
@property (nonatomic) ProductAccessType accessType;
@property (nonatomic, readonly) NSString *accessTypeTitle;
@property (nonatomic) BOOL isCurrent;
@property (nonatomic) BOOL isPurchased;
@property (nonatomic) int visibility;
@property (nonatomic) int status;
+(instancetype)productWithDict:(NSDictionary *)dict;
@end
