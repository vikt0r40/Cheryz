//
//  CHPickerImageField.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 2/10/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "CHPickerImageField.h"
#import "CHPickerImageDelegateHelper.h"
#import "UIColor+Cheryz.h"

@interface CHPickerImageField()
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) CHPickerImageDelegateHelper *pickerDelegate;
@end

@implementation CHPickerImageField

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if(!self)
        return nil;
    
    self.pickerDelegate = [CHPickerImageDelegateHelper delegateWithArray:nil target:self didSelectValueSelector:@selector(didSelectIndex:andValue:)];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource = self.pickerDelegate;
    self.pickerView.delegate = self.pickerDelegate;
    self.inputView = self.pickerView;
    
    self.selectedIndex = -1;
    self.selectedValue = nil;
    self.inputAccessoryView = [self chooseAccessoryView];
    
    [self addTarget:self action:@selector(editingDidBegin) forControlEvents:UIControlEventEditingDidBegin];
    
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
-(void)setSourceArray:(NSArray *)sourceArray{
    _sourceArray = sourceArray;
    self.pickerDelegate.array = _sourceArray;
    [self.pickerDelegate calculateWidth];
    [self.pickerView reloadAllComponents];
}
-(void)setIconsArray:(NSArray *)iconsArray {
    _iconsArray = iconsArray;
    self.pickerDelegate.iconsArray = _iconsArray;
    [self.pickerView reloadAllComponents];
}
-(void)didSelectIndex:(NSInteger)index andValue:(NSString*)value{
    self.selectedIndex = index;
}

-(void)editingDidBegin{
    if((self.selectedIndex==-1) && self.sourceArray.count>0){
        self.selectedIndex = 0;
    }
    if(self.selectedIndex != [self.pickerView selectedRowInComponent:0]){
        [self.pickerView selectRow:self.selectedIndex inComponent:0 animated:NO];
    }
}

-(void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    self.selectedValue = self.sourceArray[selectedIndex];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.text = self.selectedValue;
    });
    [self.bindTarget setValue:@(self.selectedIndex) forKey:self.bindKey];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
