//
//  CHPickerImageField.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/10/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "CHBindableTextField.h"

@interface CHPickerImageField : CHBindableTextField
@property (nonatomic, strong) NSArray *sourceArray;
@property (nonatomic, strong) NSArray *iconsArray;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSString *selectedValue;
@end
