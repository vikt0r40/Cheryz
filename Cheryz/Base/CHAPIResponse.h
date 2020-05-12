//
//  CHAPIResponse.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/11/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHAPIResponse : NSObject
@property (nonatomic) NSInteger code;
@property (nonatomic) id body;
+(instancetype) apiResponseWithTask:(NSURLSessionDataTask *) task andResponseObject: (id) responseObject;
@end
