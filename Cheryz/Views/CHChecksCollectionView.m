//
//  CHChecksCollectionView.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/1/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "CHChecksCollectionView.h"
#import "CheckCell.h"
#import "UIImageView+AFNetworking.h"
#import "LiveCommandClient+TourCommands.h"
#import "UIColor+Cheryz.h"

static NSString * const reuseIdentifier = @"CheckCell";
@implementation CHChecksCollectionView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:flowLayout];
    if(self.isAuthor) {
        self.allowAddNewCheck = YES;
    }
    [self.collectionView reloadData];
    return self;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.checks.count+(int)self.allowAddNewCheck;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CheckCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(!self.isAuthor) {
        [cell.imageViewCheck setImageWithURL:[NSURL URLWithString:self.checks[indexPath.item]]];
        cell.imageViewCheck.contentMode = UIViewContentModeScaleAspectFill;
        return cell;
    }
    
    if(indexPath.item==0 && self.allowAddNewCheck){
        
        [cell.imageViewCheck setImage:[UIImage imageNamed:@"SmallCheck"]];
        cell.imageViewCheck.contentMode = UIViewContentModeCenter;
        cell.imageViewCheck.layer.borderColor = [UIColor cheryzGray].CGColor;
        cell.imageViewCheck.layer.borderWidth = 1.;
        
    }else{
        int offset = self.allowAddNewCheck? -1 : 0;
        [cell.imageViewCheck setImageWithURL:[NSURL URLWithString:self.checks[indexPath.item+offset]]];
        cell.imageViewCheck.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageViewCheck.layer.borderWidth = 0;
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.isAuthor) {
        CheckCell *cell = (CheckCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if([self.delegate respondsToSelector:@selector(didSelectCheckWithImage:)]){
            [self.delegate didSelectCheckWithImage:cell.imageViewCheck.image];
        }
        return;
    }
    
    if(indexPath.item==0 && self.allowAddNewCheck){
        if([self.delegate respondsToSelector:@selector(didSelectNewCheck)]){
            [self.delegate didSelectNewCheck];
        }
    }else{
        CheckCell *cell = (CheckCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if([self.delegate respondsToSelector:@selector(didSelectCheckWithImage:)]){
            [self.delegate didSelectCheckWithImage:cell.imageViewCheck.image];
        }
    }
}
-(void)reloadTheData {
    if(self.isAuthor) {
        self.allowAddNewCheck = YES;
    }
    [self.collectionView reloadData];
}

@end
