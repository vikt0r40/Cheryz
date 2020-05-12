//
//  CHVideoPlayer.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/28/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "WebSocketVideoPlayer.h"
#import <AFNetworking.h>
typedef enum : NSUInteger {
    CHVideoPlayerTypeHLS,
    CHVideoPlayerTypeWSS
} CHVideoPlayerType;

@interface CHVideoPlayer (){
    NSTimer *playTimer;
    BOOL waitForPlaying;
}
@property (nonatomic) CHVideoPlayerType type;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) WebSocketVideoPlayer *wssPlayer;
@end

@implementation CHVideoPlayer

-(instancetype) initWithURL:(NSURL *)url{
    self = [super init];
    
    if(!self){
        return nil;
    }
    
    if([[url.scheme lowercaseString] isEqualToString:@"wss"]){
        self.type = CHVideoPlayerTypeWSS;
        self.wssPlayer = [[WebSocketVideoPlayer alloc] initWithURL:url.absoluteString];
    }else if([[url.scheme lowercaseString] isEqualToString:@"https"]){
        self.type = CHVideoPlayerTypeHLS;
        waitForPlaying = NO;
        //self.avPlayer = [AVPlayer playerWithURL:url];
    }
    
    self.url = url;
    
    return self;
}
-(void)setView:(UIView *)view{
    _view = view;
    
    switch (self.type) {
        case CHVideoPlayerTypeHLS:{
            
        } break;
            
        case CHVideoPlayerTypeWSS:{
            self.wssPlayer.view = _view;
        } break;
    }
    
}

-(void)playVideoHLS{
    if(!waitForPlaying) return;
    self.avPlayer = [AVPlayer playerWithURL:self.url];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    playerLayer.frame = _view.bounds;
    
    [[_view.layer sublayers] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    
    [_view.layer addSublayer:playerLayer];
    [self.avPlayer play];
}
-(void)waitForPlaylist{
    NSLog(@"Check playlist");
    __weak CHVideoPlayer *weakSelf = self;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager GET:[self.url absoluteString] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Have playlist");
        [weakSelf playVideoHLS];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"No playlist");
        if(waitForPlaying){
            playTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:weakSelf selector:@selector(waitForPlaylist) userInfo:nil repeats:NO];
        }
    }];
}
-(void)play{
    switch (self.type) {
        case CHVideoPlayerTypeHLS:{
            waitForPlaying = YES;
            [self waitForPlaylist];
            
        } break;
            
        case CHVideoPlayerTypeWSS:{
            [self.wssPlayer startPlaying];
        } break;
    }
}
-(void)setGetImage:(void (^)(UIImage *))getImage{
    _getImage = getImage;
    self.wssPlayer.getImage = getImage;
}
-(void)stop{
    switch (self.type) {
        case CHVideoPlayerTypeHLS:{
            waitForPlaying = NO;
            if([playTimer isValid]){
                [playTimer invalidate];
            }
            [self.avPlayer pause];
        } break;
            
        case CHVideoPlayerTypeWSS:{
            [self.wssPlayer stopPlaying];
        } break;
    }
}

@end
