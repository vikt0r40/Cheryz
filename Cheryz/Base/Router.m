//
//  Router.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/14/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Router.h"

@interface Router()
@property (nonatomic, strong)  UIStoryboard *mainStoryboard;
@end

@implementation Router

-(instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if(!self)
        return nil;
    
    self.navigationController = navigationController;
    return self;
}
-(UIStoryboard *)mainStoryboard{
    if(!_mainStoryboard){
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    return _mainStoryboard;
}
-(id)viewControllerWithClass:(Class)class {
    return [self.mainStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass(class)];
} 
-(void)viewControllerWithClass:(Class)class controllerHandler:(void(^)(id viewController)) viewControllerHandler {
    
    [self viewControllerWithClass:class fromStoryboardWithName:@"Main" controllerHandler:viewControllerHandler];
}
-(BOOL)isAutorizationRequiredForViewControllerWithClass:(Class)class{
    SEL selector = NSSelectorFromString(@"isAuthorizationRequired");
    if ([class respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [class methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:class];
        [invocation invoke];
        BOOL returnValue;
        [invocation getReturnValue:&returnValue];
        NSLog(@"Returned %d", returnValue);
        return returnValue;
    }
    return NO;
}
-(UIViewController*)viewControllerWithClass:(Class)class fromStoryboardWithName:(NSString *)name{
    NSBundle* bundle = [NSBundle bundleForClass:class];
    return [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:bundle] instantiateViewControllerWithIdentifier:NSStringFromClass(class)];
}
-(void)viewControllerWithClass:(Class)class fromStoryboardWithName:(NSString *)name controllerHandler:(void(^)(id viewController)) viewControllerHandler {
//    if([self isAutorizationRequiredForViewControllerWithClass:class]&&![[Authorization manager] authorized]){
//        AuthorizationController* authController = (AuthorizationController*)[self viewControllerWithClass:[AuthorizationController class] fromStoryboardWithName:@"Authorization"];
//        authController.completionHandler = (^(BOOL isAuthorized){
//            if(isAuthorized) {
//                viewControllerHandler([self viewControllerWithClass:class fromStoryboardWithName:name]);
//            }
//        });
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authController];
//        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
//    }else{
//        viewControllerHandler([self viewControllerWithClass:class fromStoryboardWithName:name]);
//    }
}
@end
