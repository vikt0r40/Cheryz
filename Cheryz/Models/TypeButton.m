//
//  TypeButton.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/24/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "TypeButton.h"
#import "UIColor+Cheryz.h"

@implementation TypeButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithTitle:(NSString*)title andStackView:(UIStackView*)stackview arrayCount:(int)arrayCount{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    [self setTitle:title forState:UIControlStateNormal];
    
    [stackview addArrangedSubview:self];
    
    [self.widthAnchor constraintGreaterThanOrEqualToAnchor:stackview.widthAnchor multiplier:1./arrayCount constant:-1+(1./arrayCount)].active = true;
    [self.heightAnchor constraintEqualToAnchor:stackview.heightAnchor multiplier:1].active = true;
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-5, self.bounds.size.width, 5)];
    [self.bottomView setBackgroundColor:[UIColor cheryzRed]];//[UIColor colorWithRed:239.f/255.f green:76.f/255.f blue:90.f/255.f alpha:1]];
    [self addSubview:self.bottomView];
    self.isActive = NO;
    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray* verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView(5)]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views: @{@"bottomView":self.bottomView}];
    [self addConstraints:verticalConstraints];
    NSArray* horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(-1)-[bottomView]-(-1)-|" options:NSLayoutFormatAlignmentMask metrics:nil views: @{@"bottomView":self.bottomView}];
    [self addConstraints:horizontalConstraints];
    
    return self;
}
-(void)setIsActive:(BOOL)isActive {
    _isActive = isActive;
    
    self.bottomView.hidden = !isActive;
    if (!isActive) {
        self.backgroundColor = [UIColor colorWithRed:244.f/255.f green:244.f/255.f blue:244.f/255.f alpha:1];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
//        [self setTitleColor:[UIColor colorWithRed:239.f/255.f green:76.f/255.f blue:90.f/255.f alpha:1] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor cheryzRed] forState:UIControlStateNormal];
    }
}
@end
