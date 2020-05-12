//
//  MessageParent.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/17/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MessageParentTypeNotSpecified = -1,
    MessageParentTypeOfTour = 0,
    MessageParentTypeOfOrder = 4,
    MessageParentTypeOfBid,
} MessageParentType;

@interface MessageParent : NSObject
@property (nonatomic) MessageParentType type;
@property (nonatomic, strong) NSString* objectID;
@property (readonly, nonatomic) NSString* title;
+(instancetype)messageParentFromDict:(NSDictionary*)dict;
@end
