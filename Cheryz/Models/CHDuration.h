//
//  CHDuration.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11.04.2020.
//  Copyright © 2020 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHDuration : NSObject
@property (nonatomic) int seconds;
@property (nonatomic, readonly) NSString *formated;
+(CHDuration *)durationWithSeconds:(int)seconds;
@end

NS_ASSUME_NONNULL_END
