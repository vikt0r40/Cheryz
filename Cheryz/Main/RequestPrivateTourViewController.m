//
//  RequestPrivateTourViewController.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 05.04.2020.
//  Copyright © 2020 Cheryz. All rights reserved.
//

#import "RequestPrivateTourViewController.h"
#import "ToursAPI.h"
#import "TimeTour.h"

@interface RequestPrivateTourViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) NSMutableArray* timeArray;
@property (nonatomic, strong) NSString* dateSelected;
@property (nonatomic, strong) NSString* timeSelected;
@property (nonatomic, strong) NSMutableArray* requests;
@end

@implementation RequestPrivateTourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.requests = [NSMutableArray new];
    [ToursAPI loadRequestTranslation:^(NSDictionary *response) {
        for (NSDictionary* request in response[@"requests"]) {
            TimeTour* t = [TimeTour timeTourFromDict:request];
            [self.requests addObject:t];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
    self.dateView.dataSource = self;
       self.dateView.delegate = self;
       self.timeView.dataSource = self;
       self.timeView.delegate = self;
       [self.dateView reloadAllComponents];
       [self setDefaultValueOfDate];
       [self setDefaultValueOfTime];
}

-(NSArray*)setDatePicker {
    NSMutableArray* dates = [NSMutableArray new];
    NSDateFormatter* dateF = [NSDateFormatter new];
    dateF.dateFormat = @"E, d MMM y";
    
    NSDate* now = [NSDate date];
    [dates addObject:@"Today"];
    
    for(int i = 0; i < 60; i++) {
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = i;
        NSDate* d = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:now options:0];
        [dates addObject:[dateF stringFromDate:d]];
    }
    
    return [dates copy];
}
-(NSArray*)setTimePicker {
    NSMutableArray* dates = [NSMutableArray new];
    NSDateFormatter* dateF = [NSDateFormatter new];
    dateF.dateFormat = @"h:mm a";
    
    NSDate* now = [self beginningOfDay:[NSDate date]];
    
    for(int i = 0; i < 73; i++) {
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.minute = 15;
        now = [[NSCalendar currentCalendar] dateByAddingComponents:dayComponent toDate:now options:0];
        [dates addObject:[dateF stringFromDate:now]];
    }
    
    return [dates copy];
}
-(NSDate *)beginningOfDay:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [components setHour:5];
    [components setMinute:45];
    [components setSecond:0];
    return [calendar dateFromComponents:components];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView.tag == 1) {
        return [[self setDatePicker] count];
    } else {
        return [[self setTimePicker] count];
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(pickerView.tag == 1) {
        return [self setDatePicker][row];
    } else {
        return [self setTimePicker][row];
    }
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if(pickerView.tag == 1) {
        if([[self setDatePicker][row] isEqualToString:@"Today"]) {
            [self setDefaultValueOfDate];
        } else {
            self.dateSelected = [self setDatePicker][row];
        }
    } else {
        self.timeSelected = [self setTimePicker][row];
    }
    
}
-(void)setDefaultValueOfDate {
    NSDateFormatter* dateF = [NSDateFormatter new];
    dateF.dateFormat = @"E, d MMM y";
    NSDate* now = [NSDate date];
    self.dateSelected = [dateF stringFromDate:now];
}
-(void)setDefaultValueOfTime {
    NSDateFormatter* dateF = [NSDateFormatter new];
    dateF.dateFormat = @"h:mm a";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    [components setHour:6];
    [components setMinute:00];
    [components setSecond:0];
    NSDate* dateNow = [calendar dateFromComponents:components];
    self.timeSelected = [dateF stringFromDate:dateNow];
}
-(IBAction)requestAction:(id)sender {
    NSDateFormatter* dateF = [NSDateFormatter new];
    dateF.dateFormat = @"E, d MMM y h:mm a";
    NSDate* selectedDate = [dateF dateFromString:[NSString stringWithFormat:@"%@ %@",self.dateSelected, self.timeSelected]];
    NSLog(@"%@",[dateF stringFromDate:selectedDate]);
}


@end
