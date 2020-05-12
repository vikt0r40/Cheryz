//
//  CHPickerDelegateHelper.h
//  Cheres
//
//  Created by Azarnikov Vadim on 5/9/16.
//  Copyright © 2016 Flexbricks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CHPickerDelegateHelper : NSObject <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) NSArray<NSString*>*array;
//@property (nonatomic, copy) void ((^rowSelectHandler)(NSInteger row, NSString *text));
//-(instancetype)initWithArray:(NSArray<NSString*>*)array;
+(instancetype)delegateWithArray:(NSArray<NSString*>*)array target:(id)target didSelectValueSelector:(SEL)selector;
@end
