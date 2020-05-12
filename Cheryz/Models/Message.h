//
//  Message.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/1/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@interface Message : NSObject
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) NSDate* createDate;
@property (nonatomic, strong) NSString* messageID;
@property (nonatomic, strong) NSString* messageText;
@property (nonatomic, strong) NSString* messageImageUrl;
@property (nonatomic) int messageType;
+(instancetype)messageFromDictionary:(NSDictionary*)dictionary;
@end
