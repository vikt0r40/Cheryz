//
//  AboutContentTableViewController.h
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 10/31/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHPickerField.h"
#import "CHDatePickerField.h"
#import "CHBindableTextField.h"
#import "CHImagePickerCollectionView.h"
#import "Tour.h"
#import <MapKit/MapKit.h>
#import "CHChecksCollectionView.h"

@interface AboutContentTableViewController : UITableViewController
@property (nonatomic, strong) Tour *tour;
@property (weak, nonatomic) IBOutlet CHBindableTextField *priceTextField;
@property (weak, nonatomic) IBOutlet CHBindableTextField *durationTextField;
- (IBAction)visitWebsite:(id)sender;

//Mandatory
@property (strong, nonatomic) IBOutlet CHBindableTextField *titleTextField;
@property (strong, nonatomic) IBOutlet CHBindableTextField *shopperFullName;
@property (strong, nonatomic) IBOutlet CHDatePickerField *tourDatePickerField;
@property (strong, nonatomic) IBOutlet CHPickerField *languagePickerField;
@property (strong, nonatomic) IBOutlet UILabel *shoppingTourLocationLabel;
@property (strong, nonatomic) IBOutlet CHPickerField *typePickerField;

//Additional
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet CHBindableTextField *minBuyersCountTextField;
@property (strong, nonatomic) IBOutlet CHBindableTextField *maxBuyersCountTextField;
@property (strong, nonatomic) IBOutlet UILabel *deliveryLocationLabel;
@property (strong, nonatomic) IBOutlet CHDatePickerField *deliveryFromDatePickerField;
@property (strong, nonatomic) IBOutlet CHDatePickerField *deliveryToDatePickerField;
@property (strong, nonatomic) IBOutlet CHPickerField *accessTypePickerField;
@property (strong, nonatomic) IBOutlet UIImageView* accessTypeIcon;
@property (strong, nonatomic) IBOutlet CHImagePickerCollectionView *imagePickerCollectionView;
@property (strong, nonatomic) IBOutlet CHChecksCollectionView *checksCollectionView;
@property (strong, nonatomic) IBOutlet MKMapView* map;
@property (strong, nonatomic) IBOutlet UILabel* streetAddress;
@property (strong, nonatomic) id coordinator;
@property (nonatomic) BOOL isShopper;
@end
