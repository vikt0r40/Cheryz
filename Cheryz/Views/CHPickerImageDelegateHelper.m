//
//  CHPickerImageDelegateHelper.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/10/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "CHPickerImageDelegateHelper.h"

@interface CHPickerImageDelegateHelper()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL didSelectValueSelector;
@property (nonatomic) float maxWidth;
@end
@implementation CHPickerImageDelegateHelper
-(instancetype)initWithArray:(NSArray<NSString*>*)array{
    
    self = [super init];
    
    if(!self) return nil;
    
    self.array = array;
    
    return self;
    
}
+(instancetype)delegateWithArray:(NSArray<NSString*>*)array target:(id)target didSelectValueSelector:(SEL)selector{
    CHPickerImageDelegateHelper *delegate = [[CHPickerImageDelegateHelper alloc] initWithArray:array];
    delegate.target = target;
    delegate.didSelectValueSelector = selector;
    return delegate;
}
#pragma mark - Picker datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.array.count;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *pickerCustomView = (id)view;
    UILabel *pickerViewLabel;
    UIImageView *pickerImageView;
    
    if (!pickerCustomView) {
        pickerCustomView= [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(pickerView.frame), 0.0f,self.maxWidth+30, [pickerView rowSizeForComponent:component].height)];
        
        pickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 17.0f, 17.0f)];
        pickerImageView.contentMode = UIViewContentModeScaleAspectFit;
        pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(25, -6.0f,self.maxWidth, [pickerView rowSizeForComponent:component].height)];
        // the values for x and y are specific for my example
        [pickerCustomView addSubview:pickerImageView];
        [pickerCustomView addSubview:pickerViewLabel];
    }
    
    pickerImageView.image = [UIImage imageNamed:_iconsArray[row]];
    pickerViewLabel.backgroundColor = [UIColor clearColor];
    pickerViewLabel.text = _array[row]; // where therapyTypes[row] is a specific example from my code
    pickerViewLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    
    return pickerCustomView;
}
#pragma mark - Picker delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([self.target respondsToSelector:self.didSelectValueSelector]){
        
        NSMethodSignature *signature = [[self.target class] instanceMethodSignatureForSelector:self.didSelectValueSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.selector = self.didSelectValueSelector;
        NSString *value = self.array[row];
        
        [invocation setArgument:&row atIndex:2];
        [invocation setArgument:&value atIndex:3];
        
        [invocation performSelector:@selector(invokeWithTarget:) withObject:self.target];
    }
}
-(void)calculateWidth {
    NSString *longestWord = nil;
    for(NSString *str in self.array) {
        if (longestWord == nil || [str length] > [longestWord length]) {
            longestWord = str;
        }
    }
    self.maxWidth = [self widthOfString:longestWord withFont:[UIFont fontWithName:@"Helvetika" size:20]];
}
- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    //NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGSize size = [string sizeWithAttributes:
                   @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:20]}];
    
    // Values are fractional -- you should take the ceilf to get equivalent values
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return adjustedSize.width;
}
@end
