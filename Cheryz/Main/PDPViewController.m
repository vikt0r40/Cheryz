//
//  PDPViewController.m
//  CheryzSDK
//
//  Created by Viktor Todorov on 1.05.20.
//  Copyright © 2020 Viktor Todorov. All rights reserved.
//

#import "PDPViewController.h"

@interface PDPViewController ()

@end

@implementation PDPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view = self.customView;
    
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view = self.customView;
}

@end
