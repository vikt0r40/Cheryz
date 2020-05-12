//
//  EmbededResourceCollectionViewCell.m
//  Cheryz
//
//  Created by Azarnikov Vadim on 10/21/15.
//  Copyright © 2015 Cheryz. All rights reserved.
//

#import "EmbededResourceCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+AFNetworking.h"

@interface EmbededResourceCollectionViewCell()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation EmbededResourceCollectionViewCell

-(void)setResourceLocalURL:(NSURL *)resourceURL{
    _resourceURL = resourceURL;
    
    NSData *data = [NSData dataWithContentsOfURL:resourceURL];

    self.imageView.image = [UIImage imageWithData:data];
    
}
-(void)setNonLocalURL:(NSURL*)resourceURL {
    _resourceURL = resourceURL;
    
    [self.imageView setImageWithURL:_resourceURL];
}
-(IBAction)deleteButtonPressed:(id)sender{
    if([self.delegate respondsToSelector:@selector(deleteEmbededResourseCell:)]){
        [self.delegate deleteEmbededResourseCell:self];
    }
    
    
    // remove resource file
    
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtURL:_resourceURL error:&error];
    
    if(error){
        NSLog(@"Remive resource file error %@",error);
    }
    
}
@end
