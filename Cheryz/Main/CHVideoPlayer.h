//
//  CHVideoPlayer.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CHVideoPlayer : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) BOOL isPlaying;

-(instancetype) initWithURL:(NSURL *)url;
-(void)play;
-(void)stop;

@property (nonatomic, copy) void (^getImage)(UIImage *image);

@end
