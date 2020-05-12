//
//  BuyRequest.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/29/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuyRequest : NSObject
@property (nonatomic, strong) NSString* imageURL;
@property (nonatomic) int quantity;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* requestID;
@property (nonatomic, strong) NSString* tourID;
@property (nonatomic, strong) NSString* productID;
@property (nonatomic, strong) NSString* username;
@end
