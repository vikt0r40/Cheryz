//
//  Location.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/21/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject
+(instancetype)locationForCountry:(NSString *)country region:(NSString *)region city:(NSString *)city placeName:(NSString *)placeName placeID:(NSString *)placeID latitude:(double)lat longitude:(double)lng;
+(instancetype)locationFromDictionary:(NSDictionary*)dict;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, readonly) NSString *formattedAddress;
@property (nonatomic) CLLocationCoordinate2D coordinates;
@end
