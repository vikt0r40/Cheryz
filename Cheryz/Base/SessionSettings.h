//
//  SessionSettings.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 1/26/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

@interface SessionSettings : NSObject
+(instancetype)defaultSettings;
@property (nonatomic, strong) NSString *wssSessionID;
@property (nonatomic, strong) Currency *currency;
@end
