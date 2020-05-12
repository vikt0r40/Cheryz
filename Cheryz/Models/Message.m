//
//  Message.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/1/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "Message.h"
#import "User.h"

@implementation Message
+(instancetype)messageFromDictionary:(NSDictionary*)dictionary {
    Message* msg = [[Message alloc]init];
    msg.createDate = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"create_date"] doubleValue]/1000.];
    msg.user = [User userFromDictionary:dictionary[@"from_user"]];
    msg.messageID = dictionary[@"message_id"];
    msg.messageText = dictionary[@"message_text"];
    msg.messageType = (int)dictionary[@"message_type"];
    msg.messageImageUrl = dictionary[@"image"];
    return msg;
}
@end
