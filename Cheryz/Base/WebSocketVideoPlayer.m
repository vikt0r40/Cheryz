//
//  WebSocketVideoPlayer.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/10/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "WebSocketVideoPlayer.h"
#import <SRWebSocket.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "NALU.h"
#import "WSVPBuffer.h"

@interface WebSocketVideoPlayer ()<SRWebSocketDelegate>{
    uint8_t *buffer;
    uint8_t *chunk;
    int bpos;
    int bsize;
    int c_nal;
    int bsize2;
    NSMutableArray* NALS;
    BOOL reconnectRequired;
    NSTimer *reconnectTimer;
}

@property (nonatomic, strong) SRWebSocket *wssSocket;
@property (nonatomic, assign) BOOL init_decoder;
@property (nonatomic, assign) CMVideoFormatDescriptionRef formatDesc;
@property (nonatomic, assign) VTDecompressionSessionRef decompressionSession;
@property (nonatomic, retain) AVSampleBufferDisplayLayer *videoLayer;
@property (nonatomic, assign) int spsSize;
@property (nonatomic, assign) int ppsSize;
@property (nonatomic, strong) CALayer *layer;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic) CVPixelBufferRef pixelBufferCopy;
@property (nonnull, strong) WSVPBuffer *wsvpBuffer;
@property (nonatomic) uint64_t frameIndex;
@end

@implementation WebSocketVideoPlayer

//-(void) SaveBuffer:(uint8_t *)frame withSize:(uint32_t)Size {
//    
//    NSString *docsDir;
//    NSArray *dirPaths;
//    
//    NSData *data = [NSData dataWithBytes:frame length:Size];
//    
//    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    docsDir = [dirPaths objectAtIndex:0];
//    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"buffer.h264"]];
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
//        NSLog(@"databasePath %@",databasePath);
//    });
//    
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:databasePath];
//    if(fileHandle == nil) {
//        [[NSFileManager defaultManager] createFileAtPath:databasePath contents:nil attributes:nil];
//        fileHandle = [NSFileHandle fileHandleForWritingAtPath:databasePath];
//    }
//    [fileHandle seekToEndOfFile];
//    [fileHandle writeData:data];
//    [fileHandle closeFile];
//   
//    
//}

-(instancetype)initWithURL:(NSString*)url{
    self = [super init];
    
    if(!self){
        return nil;
    }
    reconnectRequired=NO;
    buffer = malloc(5*1024*1024);
    chunk = malloc(1*1024*1024);
    _init_decoder = false;
    _frameIndex = 1;
    bpos = 0;
    bsize = 0;
    c_nal = 0;
    bsize2 = 0;

    NALS = NULL;
    
    self.url = url;
    
    _videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
    
    _videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _videoLayer.backgroundColor = [[UIColor blackColor] CGColor];
    
    CMTimebaseRef controlTimebase;
    CMTimebaseCreateWithMasterClock(CFAllocatorGetDefault(), CMClockGetHostTimeClock(), &controlTimebase);
    
    CMTimebaseSetTime(self.videoLayer.controlTimebase, kCMTimeZero);
    CMTimebaseSetRate(self.videoLayer.controlTimebase, 1.0);
    self.lock = [NSLock new];
    
    self.wsvpBuffer = [WSVPBuffer new];
    
    return self;
}

-(void)dealloc{
    [self.wsvpBuffer clean];
}

-(void)setView:(UIView *)view{
    _view = view;
    self.wsvpBuffer.delegate = self.view;
    
//    _layer = [CALayer layer];
//    _layer.frame = _view.frame;
//    _layer.bounds = _view.bounds;
//    [_view.layer addSublayer:_layer];
//    _videoLayer.frame = _view.frame;
//    _videoLayer.bounds = _view.bounds;
//    [[_view layer] addSublayer:_videoLayer];
}

-(void)startPlaying{
    reconnectRequired = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.wssSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString: self.url]];
        NSLog(@"open video url %@", self.url);
        self.wssSocket.delegate = self;
        [self.wssSocket open];
    });
}

-(void)stopPlaying{
    reconnectRequired = NO;
    if([reconnectTimer isValid]){
        [reconnectTimer invalidate];
        reconnectTimer = nil;
    }
    NSLog(@"close video url %@", self.url);
    [self.wssSocket close];
    
}

- (NSMutableArray*) foundNALU:(uint8_t *)frame withSize:(uint32_t)Size StartPos:(int)StartPos
{
    NSMutableArray* pos = NULL;
    
    
    if (Size==0)
    return NULL;
    
    for (int i = StartPos; i < Size-5; i++)
    {
        if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x00 && frame[i+3] == 0x01)
        {
            if (pos == NULL)
            pos = [[NSMutableArray alloc] init];
            
            NALU* nalu = [NALU alloc];
            nalu.pos = i;
            nalu.type = (frame[i + 4] & 0x1F);
            nalu.hdr = 4;
            [pos addObject:nalu];
            i+=3;
        }
        if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x01)
        {
            if (pos == NULL)
            pos = [[NSMutableArray alloc] init];
            
            NALU* nalu = [NALU alloc];
            nalu.pos = i;
            nalu.type = (frame[i + 3] & 0x1F);
            nalu.hdr = 3;
            [pos addObject:nalu];
        }
    }
    
    
    return pos;
    
}

- (int) foundNALU:(uint8_t *)frame withSize:(uint32_t)Size Type:(int)type
{
    
    for (int i = 0; i < Size-5; i++)
    {
        if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x00 && frame[i+3] == 0x01 && (frame[i + 4] & 0x1F)==type)
        {
            return i;
        }
    }
    
    
    return -1;
    
}

-(void) configure_encoder:(uint8_t *)sps sps_size:(int)sps_size pps:(uint8_t *)pps pps_size:(int)pps_size
{
    OSStatus status;
    
    uint8_t *_pps = NULL;
    uint8_t *_sps = NULL;
    
    _sps = malloc(sps_size-4);
    _pps = malloc(pps_size-4);
    
    memcpy(_sps, &sps[4], sps_size-4);
    memcpy(_pps, &pps[4], pps_size-4);
    
    //[self SaveBuffer:sps withSize:sps_size];
    //[self SaveBuffer:pps withSize:pps_size];
    
    uint8_t*  parameterSetPointers[2] = {_sps, _pps};
    size_t parameterSetSizes[2] = {sps_size-4, pps_size-4};
    
    status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2,
                                                                 (const uint8_t *const*)parameterSetPointers,
                                                                 parameterSetSizes, 4,
                                                                 &_formatDesc);
    if(status != noErr) {
        NSLog(@"\t\t Format Description ERROR type: %d", (int)status);
    }
    
    
    if((status == noErr) && (_decompressionSession == NULL))
    {
        [self createDecompSession];
    }
    
    
}



-(void) process_frame:(uint8_t *)frame size:(int)size Start:(int)start End:(int)end
{
    
    //[self SaveBuffer:frame withSize:size];
    
    OSStatus status;
    
    CMSampleBufferRef sampleBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    
    status = CMBlockBufferCreateWithMemoryBlock(NULL, frame,  // memoryBlock to hold data. If NULL, block will be alloc when needed
                                                size,  // overall length of the mem block in bytes
                                                kCFAllocatorNull, NULL,
                                                0,     // offsetToData
                                                size,  // dataLength of relevant data bytes, starting at offsetToData
                                                0, &blockBuffer);
    
    if(status == noErr)
    {
        const size_t sampleSize = size;
        
        
        //        status = CMSampleBufferCreate(kCFAllocatorDefault,
        //                                      blockBuffer, true, NULL, NULL,
        //                                      _formatDesc, 1, 0, NULL, 1,
        //                                      &sampleSize, &sampleBuffer);
        //
        CMSampleTimingInfo timing               = { CMTimeMake(1, 30), CMTimeMake(_frameIndex, 30), kCMTimeInvalid };
        _frameIndex++;
        status = CMSampleBufferCreate(kCFAllocatorDefault,
                                      blockBuffer,
                                      true,
                                      NULL,
                                      NULL,
                                      _formatDesc,
                                      1,
                                      1,
                                      &timing,
                                      1,
                                      &sampleSize, &sampleBuffer);
        
    }
    
    if(status == noErr)
    {
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
        
        [self render:sampleBuffer];
    }
    
    
    
}


-(void) createDecompSession
{
    // make sure to destroy the old VTD session
    _decompressionSession = NULL;
    VTDecompressionOutputCallbackRecord callBackRecord;
    callBackRecord.decompressionOutputCallback = decompressionSessionDecodeFrameCallback;
    
    // this is necessary if you need to make calls to Objective C "self" from within in the callback method.
    callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
    
    // you can set some desired attributes for the destination pixel buffer.  I didn't use this but you may
    // if you need to set some attributes, be sure to uncomment the dictionary in VTDecompressionSessionCreate
    NSDictionary *destinationImageBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                      [NSNumber numberWithBool:YES],
//                                                      (id)kCVPixelBufferOpenGLESCompatibilityKey,
                                                      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                                         ,kCVPixelBufferPixelFormatTypeKey,
                                                      nil];
    
    OSStatus status =  VTDecompressionSessionCreate(NULL, _formatDesc, NULL,
                                                     (__bridge CFDictionaryRef)(destinationImageBufferAttributes),
                                                    &callBackRecord, &_decompressionSession);
    NSLog(@"Video Decompression Session Create: \t %@", (status == noErr) ? @"successful!" : @"failed...");
    if(status != noErr) NSLog(@"\t\t VTD ERROR type: %d", (int)status);
}


void decompressionSessionDecodeFrameCallback(void *decompressionOutputRefCon,
                                             void *sourceFrameRefCon,
                                             OSStatus status,
                                             VTDecodeInfoFlags infoFlags,
                                             CVImageBufferRef imageBuffer,
                                             CMTime presentationTimeStamp,
                                             CMTime presentationDuration)
{
    
//    NSLog(@"pts %f",CMTimeGetSeconds(presentationTimeStamp));
    if (status == noErr)
//    {
//        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
//        NSLog(@"Decompressed error: %@", error);
//    }else
    {
//        if([streamManager.lock tryLock]){
//            CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
//            
//        
//        }
//        if([streamManager.lock tryLock]){
        WebSocketVideoPlayer *streamManager = (__bridge WebSocketVideoPlayer *)decompressionOutputRefCon;
        [streamManager.wsvpBuffer push:imageBuffer];
            //[streamManager renderPixelBuffer:imageBuffer];

//        }
//            if(streamManager.getImage){
//                CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
//                CIContext *temporaryContext = [CIContext contextWithOptions:nil];
//                CGImageRef videoImage = [temporaryContext
//                                         createCGImage:ciImage
//                                         fromRect:CGRectMake(0, 0,
//                                                             CVPixelBufferGetWidth(imageBuffer),
//                                                             CVPixelBufferGetHeight(imageBuffer))];
//                UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
//                streamManager.getImage(image);
//                CGImageRelease(videoImage);
//
//            }
        }
    //}

}



- (void) render:(CMSampleBufferRef)sampleBuffer
{
    
//    if(self.getImage){
    
        VTDecodeFrameFlags flags = kVTDecodeFrame_EnableAsynchronousDecompression;
        
        NSDate* currentTime = [NSDate date];
        OSStatus status;
        status = VTDecompressionSessionDecodeFrame(_decompressionSession,
                                                   sampleBuffer,
                                                   flags,
                                                   (void*)CFBridgingRetain(currentTime),
                                                   0);
//    }
//    
//    while( ![_videoLayer isReadyForMoreMediaData] ) {
//        usleep(5);
//    }
//    [_videoLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
//    
//    [_videoLayer setNeedsDisplay];
}

- (void)renderPixelBuffer:(CVPixelBufferRef )pixelBuffer {
    
        
    
    // Get pixel buffer info
    
    const int kBytesPerPixel = 4;
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    uint8_t *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // Copy the pixel buffer
    CVPixelBufferRef pixelBufferCopy;
    
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, bufferWidth, bufferHeight, kCVPixelFormatType_32BGRA, NULL, &pixelBufferCopy);
    CVPixelBufferLockBaseAddress(pixelBufferCopy, 0);
    uint8_t *copyBaseAddress = CVPixelBufferGetBaseAddress(pixelBufferCopy);
    memcpy(copyBaseAddress, baseAddress, bufferHeight * bytesPerRow);
    CVPixelBufferUnlockBaseAddress(pixelBufferCopy, 0);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //[self.view drawFrameLock:pixelBufferCopy];
        CVPixelBufferRelease(pixelBufferCopy);
    });
    
    // Do what needs to be done with the 2 pixel buffers
    
}

-(void) Moov:(uint8_t *)data  StartPos:(int)StartPos
{
    memcpy(data, data+StartPos, bsize-StartPos);
    bsize=bsize-StartPos;
}


-(void) Append:(uint8_t *)frame  Size:(int)Size
{
    int last_type = 0;
    
    int i = 0;
    for (i = 0; i < Size-5; i++)
    {
        if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x00 && frame[i+3] == 0x01)
        {
            last_type = (frame[i + 4] & 0x1F);
            memcpy(&buffer[bsize], &frame[i], 5);
            bsize+=5;
            i+=4;
            
        } else {
            if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x01) {
                int type = 0;
                type = (frame[i + 3] & 0x1F);
                
                // fix Iframe
                if (type == 5 && (last_type == 8 || last_type==6))
                buffer[bsize++] = 0;
                
                memcpy(&buffer[bsize], &frame[i], 4);
                bsize+=4;
                last_type = type;
                i+=3;
                
                
            } else {
                // copy byte
                buffer[bsize] = frame[i];
                bsize++;
            }
        }
    }
    memcpy(&buffer[bsize], &frame[i], 5);
    bsize+=5;
    
    
    
}


-(int) foundNALHDR4:(NSMutableArray *)nals Start:(int)Start
{
    if (nals==NULL)
    return -1;
    
    for (int i=Start; i<nals.count; i++) {
        NALU* n = NULL;
        n = nals[i];
        
        if (n==NULL)
        return -1;
        
        if (n.hdr==4)
        return i;
        
        
    }
    
    return -1;
    
}


-(int) foundNAL:(NSMutableArray *)nals Start:(int)Start Type:(int)type
{
    if (nals==NULL)
    return -1;
    
    for (int i=Start; i<nals.count; i++) {
        NALU* n = NULL;
        n = nals[i];
        
        if (n==NULL)
        return -1;
        
        if (n.hdr==4 && n.type == type)
        return i;
        
        
    }
    
    return -1;
    
}


-(int) foundNALHDR3:(NSMutableArray *)nals Start:(int)Start Type:(int)type
{
    if (nals==NULL)
    return -1;
    
    for (int i=Start; i<nals.count; i++) {
        NALU* n = NULL;
        n = nals[i];
        
        if (n==NULL)
        return -1;
        
        if (n.hdr==3 && n.type == type)
        return i;
        
        
    }
    
    return -1;
    
}


-(int) AnnexbToAVC:(uint8_t *)data  Start:(int)Start End:(int)End
{
    int size = 0;
    
    for (int i=Start; i<End; i++) {
        NALU *n1 = NALS[i];
        NALU *n2 = NALS[i+1];
        
        int len = n2.pos - n1.pos - n1.hdr;
        
        uint32_t dataLength32 = htonl (len);
        memcpy (&data[size], &dataLength32, sizeof (uint32_t));
        size+=4;
        memcpy(&data[size],&buffer[n1.pos+n1.hdr], len);
        size+=len;
        
    }
    
    return size;
    
}



- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Video Websoket Receive message");
    bool update_decoder_config = false;
    
    
    memcpy(&buffer[bsize],[((NSData*)message) bytes], ((NSData*)message).length);
    bsize+=((NSData*)message).length;
    
    
    if (!_init_decoder) {
        int pos = -1;
        pos = [self foundNALU:buffer withSize:bsize Type:7];
        if (pos==-1)
        return;
        
    }
    
    // found SPS PPS
    if (!_init_decoder) {
        int pos = -1;
        pos = [self foundNALU:buffer withSize:bsize Type:7];
        if (pos==-1)
        return;
        if (pos!=0)
        [self Moov:buffer  StartPos:pos];
        if ([self foundNALU:buffer withSize:bsize Type:1] == -1)
        return;
        NALS = [self foundNALU:buffer withSize:bsize StartPos:0];
        update_decoder_config = true;
        
    }
    
    if (_init_decoder) {
        NALS = [self foundNALU:buffer withSize:bsize StartPos:0];
    }
    
    bool need_more_data = false;
    while (NALS.count>15 && !need_more_data) {
        
        //        // configure decoder
        //        if ( update_decoder_config)
        //        {
        //
        //            int sps_pos = [self foundNAL:NALS Start:0 Type:7];
        //            int pps_pos = [self foundNAL:NALS Start:0 Type:8];
        //
        //            int ifr_pos = [self foundNALHDR3:NALS Start:0 Type:5];
        //
        //
        //            if (sps_pos!=-1 && pps_pos!=-1 && ifr_pos!=-1) {
        
        // configure decoder
        if ( update_decoder_config)
        {
            
            int sps_pos = [self foundNAL:NALS Start:0 Type:7];
            int pps_pos = [self foundNAL:NALS Start:0 Type:8];
            
            int ifr_pos = [self foundNALHDR3:NALS Start:0 Type:5];
            int ifr_pos4 = [self foundNAL:NALS Start:0 Type:5];
            
            if (ifr_pos4 == -1 && ifr_pos == -1)
            break;
            
            if (ifr_pos4==-1)
            ifr_pos4 = 64*1024;//NSIntegerMax;
            if (ifr_pos==-1)
            ifr_pos = 64*1024;//NSIntegerMax;
            
            if (ifr_pos4<ifr_pos)
            ifr_pos = ifr_pos4;
            
            
            
            if (sps_pos!=-1 && pps_pos!=-1 && ifr_pos!=-1) {
                NALU* sps = NALS[sps_pos];
                NALU* pps = NALS[pps_pos];
//                NALU* ifr = NALS[ifr_pos];
                
                NALU* n = NULL;
                
                n = NALS[sps_pos+1];
                int sps_size = n.pos  - sps.pos;
                
                n = NALS[pps_pos+1];
                int pps_size = n.pos  - pps.pos;
                
                
                int ifr_end = [self foundNALHDR4:NALS Start:ifr_pos+1];
                n = NALS[ifr_end];
                
                // configure decoder
                [self configure_encoder:&buffer[sps.pos] sps_size:sps_size pps:&buffer[pps.pos] pps_size:pps_size];
                
                /// write Iframe
                int len = [self AnnexbToAVC:chunk Start:ifr_pos End:ifr_end];
                
                
                [self process_frame:chunk size:len Start:ifr_pos End:ifr_end]  ;
                
                [self Moov:buffer  StartPos:n.pos];
                NALS = [self foundNALU:buffer withSize:bsize StartPos:0];
                _init_decoder = true;
                if([self.delegate respondsToSelector:@selector(webSocketVideoPlayerStartPlaying)]){
                    [self.delegate webSocketVideoPlayerStartPlaying];
                }
                update_decoder_config = false;
                
            }
            
        }
        
        if (!_init_decoder)
        break;
        
        
        NALU *last = NULL;
        
        /// parse others NALU
        for  (int i=0; i<NALS.count-2; i++)
        {
            
            NALU *n1 = NALS[i];
            NALU *n2 = NALS[i+1];
            
            int pos1 = i;
            int pos2 = i+1;
            
            // check for SPS/PPS
            if (n1.type == 7 )
            {
                
                if ([self foundNALU:&buffer[n1.pos+4] withSize:bsize Type:1]!=-1)
                update_decoder_config = true;
                else
                need_more_data = true;
                
                break;
            }
            
            pos2 = [self foundNALHDR4:NALS Start:i+1];
            if (pos2!=-1) {
                
                n2 = NALS[pos2];
                int len = [self AnnexbToAVC:chunk Start:pos1 End:pos2];
                [self process_frame:chunk size:len Start:pos1 End:pos2];
                
                [self Moov:buffer  StartPos:n2.pos];
                NALS = [self foundNALU:buffer withSize:bsize StartPos:0];
                
                break;
                
                
            }else{
                need_more_data = true;
            }
            break;
            
            
        }
        
        if (last!=NULL) {
            [self Moov:buffer  StartPos:last.pos];
            NALS = [self foundNALU:buffer withSize:bsize StartPos:0];
        }
        
    }
    
    
    
}



- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
//    NSString *helloMsg = @"{\"event\":\"pusher:subscribe\",\"data\":{\"channel\":\"chat_ru\"}}";
//    // [webSocket send:helloMsg];
    NSLog(@"Open web socket for video");
}


- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"Close web socket with video");
    if([self.delegate respondsToSelector:@selector(webSocketVideoPlayerEndPlaying)]){
        [self.delegate webSocketVideoPlayerEndPlaying];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
//    NSLog(@"Recieve error \n");
    NSLog(@"Error web socket with video");
    if(reconnectRequired){
        reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(startPlaying) userInfo:nil repeats:NO];
    }
    if([self.delegate respondsToSelector:@selector(webSocketVideoPlayerError:)]){
        [self.delegate webSocketVideoPlayerError:error];
    }
}

@end
