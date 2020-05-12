//
//  AlertView.m
//  Cheryz-iOS
//
//  Created by Viktor on 10/6/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView
//+ (id)sharedInstance
//{
//    // structure used to test whether the block has completed or not
//    static dispatch_once_t p = 0;
//    
//    // initialize sharedObject as nil (first call only)
//    __strong static id _sharedObject = nil;
//    
//    // executes a block object once and only once for the lifetime of an application
//    dispatch_once(&p, ^{
//        _sharedObject = [[self alloc] init];
//    });
//    
//    // returns the same object each time
//    return _sharedObject;
//}
+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message controller:(UIViewController*)controller {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    //We add buttons to the alert controller by creating UIAlertActions:
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [controller presentViewController:alertController animated:YES completion:nil];
}
@end
