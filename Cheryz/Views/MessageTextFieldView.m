//
//  MessageTextFieldView.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "MessageTextFieldView.h"

@implementation MessageTextFieldView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
        NSArray *loadedViews = [mainBundle loadNibNamed:@"MessageTextFieldView" owner:self options:nil];
        MessageTextFieldView *loadedSubview = [loadedViews firstObject];
        
        [self addSubview:loadedSubview];
        
        loadedSubview.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeTop]];
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeLeft]];
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeBottom]];
        [self addConstraint:[self pin:loadedSubview attribute:NSLayoutAttributeRight]];
        
        if ([self.messageField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor blackColor];
            self.messageField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Type something", nil) attributes:@{NSForegroundColorAttributeName: color}];
        } else {
            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
            // TODO: Add fall-back code to set placeholder color.
        }
        self.messageField.delegate = self;
    }
    return self;
}

- (NSLayoutConstraint *)pin:(id)item attribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:item
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([self.delegate respondsToSelector:@selector(didClickReturnKey)]) {
        [self.delegate didClickReturnKey];
    }
    
    return YES;
}
@end
