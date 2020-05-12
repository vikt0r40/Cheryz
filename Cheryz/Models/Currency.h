//
//  Currency.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 1/26/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject
@property (nonatomic, strong) NSString *currencyID;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, readonly) NSString *symbol;
+(instancetype)currencyWithID:(NSString *)currencyID;
+(NSDictionary *)allCurrencyDictionary;
+(NSArray *)allCurrencyArray;

@end
