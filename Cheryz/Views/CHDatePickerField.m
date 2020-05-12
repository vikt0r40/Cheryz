//
//  CHDatePickerField.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 10/13/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CHDatePickerField.h"
#import "UIColor+Cheryz.h"

@interface CHDatePickerField()<UITextFieldDelegate>


@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CHDatePickerField

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if(!self)
        return nil;
    
    [self addTarget:self action:@selector(updateDateValue) forControlEvents:UIControlEventEditingDidBegin];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateStyle = NSDateFormatterMediumStyle;
    self.timeStyle = NSDateFormatterShortStyle;

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.minimumDate = self.minDate;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(updateDateValue) forControlEvents:UIControlEventValueChanged];
    self.inputView = self.datePicker;
    self.inputAccessoryView = [self chooseAccessoryView];
//    self.delegate = self;
    return self;
}
-(UIView *)chooseAccessoryView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40.)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Choose" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 1, view.bounds.size.width, view.bounds.size.height)];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:button];
    button.tintColor = [UIColor cheryzRed];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(chooseAccessoryAction) forControlEvents:UIControlEventTouchUpInside];
    view.backgroundColor = [UIColor cheryzGray];
    return view;
}
-(void)chooseAccessoryAction{
    [self resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self updateDateValue];
    return YES;
}
-(void)setDateStyle:(NSDateFormatterStyle)dateStyle{
    
    _dateStyle = dateStyle;
    
    [self.dateFormatter setDateStyle:_dateStyle];
    
}

-(void)setTimeStyle:(NSDateFormatterStyle)timeStyle{

    _timeStyle = timeStyle;
    
    [self.dateFormatter setTimeStyle:_timeStyle];
    
}

-(void)updateDateValue{
    self.date = self.datePicker.date;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.text = [self.dateFormatter stringFromDate:self.date];
    });
    

    [self.bindTarget setValue:self.date forKey:self.bindKey];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
@end
