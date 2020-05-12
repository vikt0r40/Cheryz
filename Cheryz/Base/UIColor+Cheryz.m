//
//  UIColor+Cheryz.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/2/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "UIColor+Cheryz.h"

@implementation UIColor (Cheryz)
+(instancetype)cheryzRed {
//    return [UIColor colorWithRed:239./255. green:76./255. blue:90./255. alpha:1];
    return [UIColor cheryzBlue];
}
+(instancetype)cheryzGray {
    return [UIColor colorWithRed:124./255. green:124./255. blue:124./255. alpha:1];
}
+(instancetype)cheryzDarkGray {
    return [UIColor colorWithRed:56./255. green:57./255. blue:56./255. alpha:1];
}
+(instancetype)cheryzBlue {
    return [UIColor colorWithRed:76./255. green:149./255. blue:239./255. alpha:1];
}
+(instancetype)mapPinRed {
   return [UIColor colorWithRed:239./255. green:76./255. blue:90./255. alpha:1];
}
@end
