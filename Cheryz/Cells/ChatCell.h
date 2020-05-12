//
//  ChatCell.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/1/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell
@property (nonatomic) IBOutlet UITextView* bubbleTextView;
@property (nonatomic) IBOutlet UIImageView* userImage;
@property (nonatomic) IBOutlet UILabel* sentTime;
@property (nonatomic) IBOutlet UILabel* authorName;
@property (nonatomic) IBOutlet UIImageView* image;
@property (nonatomic) IBOutlet NSLayoutConstraint* imageHeightConstraint;
@end
