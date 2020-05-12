//
//  CHPickerDelegateHelper.m
//  Cheres
//
//  Created by Azarnikov Vadim on 5/9/16.
//  Copyright © 2016 Flexbricks. All rights reserved.
//

#import "CHPickerDelegateHelper.h"

@interface CHPickerDelegateHelper ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL didSelectValueSelector;
@end

@implementation CHPickerDelegateHelper

-(instancetype)initWithArray:(NSArray<NSString*>*)array{
    
    self = [super init];

    if(!self) return nil;
    
    self.array = array;
    
    return self;

}
+(instancetype)delegateWithArray:(NSArray<NSString*>*)array target:(id)target didSelectValueSelector:(SEL)selector{
    CHPickerDelegateHelper *delegate = [[CHPickerDelegateHelper alloc] initWithArray:array];
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
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.array[row];
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

@end
