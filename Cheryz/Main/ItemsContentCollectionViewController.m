//
//  ItemsContentCollectionViewController.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/5/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "ItemsContentCollectionViewController.h"
#import "ItemContentCell.h"
#import "UIImageView+AFNetworking.h"
#import "TourTabViewControllerProtocol.h"
#import "LiveCommandClient+TourCommands.h"
#import "Order.h"
#import "TotalPriceCollectionReusableView.h"
#import "SessionSettings.h"

@interface ItemsContentCollectionViewController () <ItemContentCellDelegate,TourTabViewControllerProtocol>
@property (nonatomic, strong) NSMutableArray* ordersArray;
@property (nonatomic, strong) UIView *totalView;
@property (nonatomic, weak) UILabel *totalLabel;
@property (nonatomic, strong) NSMutableDictionary* productCount;
@end

const int galleryCollectionViewPadding = 5;
const int galleryCollectionViewItemsPerRow = 2;
@implementation ItemsContentCollectionViewController

static NSString * const reuseIdentifier = @"ItemContentCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productCount = [NSMutableDictionary new];
//    self.totalView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.collectionView.bounds.size.width, 44.)];
//    self.totalView.backgroundColor = [UIColor whiteColor];
//    self.totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.totalView.bounds.size.width-20., self.totalView.bounds.size.height)];
//    
//    [self.totalLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    [self.totalView addSubview:self.totalLabel];
//    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.totalView.bounds.size.width, 1.)];
//    
//    separatorView.backgroundColor = [UIColor lightGrayColor];
//    
//    [separatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    [self.totalView addSubview:separatorView];
    [self updateTotalPrice];
}

-(void)willLoad{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveItemList:) name:kItemListCreatedInTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveItem:) name:kItemCreatedInTourListenerKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBuyResponse:) name:kItemBuyResponseListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(priceUpdatedNotification:) name:kTourCurrentProductPriceIsUpdatedListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveListOfOrdersNotification:) name:kOrderListCreatedInTourListenerKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOrderNotification:) name:kOrderCreatedInTourListenerKey object:nil];
    
}
-(void)willUnload {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)receiveItemList:(NSNotification *)notification{
    self.productsArray = [notification.object mutableCopy];
    [self.collectionView reloadData];
}
- (void)receiveItem:(NSNotification *)notification{
    [self.productsArray insertObject:notification.object atIndex:0];
    if(self.collectionView.indexPathsForVisibleItems.count==0){
        [self.collectionView reloadData];
    }
    else{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    }
}
- (void)priceUpdatedNotification:(NSNotification *)notification {
    NSDictionary *updateDict = notification.object;
    if([updateDict[@"product_id"] isKindOfClass:[NSString class]]){
        Price *price = [Price priceFromDictionary: updateDict[@"price"]];
        if(price){
            [self.productsArray enumerateObjectsUsingBlock:^(Product * _Nonnull product, NSUInteger idx, BOOL * _Nonnull stop) {
                if([product.productID isEqualToString:updateDict[@"product_id"]]){
                    //product.productPrice = [NSString stringWithFormat:@"%.02f",price];
                    product.price = price;
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
                    *stop = YES;
                }
            }];
        }
    }
    
    [self.ordersArray enumerateObjectsUsingBlock:^(Order * _Nonnull order, NSUInteger idx, BOOL * _Nonnull stop) {
        if([order.product_id isEqualToString:updateDict[@"product_id"]]) {
            Price *price = [Price priceFromDictionary: updateDict[@"price"]];
            order.productPrice = price;
            [self updateTotalPrice];
        }
    }];
}

-(void)receiveListOfOrdersNotification:(NSNotification *)notification{
    self.ordersArray = notification.object;
    [self updateTotalPrice];
    
    self.productCount = [NSMutableDictionary new];
    [self.ordersArray enumerateObjectsUsingBlock:^(Order * _Nonnull order, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addProductCountToCache:order.count forProductID:order.product_id];
            //int currentCount = (int)self.productCount[order.product_id];
            //int newCount = currentCount + newOrder.count;
            //[self.productCount setObject:@(newCount) forKey:newOrder.product_id];
    }];
    [self.collectionView reloadData];
}
-(void)addProductCountToCache:(int)count forProductID:(NSString *)productID{
    int oldCount = 0;
    if(self.productCount[productID]){
        NSNumber *countNumber = self.productCount[productID];
        oldCount = [countNumber intValue];
    }
    self.productCount[productID] = @(oldCount+count);
}
-(int)countOfProductWithID:(NSString *)productID{
    if(self.productCount[productID]){
        return [self.productCount[productID] intValue];
    }else{
        return 0;
    }
}
-(void)reloadCountLabelInCellWithProductID:(NSString *)productID{
    [self.productsArray enumerateObjectsUsingBlock:^(Product * _Nonnull product, NSUInteger idx, BOOL * _Nonnull stop) {
        if([product.productID isEqualToString:productID]){
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
            ItemContentCell *cell = (ItemContentCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
            int count = [self countOfProductWithID:productID];
            [cell updateCount:count];
            *stop = YES;
        }
    }];
}
-(void)receiveOrderNotification:(NSNotification *)notification{
    if(!_ordersArray){
        _ordersArray = [NSMutableArray new];
    }
    Order* newOrder = notification.object;
    [self.ordersArray addObject:newOrder];
    [self updateTotalPrice];

    [self addProductCountToCache:newOrder.count forProductID:newOrder.product_id];
    [self reloadCountLabelInCellWithProductID:newOrder.product_id];
}

//-(void)updateTotalPrice {
//    NSString *currency = @"USD";
//    __block double total = 0.;
//    [self.ordersArray enumerateObjectsUsingBlock:^(Order * _Nonnull order, NSUInteger idx, BOOL * _Nonnull stop) {
//        total += [order.productPrice.value floatValue]*order.count;
//    }];
//    self.totalLabel.text = [NSString stringWithFormat:@"Total: %0.2f %@",total, currency];
//}
-(void)updateTotalPrice{
    __block Currency *currency = [SessionSettings defaultSettings].currency;
    __block double total = 0.;
    __block BOOL success = YES;
    [self.ordersArray enumerateObjectsUsingBlock:^(Order * _Nonnull order, NSUInteger idx, BOOL * _Nonnull stop) {
        if(!currency){
            currency = order.productPrice.currency;
        }
        if([currency isEqual:order.productPrice.currency]){
            total += [order.productPrice.value floatValue]*order.count;
        }else{
            success = NO;
            *stop = YES;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(success){
            Price *totalPrice = [Price new];
            totalPrice.value = @(total);
            totalPrice.currency = currency;
            self.totalLabel.text = [NSString stringWithFormat:@"Total: %@",totalPrice.formattedString];
            //[[NSNotificationCenter defaultCenter] postNotificationName:kTotalPriceWasChangedListenerKey object:self.totalLabel.text];
        }else{
            self.totalLabel.text = @"Can't count total.";
        }
    });

}

- (void)receiveBuyResponse: (NSNotification *)notification{
    NSDictionary *dict = notification.object;
    if([dict[@"data"][@"status"] intValue]==1){
        // user buy product
        [self.productsArray enumerateObjectsUsingBlock:^(Product * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.productID isEqualToString:dict[@"data"][@"product_id"]]){
                obj.isPurchased = YES;
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
                *stop = YES;
            }
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addProductToTable:(Product*)product {
    [self.productsArray addObject:product];
    
    if([self.productsArray count] == 1) {
        [self.collectionView reloadData];
    }
    else {
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.productsArray count]-1 inSection:0]]];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.productsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.product = self.productsArray[indexPath.item];
    if(cell.product.price){
        cell.price.text = cell.product.price.formattedString;
    }else{
        cell.price.text = @"Not Specified";
    }
    int itemsCount = [self countOfProductWithID:cell.product.productID];
    
    [cell updateCount:itemsCount];
    
    if (!cell.product.isPurchased) {
        cell.overlayView.hidden = YES;
        //cell.buyButton.hidden = NO;
        //cell.wishlistButton.hidden = NO;
    }
    else {
        cell.overlayView.hidden = NO;
        //cell.buyButton.hidden = YES;
        //cell.wishlistButton.hidden = YES;
    }
    
    if(self.isGuestNotAuthorized) {
        cell.wishlistButton.hidden = YES;
    }
    
    [cell.itemImage setImageWithURL:[NSURL URLWithString:cell.product.productImageUrl]];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isGuestNotAuthorized) {
        return;
    }
//    if([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
//        [self.delegate didSelectItem:[self.productsArray objectAtIndex:indexPath.row]];
//    }
}
#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = collectionView.frame.size.width / galleryCollectionViewItemsPerRow - galleryCollectionViewPadding * galleryCollectionViewItemsPerRow;
    float height = width*4/3;
    return CGSizeMake(width, height);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return galleryCollectionViewPadding+5;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return galleryCollectionViewPadding;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:  (NSInteger)section{
    return UIEdgeInsetsMake(galleryCollectionViewPadding, galleryCollectionViewPadding, 50, galleryCollectionViewPadding);
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    TotalPriceCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TotalPrice" forIndexPath:indexPath];
    self.totalLabel = header.totalLabel;
    [self updateTotalPrice];
    return header;
}

#pragma mark - Cell Delegate
-(void)didClickBuyButton:(Product *)product {
//    if([self.delegate respondsToSelector:@selector(showRequestPopupViewForItem:)]) {
//        [self.delegate showRequestPopupViewForItem:product];
//    }
}
-(void)didClickAddToWishlistButton:(Product *)product {
    NSLog(@"Add to wishlist");
//    if([self.delegate respondsToSelector:@selector(showAddToWishlistController:)]) {
//        [self.delegate showAddToWishlistController:product];
//    }
    
}
@end
