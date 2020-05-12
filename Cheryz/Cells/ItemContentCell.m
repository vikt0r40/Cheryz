//
//  ItemContentCell.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/5/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "ItemContentCell.h"
#import "UIColor+Cheryz.h"

@implementation ItemContentCell
-(void)awakeFromNib {
    [super awakeFromNib];
    
//    self.buyButton.layer.borderWidth = 1;
//    self.buyButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    
//    self.wishlistButton.layer.borderWidth = 1;
//    self.wishlistButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}
-(void)updateCount:(int)count{
    if(count > 0) {
        self.countLabel.text = [NSString stringWithFormat:@"%i",count];
        self.countLabel.hidden = NO;
    }
    else {
        self.countLabel.hidden = YES;
    }
}
- (void)buyItemAction:(id)sender {
    [self.delegate didClickBuyButton:self.product];
}
-(void)prepareForReuse {
    self.product = nil;
    self.itemImage.image = nil;
}
-(void)addToWishListAction:(id)sender {
    [self.delegate didClickAddToWishlistButton:self.product];
}
-(void)setProduct:(Product *)product {
    _product = product;
}
@end
