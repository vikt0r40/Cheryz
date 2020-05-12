//
//  InfoRequest.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/4/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface InfoRequest : NSObject
@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) CGPoint point;
@end
