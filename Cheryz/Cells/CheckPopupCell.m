//
//  CheckPopupCell.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/10/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "CheckPopupCell.h"

@implementation CheckPopupCell
-(void)prepareForReuse{
    self.imageView.image = nil;
}
-(IBAction)close:(id)sender{
    if([self.delegate respondsToSelector:@selector(closeCheckPopupCell:)]){
        [self.delegate closeCheckPopupCell:self];
    }
}
@end
