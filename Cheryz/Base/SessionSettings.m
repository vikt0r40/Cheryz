//
//  SessionSettings.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 1/26/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "SessionSettings.h"
/*
 
 +(instancetype)defaultSettings;
 @property (nonatomic, strong, readonly) NSString *wssPreviousSessionID;
 @property (nonatomic, strong) NSString *wssSessionID;
 @property (nonatomic, strong) Currency *currency;
 
 */

@implementation SessionSettings

+(instancetype)defaultSettings{
    
        // structure used to test whether the block has completed or not
        static dispatch_once_t p = 0;
    
        // initialize sharedObject as nil (first call only)
        __strong static SessionSettings * _sharedObject = nil;
    
        // executes a block object once and only once for the lifetime of an application
        dispatch_once(&p, ^{
            _sharedObject = [[self alloc] init];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if([userDefaults objectForKey:@"wssSessionID"]){
                _sharedObject->_wssSessionID = [userDefaults objectForKey:@"wssSessionID"];
            }
            
            if([userDefaults objectForKey:@"currencyID"]){
                _sharedObject->_currency = [Currency currencyWithID:[userDefaults objectForKey:@"currencyID"]];
            }else{
            
            }
        });
    
        // returns the same object each time
        return _sharedObject;
}

-(void)setWssSessionID:(NSString *)wssSessionID{
    _wssSessionID = wssSessionID;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:wssSessionID forKey:@"wssSessionID"];
    [userDefaults synchronize];
}

-(void)setCurrency:(Currency *)currency{
    _currency = currency;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currency.currencyID forKey:@"currencyID"];
    [userDefaults synchronize];
}

@end
