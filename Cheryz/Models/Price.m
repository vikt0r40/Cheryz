//
//  Price.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 1/30/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "Price.h"

@implementation Price

-(NSString *)formattedString{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    numberFormatter.currencyCode = self.currency.shortName;
    numberFormatter.positiveFormat = @"¤#,##0";
//    numberFormatter.currencySymbol = self.currency.shortName;
    NSString *numberAsString = [numberFormatter stringFromNumber:self.value];
    return numberAsString;
}

-(NSString *)formattedDecimalString{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.maximumFractionDigits = 2;
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    numberFormatter.usesGroupingSeparator = NO;
    NSString *numberAsString = [numberFormatter stringFromNumber:self.value];
    return numberAsString;
}

+(NSNumber *)numberFromString:(NSString *)string{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = kCFNumberFormatterDecimalStyle;
    f.usesGroupingSeparator = NO;
    NSNumber *price = [f numberFromString:string];
    return price;
}
+(NSString *)decimalStringFromNumber:(NSNumber *)number {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.maximumFractionDigits = 2;
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberAsString = [numberFormatter stringFromNumber:number];
    return numberAsString;
}
+(BOOL)isPriceValueValid:(NSString*)price {
    
    if (![self validateString:price])
    {
        return NO;
    }
    if([price doubleValue] < 0 || [price doubleValue] > 99999.99) {
        return NO;
    }
    
    return YES;
}
+(instancetype)priceFromDictionary:(NSDictionary *)dict{
    if(dict && [dict isKindOfClass:[NSDictionary class]]){
        if(
           dict[@"value"]&&[dict[@"value"] isKindOfClass:[NSNumber class]]
           &&dict[@"currency_name"]&&[dict[@"currency_name"] isKindOfClass:[NSString class]]
           ){
            Price *price = [Price new];
            price.currency = [Currency currencyWithID:dict[@"currency_name"]];
            price.value = dict[@"value"];
            return price;
        }
    }
    return nil;
}
+ (BOOL)validateString:(NSString *)string
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setMaximumFractionDigits:2];
    [f setMaximumSignificantDigits:2];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *price = [f numberFromString:string];
    if(!price){
        return NO;
    }
    return YES;
}
@end
