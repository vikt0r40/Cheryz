//
//  UserToken.m
//  Cheryz-iOS
//
//  Created by Viktor on 10/7/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHUserToken.h"
@implementation CHUserToken
+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}
-(NSString*)getAccessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_TOKEN"];
}
-(NSString*)getUserID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"];
}
-(BOOL)isAgent{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_AGENT"];
}
-(void)forgetAccessToken{
    NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"USER_TOKEN"];
    [userDefaults setObject:nil forKey:@"USER_ID"];
    [userDefaults removeObjectForKey:@"IS_AGENT"];
    [userDefaults synchronize];
}
-(void)storeAccessToken:(NSString *)token forUserID:(NSString*)userID isAgent:(BOOL)isAgent{
    NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:@"USER_TOKEN"];
    [userDefaults setObject:userID forKey:@"USER_ID"];
    [userDefaults setBool:isAgent forKey:@"IS_AGENT"];
    [userDefaults synchronize];
}
-(void)storeUserFullName:(NSString*)name {
    NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:name forKey:@"USER_FULLNAME"];
    [userDefaults synchronize];
}
-(NSString *)getUserFullName{
    NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
    NSString *fullname = [userDefaults objectForKey:@"USER_FULLNAME"];
    return fullname;
}
@end
