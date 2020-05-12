//
//  WebSocketVideoPlayer.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/10/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WebSocketVideoPlayerDelegate <NSObject>

-(void)webSocketVideoPlayerStartPlaying;
-(void)webSocketVideoPlayerEndPlaying;
-(void)webSocketVideoPlayerError:(NSError *)error;

@end

@interface WebSocketVideoPlayer : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, weak) id<WebSocketVideoPlayerDelegate> delegate;
@property (nonatomic, copy) void (^getImage)(UIImage *image);
-(instancetype)initWithURL:(NSString*)url;
-(void)startPlaying;
-(void)stopPlaying;

@end
