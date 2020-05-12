//
//  User.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/18/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "User.h"

@implementation User

+(instancetype)userWithID:(NSString *)userID firstName:(NSString *)firstName lastName:(NSString *)lastName photoPath:(NSString *)photoPath{
    User *user = [[User alloc] init];
    user.firstName = firstName;
    user.lastName = lastName;
    user.userID = userID;
    if([photoPath isKindOfClass:[NSString class]]) {
        user.imageURL = [NSURL URLWithString: photoPath];
    }
    return user;
}

+(instancetype)userFromDictionary:(NSDictionary *)dictionary {
    User *user = [[User alloc] init];
    user.firstName = dictionary[@"first_name"];
    user.lastName = dictionary[@"last_name"];
    user.userID = dictionary[@"user_id"];
    if(dictionary[@"photo"] != [NSNull null]) {
        user.imageURL = [NSURL URLWithString:dictionary[@"photo"]];
    }
    
    return user;
}
-(NSURL *)userImageURLWithSize:(CGSize)size{
    NSString *string = [self.imageURL absoluteString];
    NSString *stringWithParams = [NSString stringWithFormat:@"%@?w=%d&h=%d",string,(int)size.width, (int)size.height];
    NSURL *sizedImageURL = [NSURL URLWithString:stringWithParams];
    return sizedImageURL;
}
-(NSString *)fullName{
    return [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
}
@end
