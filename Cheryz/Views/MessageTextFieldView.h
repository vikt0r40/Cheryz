//
//  MessageTextFieldView.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageTextFieldViewDelegate <NSObject>

-(void)didClickReturnKey;

@end

@interface MessageTextFieldView : UIView <UITextFieldDelegate>
@property (nonatomic) IBOutlet UITextField* messageField;
@property (nonatomic) IBOutlet UIButton* messageSendButton;
@property (nonatomic, weak) id <MessageTextFieldViewDelegate> delegate;
@end
