//
//  CHChecksCollectionView.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/1/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHChecksCollectionViewDelegate <NSObject>

-(void)didSelectCheckWithImage:(UIImage *)image;
-(void)didSelectNewCheck;
@end
@interface CHChecksCollectionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *checks;
@property (nonatomic, weak) id <CHChecksCollectionViewDelegate> delegate;
@property (nonatomic) BOOL allowAddNewCheck;
@property (nonatomic) BOOL isAuthor;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
-(void)reloadTheData;
@end
