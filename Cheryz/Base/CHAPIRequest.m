//
//  CHAPIRequest.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/11/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHAPIRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "SessionSettings.h"

@interface CHAPIRequest ()
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, copy) void(^success)(id);
@property (nonatomic, copy) void(^failure)(NSError*);
@end

@implementation CHAPIRequest

+ (instancetype)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

+ (void)GET:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure{
    
    [CHAPIRequest sharedInstance].dataTask = [[self manager] GET:[self apiURLAppendWithPath:path]
                                                       parameters:params
                                                         progress:nil
                                                          success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
                                                              success([CHAPIResponse apiResponseWithTask:task andResponseObject:responseObject]);
                                                              
                                                          }
                                                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                              failure(error);
                                                          }];
}
+ (void)POST:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure{
    [CHAPIRequest sharedInstance].dataTask = [[self manager] POST:[self apiURLAppendWithPath:path]
                                                        parameters:params
                                                          progress:nil
                                                           success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
                                                               success([CHAPIResponse apiResponseWithTask:task andResponseObject:responseObject]);
                                                           }
                                                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                               failure(error);
                                                           }];
}
+ (void)DELETE:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure{
    [CHAPIRequest sharedInstance].dataTask = [[self manager] DELETE:[self apiURLAppendWithPath:path]
                                                          parameters:params
                                                             success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
                                                                 success([CHAPIResponse apiResponseWithTask:task andResponseObject:responseObject]);
                                                             }
                                                             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                 failure(error);
                                                             }];
}
+ (void)PUT:(NSString*)path params:(NSDictionary*)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure{
    [CHAPIRequest sharedInstance].dataTask = [[self manager] PUT:[self apiURLAppendWithPath:path]
                                                       parameters:params
                                                          success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
                                                              success([CHAPIResponse apiResponseWithTask:task andResponseObject:responseObject]);
                                                          }
                                                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                              failure(error);
                                                          }];
}
+ (void)PUT:(NSString*)path data:(NSData*)data filename:(NSString*)filename params:(NSDictionary *)params success:(void (^)(CHAPIResponse *response))success failure:(void (^)(NSError *error))failure {
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"PUT" URLString:[self apiURLAppendWithPath:path] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(filename && data){
            [formData appendPartWithFileData:data name:@"file" fileName:filename mimeType:@"image/jpg"];
        }
    } error:nil];
    
    AFURLSessionManager *manager = [self manager];
    
    NSString *token = [[CHUserToken sharedInstance] getAccessToken];
    [request setValue:token forHTTPHeaderField:@"Authorization"];

    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          //[progressView setProgress:uploadProgress.fractionCompleted];
                          NSLog(@"Progress %f",uploadProgress.fractionCompleted);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          failure(error);
                      } else {
                          success([CHAPIResponse apiResponseWithTask:uploadTask andResponseObject:responseObject]);
                      }
                  }];
    
    [uploadTask resume];
}
+ (AFHTTPSessionManager *)manager{
    NSString *token = [[CHUserToken sharedInstance] getAccessToken];
    
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
//    return manager;
    
    manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    if(token){
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    NSString *currencyID = [SessionSettings defaultSettings].currency.currencyID;
    [manager.requestSerializer setValue:currencyID forHTTPHeaderField:@"X-Currency"];
    
    return manager;
}
+ (NSString *)apiURLAppendWithPath:(NSString*)path{
    NSString *url = [NSString stringWithFormat:@"%@/%@",API_URL,path];
    return url;
}
+ (void)cancel {
    if([CHAPIRequest sharedInstance].dataTask){
        [[CHAPIRequest sharedInstance].dataTask cancel];
    }
}
+ (NSInteger)httpStatusCodeFromError:(NSError*)error{
    return [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
}
@end
