//
//  ShareFacebook.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/12/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "ShareFacebook.h"
#import "CHUserToken.h"
#import <Social/Social.h>
#import "AlertView.h"

@implementation ShareFacebook
+(void)shareToTimeLineWithLink:(NSString*)link controller:(id)controller {
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    
    if(isInstalled) {
//        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//        content.contentURL = [NSURL URLWithString:link];
//        [FBSDKShareDialog showFromViewController:controller
//                                     withContent:content
//                                        delegate:nil];
    }
    else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [mySLComposerSheet setInitialText:link];
            
            [mySLComposerSheet addURL:[NSURL URLWithString:link]];
            
            [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Post Canceled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Post Sucessful");
                        break;
                        
                    default:
                        break;
                }
            }];
            
            [controller presentViewController:mySLComposerSheet animated:YES completion:nil];
        }
        else {
            [AlertView showAlertViewWithTitle:NSLocalizedString(@"Login Required", nil) message:NSLocalizedString(@"Please add your account under settings menu of your phone", nil) controller:controller];
        }
    }
}
+(void)sendToMessengerWithLink:(NSString*)link {
//    FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc]init];
//    content.contentURL = [NSURL URLWithString:link];
//    [FBSDKMessageDialog showWithContent:content delegate:nil];
}
+(void)shareTourToFacebook:(id)controller link:(NSString*)link {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Share with Facebook", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [controller dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share tour to timeline", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Distructive button tapped.
        //NSString* link = [NSString stringWithFormat:@"https://cheryz.com/user/invite/%@",[[CHUserToken sharedInstance] getUserID]];
        //[self dismissViewControllerAnimated:YES completion:^{
        [ShareFacebook shareToTimeLineWithLink:link controller:controller];
        //}];
    }]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send tour in Messenger", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // OK button tapped.
            //NSString* link = [NSString stringWithFormat:@"https://cheryz.com/user/invite/%@",[[CHUserToken sharedInstance] getUserID]];
            //[self dismissViewControllerAnimated:YES completion:^{
            [ShareFacebook sendToMessengerWithLink:link];
            //}];
        }]];
    }
    
    // Present action sheet.
    actionSheet.popoverPresentationController.sourceView = ((UIViewController*)controller).view;
    [controller presentViewController:actionSheet animated:YES completion:nil];
}
+(void)shareProductToFacebook:(id)controller link:(NSString*)link {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Share with Facebook", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [controller dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share product to timeline", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Distructive button tapped.
        //NSString* link = [NSString stringWithFormat:@"https://cheryz.com/user/invite/%@",[[CHUserToken sharedInstance] getUserID]];
        //[self dismissViewControllerAnimated:YES completion:^{
        [ShareFacebook shareToTimeLineWithLink:link controller:controller];
        //}];
    }]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send product in Messenger", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // OK button tapped.
            //NSString* link = [NSString stringWithFormat:@"https://cheryz.com/user/invite/%@",[[CHUserToken sharedInstance] getUserID]];
            //[self dismissViewControllerAnimated:YES completion:^{
            [ShareFacebook sendToMessengerWithLink:link];
            //}];
        }]];
    }
    
    // Present action sheet.
    actionSheet.popoverPresentationController.sourceView = ((UIViewController*)controller).view;
    [controller presentViewController:actionSheet animated:YES completion:nil];
}
@end
