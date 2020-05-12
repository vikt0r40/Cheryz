//
//  MessageParent.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/17/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "MessageParent.h"

@implementation MessageParent
+(instancetype)messageParentFromDict:(NSDictionary *)dict {
    MessageParent* parent = [MessageParent new];
    
    if(dict[@"type"] && [dict[@"type"] isKindOfClass:[NSNumber class]]) {
        parent.type = [dict[@"type"] integerValue];
    }
    else {
        return nil;
    }
    
    if(dict[@"object_id"] && [dict[@"object_id"] isKindOfClass:[NSString class]]) {
        parent.objectID = dict[@"object_id"];
    }
    else {
        return nil;
    }
    return parent;
}
-(NSString *)title{
    switch (self.type) {
        case MessageParentTypeOfTour:
            return NSLocalizedString(@"Open Tour", nil);
            break;
        case MessageParentTypeOfOrder:
            return NSLocalizedString(@"Open Order", nil);
            break;
        case MessageParentTypeOfBid:
            return NSLocalizedString(@"Open Bid", nil);
            break;
            
        default:
            break;
    }
    
    return nil;
}
@end
