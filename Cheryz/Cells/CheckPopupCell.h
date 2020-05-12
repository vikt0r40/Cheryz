//
//  CheckPopupCell.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/10/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckPopupCell;

@protocol CheckPopupCellDelegate <NSObject>
-(void)closeCheckPopupCell:(CheckPopupCell*)cell;
@end
@interface CheckPopupCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) id<CheckPopupCellDelegate> delegate;
@end
