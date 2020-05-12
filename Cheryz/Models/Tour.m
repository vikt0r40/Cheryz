//
//  Tour.m
//  Cheryz-iOS
//
//  Created by Viktor on 10/7/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Tour.h"
#import "NSDate+Server.h"

@implementation Tour

-(instancetype)init{
    self = [super init];
    if(!self) return nil;
    
    self.availableTypes = @[@"Fashion", @"Footwear", @"Food", @"Antique", @"Gifts", @"Electronics", @"For kids", @"Jewellery", @"Cosmetics"];
    self.availableTypeImages = @[@"fashion",@"Footwear",@"food",@"antique",@"gift",@"el",@"kid",@"jew",@"cos"];
    
    self.availableLanguags = @[@"English", @"Russian", @"German", @"French", @"Spanish", @"Chinese", @"Italian"];
    
    self.availableFilterTypes = @[@"Not specified", @"Fashion", @"Footwear", @"Food", @"Antique", @"Gifts", @"Electronics", @"For kids", @"Jewellery", @"Cosmetics"];
    
    self.availableFilterTypeImages = @[@"",@"fashion",@"Footwear",@"food",@"antique",@"gift",@"el",@"kid",@"jew",@"cos"];
    
    self.availableFilterLanguages = @[@"Not specified", @"English", @"Russian", @"German", @"French", @"Spanish", @"Chinese", @"Italian"];
    
    self.availableAccessTypes = @[@"Everyone", @"Only friends", @"Private", @"Specific users"];
    self.availableAccessTypesImages = @[@"public",@"friends",@"lockicon",@"specifyuser"];
    
    
    self.language = TourLanguageNotSpecified;
    self.type = TourTypeNotSpecified;
    self.status = TourStatusNotSpecified;
    self.accessType = TourAccessTypeAll;
    
    return self;
}
-(NSString *)languageTitle{
    if(self.language != TourLanguageNotSpecified)
        return self.availableLanguags[self.language];
    else
        return @"Not specified";
}
-(NSString *)typeTitle{
    if(self.type != TourTypeNotSpecified)
        return self.availableTypes[self.type];
    else
        return @"Not specified";
}
-(NSString *)accessTypeTitle{
    return self.availableAccessTypes[self.accessType];
}
-(NSString *)dateFormatted{
    if(self.date){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        return [formatter stringFromDate:self.date];
    }
    return @"Not specified";
}
-(NSString *)deliveryDateFromFormatted{
    if(self.deliveryDateFrom){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        
        return [formatter stringFromDate:self.deliveryDateFrom];
    }
    return @"Not specified";
}
-(NSString *)deliveryDateToFormatted{
    if(self.deliveryDateTo){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        
        return [formatter stringFromDate:self.deliveryDateTo];
    }
    return @"Not specified";
}
-(BOOL)canCreate{
    BOOL result = YES;
    result &= self.language != TourLanguageNotSpecified;
//    result &= self.type != TourTypeNotSpecified;
    result &= self.titleText.length > 0;
    result &= self.location != nil;
    result &= self.date!=nil;
    return result;
}
//-(NSString *)formattedPlacename{
//    NSMutableString *address = [[NSMutableString alloc] init];
//    if([_placename isKindOfClass:[NSString class]]){
//        [address appendString:_placename];
//    }
//    if([_city isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_city];
//    }
//    if([_region isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_region];
//    }
//    if([_country isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
//        [address appendString:_country];
//    }
//    return address;
//}
//-(NSString *)formattedDeliveryPlacename{
//    NSMutableString *address = [[NSMutableString alloc] init];
//    if([_deliveryPlacename isKindOfClass:[NSString class]]){
//        [address appendString:_deliveryPlacename];
//    }
//    if([_deliveryCity isKindOfClass:[NSString class]]){
//        if(address.length>0){
//            [address appendString:@", "];
//        }
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
//}
+(UIImage*)getTourCategoryImageWithType:(TourType)type {
    switch (type) {
        case TourTypeFood:
            return [UIImage imageNamed:@"food"];
            break;
        case TourTypeGifts:
            return [UIImage imageNamed:@"gift"];
            break;
        case TourTypeAntique:
            return [UIImage imageNamed:@"antique"];
            break;
        case TourTypeFashion:
            return [UIImage imageNamed:@"fashion"];
            break;
        case TourTypeFootwear:
            return [UIImage imageNamed:@"Footwear"];
            break;
        case TourTypeForKids:
            return [UIImage imageNamed:@"kid"];
            break;
        case TourTypeCosmetics:
            return [UIImage imageNamed:@"cos"];
            break;
        case TourTypeJewellery:
            return [UIImage imageNamed:@"jew"];
            break;
        case TourTypeElectronics:
            return [UIImage imageNamed:@"el"];
            break;
        default:
            return [UIImage imageNamed:@""];
            break;
    }

}
+(instancetype)tourWithDict:(NSDictionary *)obj {
    Tour *tour = [Tour new];
    tour.titleText = obj[@"title"];
    tour.date = [NSDate dateFromServerFormat:[obj[@"tour_date"] doubleValue]];
    tour.maxBuyersCount = obj[@"max_buyer_count"];
    tour.minBuyersCount = obj[@"min_buyer_count"];
    tour.languageTitle = obj[@"language"];
    tour.deliveryDateTo = [NSDate dateFromServerFormat:[obj[@"delivery_date_to"] doubleValue]];
    tour.deliveryDateFrom = [NSDate dateFromServerFormat:[obj[@"delivery_date_from"] doubleValue]];
    tour.descriptionText = obj[@"description"];
    tour.countAlert = [obj[@"count_alert"] intValue];
    tour.location = [Location locationFromDictionary:obj[@"location"]];
    tour.deliveryLocation = [Location locationFromDictionary:obj[@"delivery_location"]];
    tour.messageGroupID = obj[@"msg_group_uid"];
    tour.ownerID = obj[@"owner"][@"owner_id"];
    tour.guid = obj[@"tour_id"];
    tour.status = [obj[@"status"] intValue];
    tour.accessType = [obj[@"access_type"] intValue];
    
    tour.type = [[obj objectForKey:@"tour_type"] integerValue];
    tour.owner = [obj objectForKey:@"owner"];

    tour.products = [obj objectForKey:@"product"];
    tour.photoPreviewUrl = [obj objectForKey:@"photo_preview"];
    
    tour.additionalInfoURL = [obj objectForKey:@"url"];
    if([obj objectForKey:@"duration"]){
        tour.duration = [CHDuration durationWithSeconds:[[obj objectForKey:@"duration"] intValue]];
    }
    if([obj objectForKey:@"price"]){
        tour.price = [Price new];
        tour.price.value = [obj objectForKey:@"price"][@"sum"];
        tour.price.currency = [Currency currencyWithID:[obj objectForKey:@"price"][@"currency"]];
    }
    NSString *currencyID = @"usd";
    
    if(obj[@"tour_currency_name"]&&[obj[@"tour_currency_name"] isKindOfClass:[NSString class]]){
        currencyID = obj[@"tour_currency_name"];
    }
    
    tour.tourCurrency = [Currency currencyWithID:currencyID];
    
    if(obj[@"images"]&&[obj[@"images"] isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [NSMutableArray new];
        [obj[@"images"] enumerateObjectsUsingBlock:^(NSString * _Nonnull imagePath, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:[NSURL URLWithString:imagePath]];
        }];
        tour.imagesURLArray = [array copy];
    }

    return tour;
}
@end
