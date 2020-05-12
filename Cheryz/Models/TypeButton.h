//
//  TypeButton.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/24/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeButton : UIButton
@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic) BOOL isActive;
-(instancetype)initWithTitle:(NSString*)title andStackView:(UIStackView*)stackview arrayCount:(int)arrayCount;

@end
