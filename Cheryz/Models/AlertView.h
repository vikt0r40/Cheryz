//
//  AlertView.h
//  Cheryz-iOS
//
//  Created by Viktor on 10/6/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertView : NSObject
//+ (id)sharedInstance;
+ (void) showAlertViewWithTitle:(NSString*)title message:(NSString*)message controller:(UIViewController*)controller;
@end
