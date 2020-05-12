//
//  CHPickerField.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/13/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHBindableTextField.h"

@interface CHPickerField : CHBindableTextField
@property (nonatomic, strong) NSArray *sourceArray;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSString *selectedValue;
@end
