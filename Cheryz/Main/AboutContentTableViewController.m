//
//  AboutContentTableViewController.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "AboutContentTableViewController.h"
#import "CHUserToken.h"
#import "LiveCommandClient+TourCommands.h"
#import "GetTourByIDAPIClient.h"

@interface AboutContentTableViewController () <UITableViewDelegate>
@property (nonatomic, strong) NSArray *checks;
@end

@implementation AboutContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    
    [GetTourByIDAPIClient getTourWithID:self.tour.guid success:^(NSDictionary *response) {
        self.tour = [Tour tourWithDict:response];
        [self loadTourInformation];
      } failure:^(NSError *error) {
          
      }];
    if(self.isShopper) {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell removeFromSuperview];
    }
    
    self.checksCollectionView.delegate = self.coordinator;
//    if([self.checksCollectionView.delegate isKindOfClass:[ShopperTourCoordinator class]] || [self.checksCollectionView.delegate isKindOfClass:[ShopperFinishedTourCordinator class]]) {
//        self.checksCollectionView.isAuthor = YES;
//    }
    
        self.checksCollectionView.isAuthor = NO;
    
    self.checksCollectionView.checks = self.checks;
    [self.checksCollectionView reloadTheData];
    
}
-(void)willLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedChecks:) name:kChecksInTourListenerKey object:nil];
}
-(void)willUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadTourInformation {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    self.shopperFullName.text = [NSString stringWithFormat:@"%@ %@",self.tour.owner[@"first_name"],self.tour.owner[@"last_name"]];
    self.titleTextField.text = self.tour.titleText;
    self.tourDatePickerField.text = [formatter stringFromDate:self.tour.date];
    self.languagePickerField.sourceArray = self.tour.availableLanguags;
    if(self.tour.language == TourLanguageNotSpecified) {
        self.tour.language = 0;
    }
    self.languagePickerField.selectedIndex = self.tour.language;
    self.languagePickerField.text = self.tour.availableLanguags[self.tour.language];
    NSLog(@"%@, %@", self.languagePickerField.text, self.tour.languageTitle);
    self.shoppingTourLocationLabel.text = [self.tour.location formattedAddress];
    self.typePickerField.sourceArray = self.tour.availableFilterTypes;
    [self.typePickerField setSelectedIndex:self.tour.type+1];
    self.typePickerField.text = self.tour.typeTitle;
    self.accessTypePickerField.sourceArray = self.tour.availableAccessTypes;
    self.accessTypePickerField.selectedIndex = self.tour.accessType;
    self.priceTextField.text = self.tour.price.formattedString;
    self.durationTextField.text = self.tour.duration.formated;
    UIImage *accessImage = nil;
    
    switch (self.tour.accessType) {
            
        case TourAccessTypeAll:
            accessImage = [UIImage imageNamed:@"public"];
            break;
            
        case TourAccessTypeOnlyForMe:
            accessImage = [UIImage imageNamed:@"lockicon"];
            break;
            
        case TourAccessTypeForFriends:
            accessImage = [UIImage imageNamed:@"friends"];
            break;
            
        case TourAccessTypeSpecificUsers:
            accessImage = [UIImage imageNamed:@"specifyuser"];
            break;
            
        default:
            break;
    }
    
    self.accessTypeIcon.image = accessImage;
    
    self.descriptionTextView.text = [self.tour.descriptionText isKindOfClass:[NSString class]]?self.tour.descriptionText:NSLocalizedString(@"Not specified", nil);
    self.minBuyersCountTextField.text = [NSString stringWithFormat:@"%@",(self.tour.minBuyersCount&&[self.tour.minBuyersCount integerValue]>=0)?self.tour.minBuyersCount:NSLocalizedString(@"Not specified", nil)];
    self.maxBuyersCountTextField.text = [NSString stringWithFormat:@"%@",(self.tour.maxBuyersCount&&[self.tour.maxBuyersCount integerValue]>=0)?self.tour.maxBuyersCount:NSLocalizedString(@"Not specified", nil)];
    

    if (self.tour.deliveryLocation == nil) {
        self.deliveryLocationLabel.text = NSLocalizedString(@"Not specified", nil);
    }
    else {
        self.deliveryLocationLabel.text = [self.tour.deliveryLocation formattedAddress];
    }
    
    if([self.tour.deliveryDateFrom timeIntervalSince1970] != 0) {
        self.deliveryFromDatePickerField.text = [formatter stringFromDate:self.tour.deliveryDateFrom];
    }
    else {
        self.deliveryFromDatePickerField.text = NSLocalizedString(@"Not specified", nil);
    }
    
    if([self.tour.deliveryDateTo timeIntervalSince1970] != 0) {
        self.deliveryToDatePickerField.text = [formatter stringFromDate:self.tour.deliveryDateTo];
    }
    else {
        self.deliveryToDatePickerField.text = NSLocalizedString(@"Not specified", nil);
    }
    
    self.imagePickerCollectionView.array = [self.tour.imagesURLArray mutableCopy];
    self.imagePickerCollectionView.isAuthor = NO;
    [self.imagePickerCollectionView reloadData];
    
    //Add pin to map
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinates = self.tour.location.coordinates;
    [annotation setCoordinate:coordinates];
    //[annotation setTitle:self.tour.titleText]; //You can set the subtitle too
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 3.01;
    span.longitudeDelta = 3.01;
    region.span = span;
    region.center = coordinates;
    
    [self.map addAnnotation:annotation];
    [self.map setRegion:region animated:TRUE];
    [self.map regionThatFits:region];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:self.tableView numberOfRowsInSection:section];
}
-(void)dealloc{
#if DEBUG
    if(!_map) return;
    // Xcode8/iOS10 MKMapView bug workaround
    static NSMutableArray* unusedObjects;
    if (!unusedObjects)
        unusedObjects = [NSMutableArray new];
    [unusedObjects addObject:_map];
#endif
}
- (void)receivedChecks:(NSNotification *)notification{
    self.checks = notification.object;
    self.checksCollectionView.checks = self.checks;
    [self.checksCollectionView reloadTheData];
}

- (IBAction)visitWebsite:(id)sender {
    NSURL* url = [[NSURL alloc] initWithString: self.tour.additionalInfoURL];
    [[UIApplication sharedApplication] openURL: url];
}
@end
