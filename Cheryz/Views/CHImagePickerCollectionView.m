//
//  CHImagePickerCollectionView.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 11/3/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHImagePickerCollectionView.h"
#import "EmbededResourceCollectionViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface CHImagePickerCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource, EmbededResourceCollectionViewCellDelegate>{
    CGFloat addEmbededPhotoButtonWidthConstraintConstant;
}

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addEmbededPhotoButtonWidthConstraint;
@property (nonatomic, strong) IBOutlet UIView *view;
@end

@implementation CHImagePickerCollectionView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }

    self.array = [NSMutableArray new];
    self.isAuthor = YES;
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"CHImagePickerCollectionView" owner:self options:nil];
    UIView *view = views[0];
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:view];
    
    addEmbededPhotoButtonWidthConstraintConstant = self.addEmbededPhotoButtonWidthConstraint.constant;
    
    NSString *identifier = @"EmbededPhotoCell";
    
    //static BOOL nibMyCellloaded = NO;
    
        UINib *nib = [UINib nibWithNibName:@"CHImagePickerCollectionViewCell" bundle: nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    
    
    return self;
}
-(void)bindArrayToTarget:(id)target andKey:(NSString*)key{
    self.bindTarget = target;
    self.bindKey = key;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDatasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.array.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    EmbededResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmbededPhotoCell" forIndexPath:indexPath];
    if(!self.isAuthor) {
        cell.deleteButton.hidden = YES;
        [cell setNonLocalURL:self.array[indexPath.item]];
    }
    else {
        cell.deleteButton.hidden = NO;
        [cell setResourceLocalURL: self.array[indexPath.item]];
    }
    cell.delegate = self;
    
    return cell;
    
}
-(void)deleteEmbededResourseCell:(EmbededResourceCollectionViewCell *)cell{
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self.array removeObjectAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self.bindTarget setValue:[self.array copy] forKey:self.bindKey];
    if(self.addEmbededPhotoButtonWidthConstraint.constant!=addEmbededPhotoButtonWidthConstraintConstant){
        [UIView animateWithDuration:0.5 animations:^{
            self.addEmbededPhotoButtonWidthConstraint.constant = addEmbededPhotoButtonWidthConstraintConstant;
            [self updateConstraintsIfNeeded];
        }];
    }
}
- (IBAction)addEmbededImageButtonPressed:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self.delegate presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@", info);
    if([info[UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]){
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], [NSString stringWithFormat:@"_img.jpg"]];
        NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        
        UIImage *editedImage = info[@"UIImagePickerControllerEditedImage"];
        NSData * editedImageData = UIImageJPEGRepresentation(editedImage, 1.);
        [editedImageData writeToURL:fileURL atomically:YES];
        
        [self.array addObject:fileURL];
        [self.bindTarget setValue:[self.array copy] forKey:self.bindKey];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.array.count-1 inSection:0]]];
        if(self.array.count>2){
            self.addEmbededPhotoButtonWidthConstraint.constant = 0;
        }else{
            self.addEmbededPhotoButtonWidthConstraint.constant = addEmbededPhotoButtonWidthConstraintConstant;
        }
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)reloadData {
    self.addEmbededPhotoButtonWidthConstraint.constant = 0;
    [self updateConstraintsIfNeeded];
    [self.collectionView reloadData];
}
@end
