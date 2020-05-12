//
//  Router.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/14/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Router : NSObject
@property (nonatomic, strong) UINavigationController *navigationController;

-(UIViewController*)viewControllerWithClass:(Class)class;
-(void)viewControllerWithClass:(Class)class controllerHandler:(void(^)(id viewController)) viewControllerHandler;
-(instancetype)initWithNavigationController:(UINavigationController *)navigationController;
-(UIViewController*)viewControllerWithClass:(Class)class fromStoryboardWithName:(NSString *)name;
-(void)viewControllerWithClass:(Class)class fromStoryboardWithName:(NSString *)name controllerHandler:(void(^)(id viewController)) viewControllerHandler;

@end
