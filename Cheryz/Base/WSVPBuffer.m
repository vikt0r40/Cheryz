//
//  WSVPBuffer.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/5/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "WSVPBuffer.h"
const int bufferSize = 15;
int fps = 30;
@implementation WSVPBuffer{
    CVPixelBufferRef _buffer[bufferSize];
    int writeIndex;
    int readIndex;
    NSTimer *timer;
    NSTimer *wpsTimer;
    NSLock *lock;
    dispatch_queue_t queue;
    BOOL waitingForFrame;
    int writesPerSec;
    int currentFPS;
}

-(instancetype)init{
    self = [super init];
    
    if(!self)
        return nil;
    
    for (int i=0; i<bufferSize; i++) {
        _buffer[i] = nil;
    }
    writeIndex = -1;
    readIndex = -1;
    
    writesPerSec = 0;
    currentFPS = fps;
    
    lock = [NSLock new];
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    waitingForFrame = YES;
//    timer = [NSTimer scheduledTimerWithTimeInterval:1./30. target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
    wpsTimer = [NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(wpsTimerAction) userInfo:nil repeats:YES];
    return self;
}

-(void)wpsTimerAction{
    if(writesPerSec!=0){
        fps = (int)round(writesPerSec/2.);
        
        fps = MAX(15., fps);
        fps = MIN(35., fps);

    }
    writesPerSec = 0;
    if(currentFPS!=fps){
        currentFPS = fps;
        [self reloadTimer];
    }
}

-(void)reloadTimer{
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:(1./currentFPS) target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
}

-(void)push:(CVPixelBufferRef)pixelBuffer{
    
//    [lock lock];
    
    writesPerSec++;
    
    int tmp = writeIndex;
    
    if((writeIndex+1)<bufferSize){
        writeIndex++;
    }else{
        writeIndex = 0;
    }
    
    if(writeIndex==readIndex){
        writeIndex = tmp;
//        [lock unlock];
        return;
    }
    
    if(_buffer[writeIndex]){
        CVPixelBufferRelease(_buffer[writeIndex]);
    }
    _buffer[writeIndex] = CVPixelBufferRetain(pixelBuffer);
//    [lock unlock];
    if(waitingForFrame){
        [self performSelectorOnMainThread:@selector(drawFrame) withObject:nil waitUntilDone:NO];
    }
}

-(void)drawFrame{
//    dispatch_async(queue, ^{
//        [lock lock];
    
        int tmp = readIndex;
        
        if((readIndex+1)<bufferSize){
            readIndex++;
        }else{
            readIndex = 0;
        }
        
        if(writeIndex==readIndex){
            readIndex = tmp;
            waitingForFrame = YES;
            
//            [lock unlock];

            
            return;
        }
        
        
        if(_buffer[readIndex]){
            waitingForFrame = NO;
//            [lock unlock];
            [self.delegate drawFrameLock:_buffer[readIndex]];
        }else{
            readIndex = tmp;
            waitingForFrame = YES;
//            [lock unlock];
            return;
        }
        
    
//    });
}

-(void)clean{
    
    [timer invalidate];
    timer = nil;
    [wpsTimer invalidate];
    wpsTimer = nil;
    for (int i=0; i<bufferSize; i++) {
        if(_buffer[i]){
            CVPixelBufferRelease(_buffer[i]);
        }
    }
    waitingForFrame = YES;
}
@end
