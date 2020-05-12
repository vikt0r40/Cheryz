//
//  Location.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/21/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Location.h"

@implementation Location

+(instancetype)locationForCountry:(NSString *)country region:(NSString *)region city:(NSString *)city placeName:(NSString *)placeName placeID:(NSString *)placeID latitude:(double)lat longitude:(double)lng {
    
    Location *location = [[Location alloc] init];
    
    location.country = country;
    location.region = region;
    location.city = city;
    location.placeName = placeName;
    location.placeID = placeID;
    location.coordinates = CLLocationCoordinate2DMake(lat, lng);
    
    return location;
}
+(instancetype)locationFromDictionary:(NSDictionary*)dict {
    
    Location *location = [[Location alloc] init];
    
    if(![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if([dict[@"country"] isKindOfClass:[NSString class]])
        location.country = dict[@"country"];
    
    if([dict[@"region"] isKindOfClass:[NSString class]])
        location.region = dict[@"region"];
    
    if([dict[@"city"] isKindOfClass:[NSString class]])
        location.city = dict[@"city"];
    
    if([dict[@"place_name"] isKindOfClass:[NSString class]])
        location.placeName = dict[@"place_name"];
    
    if([dict[@"place_id"] isKindOfClass:[NSString class]])
        location.placeID = dict[@"place_id"];
    if(([dict[@"lat"] isKindOfClass:[NSNumber class]]
       ||[dict[@"lat"] isKindOfClass:[NSString class]])
       &&([dict[@"lng"] isKindOfClass:[NSNumber class]]
          ||[dict[@"lng"] isKindOfClass:[NSString class]])
       ){
        location.coordinates = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lng"] doubleValue]);
    }
    return location;
}
-(NSString *)formattedAddress{
    NSMutableString *address = [[NSMutableString alloc] init];
    
    if([_country isKindOfClass:[NSString class]]){
        if(address.length>0){
            [address appendString:@", "];
        }
        [address appendString:_country];
    }
    
    if([_region isKindOfClass:[NSString class]]){
        if(address.length>0){
            [address appendString:@", "];
        }
        [address appendString:_region];
    }
    
    if([_city isKindOfClass:[NSString class]]){
        if(address.length>0){
            [address appendString:@", "];
        }
        [address appendString:_city];
    }
    
    if([_placeName isKindOfClass:[NSString class]]){
        if(address.length>0){
            [address appendString:@", "];
        }
        [address appendString:_placeName];
    }
    return address;
}
@end
