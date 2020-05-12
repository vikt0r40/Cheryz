//
//  RequestPrivateTourViewController.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 05.04.2020.
//  Copyright © 2020 Cheryz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RequestPrivateTourViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIPickerView* dateView;
@property (nonatomic, strong) IBOutlet UIPickerView* timeView;
@end

