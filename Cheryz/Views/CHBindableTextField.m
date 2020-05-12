//
//  CHBindableTextField.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/13/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHBindableTextField.h"

@implementation CHBindableTextField{
    BOOL isBindNumber;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(!self)
        return nil;
    if([self isMemberOfClass:[CHBindableTextField class]])
        [self addTarget:self action:@selector(editingChange) forControlEvents:UIControlEventEditingChanged];
    self.delegate = self;
    return self;
}

-(void)editingChange{
    id value;
    if(isBindNumber){
        value = @([self.text integerValue]);
    }else{
        value = self.text;
    }
    [self.bindTarget setValue:value forKey:self.bindKey];
}

-(void)bindValueToTarget:(id)target andKey:(NSString*)key{
    self.bindTarget = target;
    self.bindKey = key;
    isBindNumber = NO;
}
-(void)bindNumberToTarget:(id)target andKey:(NSString *)key{
    [self bindValueToTarget:target andKey:key];
    isBindNumber = YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // only when adding on the end of textfield && it's a space
    if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        // ignore replacement string and add your own
        textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        return NO;
    }
    // for all other cases, proceed with replacement
    return YES;
}
@end
