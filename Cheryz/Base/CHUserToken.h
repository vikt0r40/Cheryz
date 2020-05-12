//
//  UserToken.h
//  Cheryz-iOS
//
//  Created by Viktor on 10/7/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHUserToken : NSObject
+(id)sharedInstance;
-(NSString*)getAccessToken;
-(NSString*)getUserID;
-(NSString*)getUserFullName;
-(BOOL)isAgent;
-(void)storeAccessToken:(NSString *)token forUserID:(NSString*)userID isAgent:(BOOL)isAgent;
-(void)forgetAccessToken;
-(void)storeUserFullName:(NSString*)name;
@end
