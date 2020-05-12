//
//  CHAPIResponse.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/11/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHAPIResponse.h"

@implementation CHAPIResponse
+(instancetype) apiResponseWithTask:(NSURLSessionDataTask *) task andResponseObject: (id) responseObject{
    
    CHAPIResponse *response = [[CHAPIResponse alloc] init];
    
    if([task.response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        response.code = httpResponse.statusCode;
    }else{
        response.code = -1;
    }
    
    if(!responseObject){
        response.body = nil;
        return response;
    }
    
    if([responseObject isKindOfClass:[NSDictionary class]]) {
        response.body = responseObject;
    }else if([responseObject isKindOfClass:[NSArray class]]){
        response.body = responseObject;
    } else {
        NSError *error;
        response.body = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if(error){
            response.body = nil;
        }
    }
    
    return response;
}
@end
