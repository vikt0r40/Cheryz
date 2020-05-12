//
//  VideoView.h
//  Cheryz
//
//  Created by Viktor Todorov on 7.05.20.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import <GLKit/GLKit.h>

@interface VideoView : UIImageView {
    CIImage* image;
    CIContext* ciContext;
}

@end

