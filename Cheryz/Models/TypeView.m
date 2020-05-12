//
//  TypeView.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/24/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "TypeView.h"
#import "UIColor+Cheryz.h"

@implementation TypeView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(!self) {
        return nil;
    }
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
    [self.bottomView setBackgroundColor:[UIColor cheryzBlue]];
    
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setBackgroundColor:[UIColor lightGrayColor]];
    
    //Stack View
    self.buttonStack = [[UIStackView alloc] init];
    self.buttonStack.backgroundColor  = [UIColor cheryzRed];//[UIColor colorWithRed:239.f/255.f green:76.f/255.f blue:90.f/255.f alpha:1];
    self.buttonStack.axis = UILayoutConstraintAxisHorizontal;
    self.buttonStack.distribution =  UIStackViewDistributionEqualSpacing;
    self.buttonStack.alignment = UIStackViewAlignmentFill;
    self.buttonStack.spacing = 1;
    [self.buttonStack setFrame:CGRectMake(1, 1, self.bounds.size.width-2, self.bounds.size.height-2)];
    [self.buttonStack setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.buttonStack];
    [self addSubview:self.bottomView];
    NSArray* verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView(1)]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views: @{@"bottomView":self.bottomView}];
    [self addConstraints:verticalConstraints];
    NSArray* horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[bottomView]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views: @{@"bottomView":self.bottomView}];
    [self addConstraints:horizontalConstraints];

    return self;
}
-(void)setButtonsArray:(NSArray *)buttonsArray {
    _buttonsArray = buttonsArray;
    
    [_buttonsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TypeButton* button = [[TypeButton alloc] initWithTitle:obj andStackView:self.buttonStack arrayCount:(int)[_buttonsArray count]];
        [button addTarget:self action:@selector(activateButton:) forControlEvents:UIControlEventTouchUpInside];
        
    }];
}
-(void)setSelectedIndex:(NSUInteger )selectedIndex{
    _selectedIndex = selectedIndex;
    if(self.buttonsArray.count>_selectedIndex){
        ((TypeButton*)self.buttonStack.subviews[_selectedIndex]).isActive = YES;
        [self.buttonStack.subviews enumerateObjectsUsingBlock:^(__kindof TypeButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            obj.isActive = idx==_selectedIndex;
        }];
    }
}
-(void)activateButton:(TypeButton*)sender {
    if(sender.isActive)
        return;
    [self.buttonStack.subviews enumerateObjectsUsingBlock:^(__kindof TypeButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.isActive = [sender isEqual:obj];
        if (obj.isActive) {
            [self.typeViewDelegate typeViewDidPressedAtIndex:(int)idx];
        }
    }];
}
@end
