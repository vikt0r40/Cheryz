//
//  BuyRequestingController.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/10/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "BuyerTourPopupsViewController.h"
#import "SendRequestCell.h"
#import "UIImageView+AFNetworking.h"
#import "InfoRequestCell.h"
#import "CheckPopupCell.h"
#import "AlertView.h"

@interface BuyerTourPopupsViewController () <CheckPopupCellDelegate, InfoRequestCellDelegate>{
    int imageHeightConstant;
}
@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic) int currectBuyerCellIndex;
@end

@implementation BuyerTourPopupsViewController
#define TRANSFORM_CELL_VALUE CGAffineTransformMakeScale(0.8, 0.8)
#define ANIMATION_SPEED 0.2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isfirstTimeTransform = YES;
    self.popupsArray = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}
-(void)keyboardWillShow:(NSNotification *)aNotisfication {
    SendRequestCell* cell = (SendRequestCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currectBuyerCellIndex inSection:0]];
    if(cell.imageHeightConstraint.constant>0){
        imageHeightConstant = cell.imageHeightConstraint.constant;
        cell.imageHeightConstraint.constant = 0;
        cell.backgroundViewHeightConstraint.constant -= imageHeightConstant;
        [self.view layoutIfNeeded];
    }
}
-(void)keyboardWillHide:(NSNotification *)aNotification {
    SendRequestCell* cell = (SendRequestCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currectBuyerCellIndex inSection:0]];
    if(cell.imageHeightConstraint.constant != imageHeightConstant){
        cell.imageHeightConstraint.constant = imageHeightConstant;
        cell.backgroundViewHeightConstraint.constant += imageHeightConstant;
        [self.view layoutIfNeeded];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.popupsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TourPop* pop = self.popupsArray[indexPath.row];
    
    switch (pop.type) {
        case BuyerBuyRequestPopupType: {
            BuyRequest* req = pop.model;
            
            
            SendRequestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SendRequestCell" forIndexPath:indexPath];
            
            if (indexPath.row == 0 && isfirstTimeTransform) { // make a bool and set YES initially, this check will prevent fist load transform
                isfirstTimeTransform = NO;
            }else{
                //cell.transform = TRANSFORM_CELL_VALUE; // the new cell will always be transform and without animation
            }
            
            if (indexPath.row == 0) {
                _currectBuyerCellIndex = 0;
            }
            
            [cell.productImage setImageWithURL:[NSURL URLWithString:req.imageURL]];
            
            cell.sendButton.tag = indexPath.row;
            cell.cancelButton.tag = indexPath.row;
            
            [cell.sendButton addTarget:self action:@selector(sendRequest:) forControlEvents:UIControlEventTouchUpInside];
            [cell.cancelButton addTarget:self action:@selector(cancelRequest:) forControlEvents:UIControlEventTouchUpInside];
            cell.commentTextView.delegate = self;            
            return cell;

        }
            break;
        
        case BuyerItemInfoRequestPopupType:{
            InfoRequestCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InfoRequestCell" forIndexPath:indexPath];
            cell.infoRequest = pop.model;
            cell.delegate = self;
            return cell;
            
        }
            break;
            
        case CheckViewerPopupType:{
            CheckPopupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckPopupCell" forIndexPath:indexPath];
            cell.imageView.image = pop.model;
            cell.delegate = self;
            return cell;
        }
            break;
            
        default:
            return nil;
            break;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    float left = (self.collectionView.frame.size.width - 292)/2;
    return UIEdgeInsetsMake(0, left, 0, 0);
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    float pageWidth = 302; // width + space
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset)
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
    else
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
    
    if (newTargetOffset < 0)
        newTargetOffset = 0;
    else if (newTargetOffset > scrollView.contentSize.width)
        newTargetOffset = scrollView.contentSize.width;
    
    targetContentOffset->x = currentOffset;
    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
    
    int index = newTargetOffset / pageWidth;
    
    if (index == 0) { // If first index
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index  inSection:0]];
        
        [UIView animateWithDuration:ANIMATION_SPEED animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
        cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index + 1  inSection:0]];
        [UIView animateWithDuration:ANIMATION_SPEED animations:^{
            cell.transform = TRANSFORM_CELL_VALUE;
        }];
        _currectBuyerCellIndex = index;
        
    }else{
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [UIView animateWithDuration:ANIMATION_SPEED animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
        
        index --; // left
        cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [UIView animateWithDuration:ANIMATION_SPEED animations:^{
            cell.transform = TRANSFORM_CELL_VALUE;
        }];
        
        index ++;
        index ++; // right
        cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [UIView animateWithDuration:ANIMATION_SPEED animations:^{
            cell.transform = TRANSFORM_CELL_VALUE;
        }];
        _currectBuyerCellIndex = index;
    }
}
#pragma mark - BUTTON ACTIONS
- (void)sendRequest:(UIButton*)sender {
    
    SendRequestCell* cell = (SendRequestCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([cell.numberField.text rangeOfCharacterFromSet:notDigits].location != NSNotFound)
    {
        [AlertView showAlertViewWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Only digits are allowed in count field", nil) controller:self];
        return;
    }
    if([cell.numberField.text intValue] > 1000) {
        [AlertView showAlertViewWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Maximum count is 1000", nil) controller:self];
        return;
    }
    if([cell.numberField.text intValue] < 1) {
        [AlertView showAlertViewWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Minimum count is 1", nil) controller:self];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(sendBuyRequest:)]) {
        BuyRequest* req = [(TourPop*)self.popupsArray[sender.tag] model];
        req.quantity = [cell.numberField.text intValue];
        [self.delegate sendBuyRequest:req];
        
        if([self.delegate respondsToSelector:@selector(haveRequestsToDisplay)]){
            [self.delegate haveRequestsToDisplay];
        }
    }
    
    [self.popupsArray removeObjectAtIndex:sender.tag];
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:sender.tag inSection:0]]];
    
    if(self.popupsArray.count==0){
        if([self.delegate respondsToSelector:@selector(haveNoRequestsToDisplay)]){
            [self.delegate haveNoRequestsToDisplay];
        }
    }
}
- (void)cancelRequest:(UIButton*)sender {
    NSLog(@"You decline item at index: %li",sender.tag);
//    [self.delegate didCLickedDeclineButton];
    
    [self.popupsArray removeObjectAtIndex:sender.tag];
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:sender.tag inSection:0]]];
    
    if(self.popupsArray.count==0){
        [self.collectionView reloadData];
        if([self.delegate respondsToSelector:@selector(haveNoRequestsToDisplay)]){
            [self.delegate haveNoRequestsToDisplay];
        }
    }
}
-(void)removePopupAtIndexPath:(NSIndexPath *) indexPath{
    [self.popupsArray removeObjectAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    if(self.popupsArray.count==0){
        if([self.delegate respondsToSelector:@selector(haveNoRequestsToDisplay)]){
            [self.delegate haveNoRequestsToDisplay];
        }
    }
}
-(void)closeCheckPopupCell:(CheckPopupCell *)cell{
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
    
    [self removePopupAtIndexPath:indexPath];

}
-(void) addTourPopup:(TourPop*)tourPopup {
    [self.popupsArray addObject:tourPopup];
    
    if([self.popupsArray count] == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
    else {
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.popupsArray count]-1 inSection:0]]];
    }
    
    if([self.delegate respondsToSelector:@selector(haveRequestsToDisplay)]){
        [self.delegate haveRequestsToDisplay];
    }
}

-(void) removeInfoPopup{
    [self.popupsArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TourPop *tourPop, NSUInteger idx, BOOL * _Nonnull stop) {
        if(tourPop.type == BuyerItemInfoRequestPopupType){
            
            [self.popupsArray removeObjectAtIndex:idx];
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
            
            if(self.popupsArray.count==0){
                if([self.delegate respondsToSelector:@selector(haveNoRequestsToDisplay)]){
                    [self.delegate haveNoRequestsToDisplay];
                }
            }
        }
    }];
}

-(void) removeTourPopup:(TourPop*)tourPopup {
    
    NSUInteger index = [self.popupsArray indexOfObject:tourPopup];
    [self.popupsArray removeObjectAtIndex:index];
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    
    if(self.popupsArray.count==0){
        if([self.delegate respondsToSelector:@selector(haveNoRequestsToDisplay)]){
            [self.delegate haveNoRequestsToDisplay];
        }
    }
}
#pragma mark - Text Field Delegate
- (void)textViewDidChange:(UITextView *)textView {
    TourPop* currentPop = self.popupsArray[_currectBuyerCellIndex];
    [(BuyRequest*)currentPop.model setComment:textView.text];
}


-(void)didCLickCloseButton {
    [self.popupsArray removeAllObjects];
    if([self.delegate respondsToSelector:@selector(haveNoRequestsToDisplay)]){
        [self.delegate haveNoRequestsToDisplay];
    }
}
@end
