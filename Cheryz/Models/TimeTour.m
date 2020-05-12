//
//  TimeTour.m
//  CheryzSDK
//
//  Created by Viktor Todorov on 7.05.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import "TimeTour.h"
#import "NSDate+Server.h"

@implementation TimeTour
+(instancetype)timeTourFromDict:(NSDictionary*)dict {
    if(!dict) {
        return nil;
    }
    
    TimeTour* tour = [TimeTour new];
    tour.tourDate = [NSDate dateFromServerFormat:[dict[@"time_tour"] doubleValue]];
    tour.timeZone = dict[@"time_zone"];
    tour.user = [User userFromDictionary:dict[@"user"]];
    
    return tour;
}
@end
