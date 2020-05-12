//
//  ShareFacebook.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/12/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FBSDKShareKit/FBSDKShareKit.h>
@interface ShareFacebook : NSObject
+(void)shareToTimeLineWithLink:(NSString*)link controller:(id)controller;
+(void)sendToMessengerWithLink:(NSString*)link;
+(void)shareTourToFacebook:(id)controller link:(NSString*)link;
+(void)shareProductToFacebook:(id)controller link:(NSString*)link;
@end
