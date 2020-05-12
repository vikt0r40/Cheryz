//
//  User.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/18/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* aboutNotes;
@property (nonatomic, strong) NSURL* imageURL;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic) int currencyID;
@property (nonatomic) NSString* currencyString;
+(instancetype)userFromDictionary:(NSDictionary *)dictionary;
-(NSURL *)userImageURLWithSize:(CGSize)size;
@end
