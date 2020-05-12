//
//  EmbededResourceCollectionViewCell.h
//  Cheryz
//
//  Created by Azarnikov Vadim on 10/21/15.
//  Copyright © 2015 Cheryz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    EmbededResourcePhotoType,
    EmbededResourceVideoType,
} EmbededResourceType;

@class EmbededResourceCollectionViewCell;

@protocol EmbededResourceCollectionViewCellDelegate <NSObject>

-(void)deleteEmbededResourseCell:(EmbededResourceCollectionViewCell*)cell;

@end

@interface EmbededResourceCollectionViewCell : UICollectionViewCell

@property (readonly) EmbededResourceType resourceType;
@property (readonly) NSURL *resourceURL;
@property (weak) id<EmbededResourceCollectionViewCellDelegate>delegate;
@property (nonatomic) IBOutlet UIButton* deleteButton;
-(void)setResourceLocalURL:(NSURL *)resourceURL;
-(void)setNonLocalURL:(NSURL*)resourceURL;
@end
