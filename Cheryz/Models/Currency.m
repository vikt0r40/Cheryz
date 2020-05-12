//
//  Currency.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 1/26/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "Currency.h"

@implementation Currency

+(instancetype)currencyWithID:(NSString *)currencyID{
    NSDictionary *allCurrencyDict = [self allCurrencyDictionary];
    if(allCurrencyDict[currencyID]){
        Currency *currency = [Currency new];
        currency.currencyID = currencyID;
        currency.shortName = allCurrencyDict[currencyID];
        return currency;
    }
    return nil;
    
}
+(NSDictionary *)allCurrencyDictionary{
    return @{
          @"usd":@"USD",
          @"uah":@"UAH",
          @"eur":@"EUR",
          @"rub":@"RUB",
          @"cny":@"CNY"
          };
}
+(NSArray *)allCurrencyArray{
    return @[
             @"USD",
             @"UAH",
             @"EUR",
             @"RUB",
             @"CNY"
             ];
}

-(NSString *)symbol{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:self.shortName];
    NSString *currencySymbol = [NSString stringWithFormat:@"%@",[locale displayNameForKey:NSLocaleCurrencySymbol value:self.shortName]];
    
    return currencySymbol;
}

-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[Currency class]]){
        
        Currency *currencyToCompare = object;
        
        if([self.currencyID isEqualToString:currencyToCompare.currencyID]){
            return YES;
        }
    }
    
    return NO;
    
}
@end
