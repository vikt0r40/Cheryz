//
//  SipSettings.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/8/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SipSettings : NSObject

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSNumber *port;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *pass;
@property (nonatomic, strong) NSString *tourID;
+(instancetype)settingsFromDictionary: (NSDictionary *)dictionary;


@end
