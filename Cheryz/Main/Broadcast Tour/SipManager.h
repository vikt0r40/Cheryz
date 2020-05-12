//
//  SipManager.h
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 2/20/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    SipStateNone            = 1 << 0,
    SipStateInitializing    = 1 << 1,
    SipStateReadyForCall    = 1 << 2,
    SipStateStartingCall    = 1 << 3,
    SipStateOnCall          = 1 << 4,
    SipStateCallEnding      = 1 << 5,
    SipStateCallEnded       = 1 << 6,
    SipStateDestroying      = 1 << 7,
    SipStateError           = 1 << 8
} SipState;

@protocol SipManagerDelegte <NSObject>

-(void)sipStateIsChangedFrom:(SipState)oldState
                          to: (SipState)newState;
@end

@interface SipManager : NSObject

@property (nonatomic, weak) id <SipManagerDelegte> delegate;
@property (nonatomic, readonly) SipState state;

+(instancetype)sharedInstance;
@property (nonatomic, strong) NSDictionary *settingsDictionary;
@property (nonatomic) SipState targetState;
@property (nonatomic, getter=isMute) BOOL mute;
@end
