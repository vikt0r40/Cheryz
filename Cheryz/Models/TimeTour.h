//
//  TimeTour.h
//  CheryzSDK
//
//  Created by Viktor Todorov on 7.05.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface TimeTour : NSObject
@property (nonatomic, strong) NSDate* tourDate;
@property (nonatomic, strong) NSString* timeZone;
@property (nonatomic, strong) User* user;

+(instancetype)timeTourFromDict:(NSDictionary*)dict;
@end

