//
//  InfoRequestCell.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 12/4/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "InfoRequestCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+Cheryz.h"

@interface InfoRequestCell ()
@property (nonatomic, strong) CALayer *fingerprintLayer;
@end

@implementation InfoRequestCell

-(void)prepareForReuse{
    self.productImage.image = nil;
    self.userName.text = @"";
}
-(CALayer *)fingerprintLayer{
    if(!_fingerprintLayer){
        self.fingerprintLayer = [CALayer layer];
        self.fingerprintLayer.cornerRadius = 15;
        self.fingerprintLayer.frame = CGRectMake(0, 0, 30, 30);
        self.fingerprintLayer.backgroundColor = [UIColor cheryzRed].CGColor;
        self.fingerprintLayer.opacity = 0.5;
        self.fingerprintLayer.hidden = true;
        [self.productImage.layer addSublayer:self.fingerprintLayer];
    }
    return _fingerprintLayer;
}
-(CGPoint)processFingerprintLayerPosition:(CGPoint)position{
    CGSize size = self.productImage.frame.size;
    CGFloat xk = size.width/480.;
    CGFloat yk = size.height/640.;
    
    return CGPointMake(xk*position.x, yk*position.y);
}
-(void)layoutSubviews{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fingerprintLayer.position = [self processFingerprintLayerPosition:self.infoRequest.point];
    });
}
-(void)setInfoRequest:(InfoRequest *)infoRequest{
    
    _infoRequest = infoRequest;
    
    self.fingerprintLayer.position = [self processFingerprintLayerPosition:infoRequest.point];
    if(_infoRequest.imageURL){
        [self.productImage setImageWithURL:[NSURL URLWithString:_infoRequest.imageURL]];
    }else if(_infoRequest.image){
        [self.productImage setImage:_infoRequest.image];
    }
    self.userName.text = [NSString stringWithFormat:@"%@:",_infoRequest.username];
}
-(IBAction)accept:(id)sender{
    if([self.delegate respondsToSelector:@selector(acceptInfoRequestAtCell:)]){
        [self.delegate acceptInfoRequestAtCell:self];
    }
}
-(IBAction)decline:(id)sender{
    if([self.delegate respondsToSelector:@selector(declineInfoRequestAtCell:)]){
        [self.delegate declineInfoRequestAtCell:self];
    }
}
-(IBAction)didClickClose:(id)sender {
    if([self.delegate respondsToSelector:@selector(didCLickCloseButton)]){
        [self.delegate didCLickCloseButton];
    }
}
@end
