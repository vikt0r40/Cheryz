//
//  ItemContentCell.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/5/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@protocol ItemContentCellDelegate <NSObject>

@required
-(void)didClickBuyButton:(Product*)product;
-(void)didClickAddToWishlistButton:(Product*)product;
@end

@interface ItemContentCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView* itemImage;
@property (nonatomic, strong) IBOutlet UIButton* buyButton;
@property (nonatomic, strong) IBOutlet UILabel* purchasedLabel;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIButton* wishlistButton;
@property (nonatomic, strong) IBOutlet UILabel* price;
@property (nonatomic, strong) IBOutlet UIView* priceView;
@property (nonatomic, strong) IBOutlet UILabel* countLabel;
@property (nonatomic, strong) Product* product;
@property (nonatomic, weak) id <ItemContentCellDelegate> delegate;
-(void)updateCount:(int)count;
-(IBAction)buyItemAction:(id)sender;
-(IBAction)addToWishListAction:(id)sender;
@end
