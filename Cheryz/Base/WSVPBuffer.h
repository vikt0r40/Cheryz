//
//  WSVPBuffer.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/5/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>

@protocol WSVPBufferProtocol <NSObject>
-(void)drawFrameLock:(CVPixelBufferRef)pixelBuffer;
@end

@interface WSVPBuffer : NSObject
-(void)push:(CVPixelBufferRef)pixelBuffer;
-(void)clean;
@property (nonatomic, weak) id delegate;
@end
