//
//  CHDatePickerField.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/13/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHBindableTextField.h"

@interface CHDatePickerField : CHBindableTextField

@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSDateFormatterStyle dateStyle;
@property (nonatomic) NSDateFormatterStyle timeStyle;
@property (nonatomic, strong) NSDate* minDate;
@property (nonatomic, strong) UIDatePicker *datePicker;
@end
