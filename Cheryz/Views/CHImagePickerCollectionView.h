//
//  CHImagePickerCollectionView.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/3/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHImagePickerCollectionView : UIView
-(void)bindArrayToTarget:(id)target andKey:(NSString*)key;
@property (nonatomic, weak) id bindTarget;
@property (nonatomic, strong) NSString *bindKey;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL isAuthor;
@property (nonatomic, strong) IBOutlet UIButton* addImageButton;
-(void)reloadData;
@end
