//
//  SendRequestCell.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/29/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendRequestCell : UICollectionViewCell
@property (nonatomic) IBOutlet UIImageView* productImage;
@property (nonatomic) IBOutlet UIButton* sendButton;
@property (nonatomic) IBOutlet UIButton* cancelButton;
@property (nonatomic) IBOutlet UITextField* numberField;
@property (nonatomic) IBOutlet UITextView* commentTextView;
@property (nonatomic) IBOutlet UIView* background;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewHeightConstraint;
@end
