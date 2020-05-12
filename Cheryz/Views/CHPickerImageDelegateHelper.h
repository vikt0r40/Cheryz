//
//  CHPickerImageDelegateHelper.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/10/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CHPickerImageDelegateHelper : NSObject <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) NSArray<NSString*>*array;
@property (nonatomic, weak) NSArray<NSString*>*iconsArray;
//@property (nonatomic, copy) void ((^rowSelectHandler)(NSInteger row, NSString *text));
//-(instancetype)initWithArray:(NSArray<NSString*>*)array;
+(instancetype)delegateWithArray:(NSArray<NSString*>*)array target:(id)target didSelectValueSelector:(SEL)selector;
-(void)calculateWidth;
@end
