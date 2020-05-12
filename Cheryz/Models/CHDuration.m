//
//  CHDuration.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11.04.2020.
//  Copyright © 2020 Cheryz. All rights reserved.
//

#import "CHDuration.h"

@implementation CHDuration
+(CHDuration *)durationWithSeconds:(int)seconds{
    CHDuration *duration = [CHDuration new];
    duration.seconds = seconds;
    return duration;
}
-(NSString *)formated{
    NSUInteger h = _seconds / 3600;
    NSUInteger m = (_seconds / 60) % 60;
    
    NSString *result=@"";
    
    if(h>0){
        NSString *f = (h==1)?@"%lu hour":@"%lu hours";
        result = [result stringByAppendingFormat:f, h];
    }else if(m>0){
        NSString *f = (m==1)?@"%lu minute":@"%lu minutes";
        result = [result stringByAppendingFormat:f, m];
    }
    
    return result;
}
@end
