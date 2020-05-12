//
//  InfoRequestCell.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/4/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoRequest.h"

@class InfoRequestCell;

@protocol InfoRequestCellDelegate <NSObject>

-(void)acceptInfoRequestAtCell:(InfoRequestCell *)infoRequestCell;
-(void)declineInfoRequestAtCell:(InfoRequestCell *)infoRequestCell;
-(void)didCLickCloseButton;

@end

@interface InfoRequestCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel* userName;
@property (nonatomic, strong) IBOutlet UIImageView* productImage;
@property (nonatomic, strong) InfoRequest *infoRequest;
@property (nonatomic, weak) id <InfoRequestCellDelegate> delegate;

@end
