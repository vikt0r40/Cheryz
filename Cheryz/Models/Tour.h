//
//  Tour.h
//  Cheryz-iOS
//
//  Created by Viktor on 10/7/16.
//  Copyright © 2016 Viktor. All rights reserved.
//
#define TimeStamp [[NSDate date] timeIntervalSince1970] * 1000

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Location.h"
#import "Currency.h"
#import "Price.h"
#import "CHDuration.h"

typedef enum : NSInteger {
    TourTypeNotSpecified = -1,
    TourTypeFashion = 0,
    TourTypeFootwear,
    TourTypeFood,
    TourTypeAntique,
    TourTypeGifts,
    TourTypeElectronics,
    TourTypeForKids,
    TourTypeJewellery,
    TourTypeCosmetics
} TourType;

typedef enum : NSInteger {
    TourLanguageNotSpecified=-1,
    TourLanguageEnglish = 0,
    TourLanguageRussian,
    TourLanguageGerman,
    TourLanguageFrench,
    TourLanguageSpanish,
    TourLanguageChinese,
    TourLanguageItalian
} TourLanguage;

typedef enum : NSUInteger {
    TourStatusNotSpecified = -1,
    TourStatusDefault = 0,
    TourStatusBroadcast,
    TourStatusLive,
    TourStatusFinishInProgress,
    TourStatusFinish,
    TourStatusDeleted
} TourStatus;

typedef enum : NSUInteger {
    TourAccessTypeAll = 0,
    TourAccessTypeForFriends,
    TourAccessTypeOnlyForMe,
    TourAccessTypeSpecificUsers
} TourAccessType;

typedef enum : NSUInteger {
    TourSortNotSelected = -1,
    TourSortTypeAll = 0,
    TourSortTypeInProgress,
    TourSortTypeUpcoming,
    TourSortTypeCompleted
} TourSortType;


@interface Tour : NSObject

@property (nonatomic, strong) NSString* titleText;
@property (nonatomic, strong) NSString* descriptionText;
@property (nonatomic, strong) Price* price;
@property (nonatomic, strong) CHDuration* duration;
@property (nonatomic, strong) NSString *additionalInfoURL;

@property (nonatomic) TourLanguage language;
@property (nonatomic, strong) NSArray* availableLanguags;
@property (nonatomic, strong) NSString *languageTitle;

@property (nonatomic) TourType type;
@property (nonatomic, strong) NSArray* availableTypes;
@property (nonatomic, strong) NSString *typeTitle;
@property (nonatomic, strong) NSArray* availableTypeImages;

@property (nonatomic, strong) NSArray* availableFilterTypes;
@property (nonatomic, strong) NSArray* availableFilterTypeImages;
@property (nonatomic, strong) NSArray* availableFilterLanguages;

@property (nonatomic) TourStatus status;

@property (nonatomic, strong) NSArray* availableAccessTypes;
@property (nonatomic) TourAccessType accessType;
@property (nonatomic, readonly) NSString *accessTypeTitle;
@property (nonatomic, strong) NSArray* specifiedUsersWithAccess;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, readonly) NSString *dateFormatted;

@property (nonatomic, strong) Location* location;
@property (nonatomic, strong) Location* deliveryLocation;

@property (nonatomic, strong) NSDate *deliveryDateFrom;
@property (nonatomic, readonly) NSString *deliveryDateFromFormatted;

@property (nonatomic, strong) NSDate *deliveryDateTo;
@property (nonatomic, readonly) NSString *deliveryDateToFormatted;

@property (nonatomic, strong) NSNumber *minBuyersCount;
@property (nonatomic, strong) NSNumber *maxBuyersCount;

@property (nonatomic, readonly) BOOL canCreate;
@property (nonatomic, strong) NSString *messageGroupID;
@property (nonatomic, strong) NSString *ownerID;
@property (nonatomic, strong) NSArray *imagesURLArray;
@property (nonatomic, strong) NSString *guid;

@property (nonatomic) NSDictionary* owner;
@property (nonatomic) NSArray* products;

@property (nonatomic, strong) NSString* photoPreviewUrl;
@property (nonatomic, strong) NSDictionary *config;
@property (nonatomic, strong) NSString* videoURL;
@property (nonatomic) int countAlert;
@property (nonatomic, strong) Currency* tourCurrency;
@property (nonatomic, strong) NSString* accessLevel;
@property (nonatomic, strong) NSArray* availableAccessTypesImages;
+(UIImage*)getTourCategoryImageWithType:(TourType)type;
+(instancetype)tourWithDict:(NSDictionary*)obj;
@end
