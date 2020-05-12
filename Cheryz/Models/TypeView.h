//
//  TypeView.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/24/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeButton.h"
@class TypeView;
@protocol TypeViewDelegate <NSObject>
@required
-(void)typeViewDidPressedAtIndex:(int)index;
@end

@interface TypeView : UIView
@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, strong) UIStackView* buttonStack;
@property (nonatomic, strong) NSArray* buttonsArray;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, weak) id<TypeViewDelegate> typeViewDelegate;
@end
