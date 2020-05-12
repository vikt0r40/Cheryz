//
//  ItemsContentCollectionViewController.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/5/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@protocol ItemsContentCollectionViewControllerDelegate <NSObject>

-(void)didSelectItem:(Product*)item;

@end

@interface ItemsContentCollectionViewController : UICollectionViewController
@property (nonatomic, weak) id <ItemsContentCollectionViewControllerDelegate> itemDelegate;
@property (nonatomic, strong) NSMutableArray* productsArray;
@property (nonatomic) BOOL isGuestNotAuthorized;
@end
