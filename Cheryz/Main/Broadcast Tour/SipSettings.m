//
//  SipSettings.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/8/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "SipSettings.h"

@implementation SipSettings

+(instancetype)settingsFromDictionary: (NSDictionary *)dictionary{
    SipSettings *settings = [[SipSettings alloc] init];
    settings.domain = dictionary[@"sip_realm"];//dictionary[@"sip_domain"];
    settings.port = @([dictionary[@"sip_port"] integerValue]);
    settings.realm = dictionary[@"sip_realm"];
    settings.user = dictionary[@"sip_user"];
    settings.pass = dictionary[@"sip_pass"];
//    settings.pass = [dictionary[@"sip_pass"] stringByAppendingString:@"asd"];
    settings.tourID = dictionary[@"sip_tour_id"];
    
    return settings;
}

@end
