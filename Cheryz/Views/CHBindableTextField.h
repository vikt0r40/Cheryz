//
//  CHBindableTextField.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/13/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHBindableTextField : UITextField <UITextFieldDelegate>
-(void)bindValueToTarget:(id)target andKey:(NSString*)key;
-(void)bindNumberToTarget:(id)target andKey:(NSString*)key;
@property (nonatomic, weak) id bindTarget;
@property (nonatomic, strong) NSString *bindKey;
@end
