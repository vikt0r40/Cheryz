//
//  Price.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 1/30/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

@interface Price : NSObject

@property (nonatomic, strong) Currency *currency;
@property (nonatomic, strong) NSNumber *value;

@property (nonatomic, readonly) NSString *formattedString;
@property (nonatomic, readonly) NSString *formattedDecimalString;

+(NSNumber *)numberFromString:(NSString *)string;
+(instancetype)priceFromDictionary:(NSDictionary *)dict;
+(NSString *)decimalStringFromNumber:(NSNumber *)number;
+(BOOL)isPriceValueValid:(NSString*)price;
@end
