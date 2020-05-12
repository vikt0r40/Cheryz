//
//  BuyRequestingController.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 11/10/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyRequest.h"
#import "TourPop.h"

@protocol BuyerTourPopupsViewControllerDelegate <NSObject>

@required
//-(void)didClickedAcceptButton;
//-(void)didCLickedDeclineButton;
-(void)haveRequestsToDisplay;
-(void)haveNoRequestsToDisplay;
-(void)sendBuyRequest:(BuyRequest*)request;
@end

@interface BuyerTourPopupsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate> {
    BOOL isfirstTimeTransform;
}
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) id <BuyerTourPopupsViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray* popupsArray;

//-(void)addBuyerBuyRequest:(BuyRequest*)request;
-(void) addTourPopup:(TourPop*)tourPopup;
-(void) removeInfoPopup;
@end
