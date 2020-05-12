//
//  SendRequestCell.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/29/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "SendRequestCell.h"

@implementation SendRequestCell
-(void)prepareForReuse{
    self.productImage.image = nil;
    self.numberField.text = @"1";
    self.commentTextView.text = @"";
}
@end
