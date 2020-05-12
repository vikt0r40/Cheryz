//
//  VideoView.m
//  Cheryz
//
//  Created by Viktor Todorov on 7.05.20.
//

#import "VideoView.h"

@implementation VideoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentMode = UIViewContentModeScaleAspectFit;
}
-(void)drawFrameLock:(CVPixelBufferRef)pixelBuffer {
    
    long w = CVPixelBufferGetWidth(pixelBuffer);
    long h = CVPixelBufferGetHeight(pixelBuffer);
    UIGraphicsBeginImageContext(CGSizeMake(w, h));

    CGContextRef c = UIGraphicsGetCurrentContext();

    void *ctxData = CGBitmapContextGetData(c);

    // MUST READ-WRITE LOCK THE PIXEL BUFFER!!!!
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *pxData = CVPixelBufferGetBaseAddress(pixelBuffer);
    memcpy(ctxData, pxData, 4 * w * h);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    self.image = img;
    
    
}
@end
