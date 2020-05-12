//
//  SipManager.m
//  Cheryz-iOS
//
//  Created by Azarnikov Vadim on 2/20/17.
//  Copyright © 2017 Cheryz. All rights reserved.
//

#import "SipManager.h"
#import "RealtimeManagerHelper.h"
#include <pjsua-lib/pjsua.h>
#import "SipSettings.h"
#import <AVFoundation/AVFoundation.h>
//#import <VideoCore/api/iOS/SIPAudioBuffer.h>
//#import <VideoCore/api/iOS/VCSimpleSession.h>
//#import <VideoCore/api/iOS/VoiceExchangeManager.h>

#pragma mark - Audio input change

NSString * const kSipDidConnectNotification = @"SipDidConnectNotification";
NSString * const kSipDidDisconnectNotification = @"SipDidDisconnectNotification";
NSString * const kSipIncommingCallNotification = @"SipIncommingCallNotification";
NSString * const kSipActiveCallNotification = @"SipActiveCallNotification";
NSString * const kSipErrorNotification = @"SipErrorNotification";



@interface AudioManager : NSObject

+(instancetype) sharedInstance;

@property (nonatomic) BOOL isConnected;

@end

@implementation AudioManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static AudioManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.isConnected = NO;
    });
    return sharedInstance;
}


-(void)setIsConnected:(BOOL)isConnected{
    
    if(isConnected != _isConnected){
        
        _isConnected = isConnected;
        
        NSString *mode = isConnected ? AVAudioSessionModeVideoChat : AVAudioSessionModeDefault;
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        BOOL success = [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        [session setMode:mode error:&error];
//        BOOL success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
//                                       mode:mode options:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        success = [session setActive:YES error:&error];
        
    }
    
}
@end

#pragma mark - Sip Manager

@interface SipManager ()
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic) void * buffer;
@property (nonatomic) pj_caching_pool cp;
@property (nonatomic) pj_pool_t *pool;

@property (nonatomic) pjmedia_port *media_port;
@property (nonatomic) pjsua_conf_port_id listen_port;

@property (nonatomic) pjsua_acc_id acc_id;
@property (nonatomic, strong) SipSettings *settings;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation SipManager

pjsua_conf_port_id pjsipConfAudioId;

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
                             pjsip_rx_data *rdata)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pjsua_call_get_info(call_id, &ci);
    
    
    /* Automatically answer incoming calls with 200/OK */
    pjsua_call_answer(call_id, 200, NULL, NULL);
    [[NSNotificationCenter defaultCenter] postNotificationName:kSipIncommingCallNotification object:nil];
}

/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(e);
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.state == PJSIP_INV_STATE_CONNECTING) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSipDidConnectNotification object:nil];
    } else if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSipDidDisconnectNotification object:nil];
    }
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsipConfAudioId = ci.conf_slot;
        pjsua_conf_adjust_tx_level(pjsipConfAudioId, [SipManager sharedInstance].isMute ? 0. : 1.);
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSipActiveCallNotification object:nil];
        
        
    }
    
}
pj_status_t cpa_fft_got_data(pjmedia_port *port, void *usr_data)
{
    
    if([SipManager sharedInstance].isMute)
        return PJ_SUCCESS;
    
    pj_size_t size = pjmedia_mem_capture_get_size(port);
//    SIPAudioBuffer *bfr = [SIPAudioBuffer new];
//
//    bfr.data = malloc(size);
//    bfr.data_size = size;
//    bfr.inNumberFrames = (int)(size/4);
//    memcpy(bfr.data, usr_data, size);
//    [[VoiceExchangeManager sharedObject] notifyAboutNewBuffer:bfr];
    
    return PJ_SUCCESS;
}

+(instancetype) sharedInstance{
    static SipManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [SipManager new];
        manager.queue = dispatch_queue_create("com.cheryz.SipQueue", NULL);
        manager.state = SipStateNone;
        manager.lock = [NSLock new];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(wasConnected) name:kSipDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(wasDisconnected) name:kSipDidDisconnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(InitRecorder) name:kSipActiveCallNotification object:nil];

    });
    return manager;
}

-(NSString *)stateStr:(SipState)state{
    switch (state) {
        case SipStateNone:
            return @"None";
        case SipStateOnCall:
            return @"Online";
        case SipStateReadyForCall:
            return @"Ready broadcast";
        case SipStateCallEnded:
            return @"Stopped";
        case SipStateCallEnding:
            return @"Stopping";
        case SipStateDestroying:
            return @"Destroying";
        case SipStateInitializing:
            return @"Initializing";
        case SipStateStartingCall:
            return @"Starting Broadcast";
        case SipStateError:
            return @"Error";
        default:
            return @"<nothing>";
    }
}

-(void)setTargetState:(SipState)targetState{
    
    if(_targetState == targetState){
        return;
    }
    
    _targetState = targetState;
    NSLog(@"Sip target state %@ -> %@",[self stateStr:_state],[self stateStr:_targetState]);
    [self makeSteps];
}
-(void)makeSteps{
    dispatch_async(self.queue, ^{
        
        if(self.state != self.targetState){
            
            switch (self.state) {
                    
                case SipStateNone:
                    [self stepAfterNone];
                    break;
                    
                case SipStateReadyForCall:
                    [self stepAfterReady];
                    break;
                    
                case SipStateOnCall:
                    [self stepAfterOnline];
                    break;
                case SipStateError:
                    [self stepAfterError];
                default:
                    break;
            }
            
        }
    });
}

-(BOOL)targetIn:(NSUInteger) mask{
    return (mask&self.targetState) == self.targetState;
}

-(void)stepAfterNone{
    if([self targetIn:SipStateReadyForCall | SipStateOnCall]){
        [self initialize];
    }
}

-(void)stepAfterReady{
    if([self targetIn:SipStateOnCall]){
        [self call];
    } else if([self targetIn:SipStateNone]){
        [self destroy];
    }
}

-(void)stepAfterOnline{
    if([self targetIn: SipStateCallEnded | SipStateReadyForCall | SipStateNone]){
        [self endCall];
    }
}

-(void)stepAfterError{
    if([self targetIn: SipStateOnCall | SipStateReadyForCall]){
        self.state = SipStateReadyForCall;
    }
}

-(void)setSettingsDictionary:(NSDictionary *)settingsDictionary{
    _settingsDictionary = settingsDictionary;
    self.settings = [SipSettings settingsFromDictionary:self.settingsDictionary];
}

-(void)InitRecorder {
    /// recorder )))
    pjsua_call_info ci;
    pj_status_t status;
    
    pjsua_call_get_info(_acc_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        
        status = pjsua_conf_add_port(_pool,_media_port,&_listen_port);
        if (status != PJ_SUCCESS) [self errorHandler:@"Error in init_recorder"];
        status = pjsua_conf_connect(0,_listen_port);
        if (status != PJ_SUCCESS) [self errorHandler:@"Error in init_recorder"];
        status = pjsua_conf_connect(ci.conf_slot,_listen_port);
        if (status != PJ_SUCCESS) [self errorHandler:@"Error in init_recorder"];
        if (status == PJ_SUCCESS){
            
        }
        pjsipConfAudioId = ci.conf_slot;
        [self updateMicVolume];
    }
    
}

-(void)CloseRecorder {
    
    pjsua_call_info ci;
    pjsua_call_get_info(_acc_id, &ci);
    if (_pool!=NULL && _listen_port!=0) {
        pjsipConfAudioId = 0;
        pjsua_conf_disconnect(0,_listen_port);
        pjsua_conf_disconnect(ci.conf_slot,_listen_port);
        pjsua_conf_remove_port(_listen_port);
        
    }
    
    if (_media_port) pjmedia_port_destroy(_media_port);
    _media_port = NULL;
    if (_pool) {
        pj_pool_release(_pool);
        _pool = NULL;
        pj_caching_pool_destroy(&_cp);
        
    }
    
    
}

-(void)wasConnected{
    
    [AudioManager sharedInstance].isConnected = YES;
    [self updateMicVolume];
    self.state = SipStateOnCall;
    
    
}
-(void)wasDisconnected{
    
    
    [self CloseRecorder];
    
    [AudioManager sharedInstance].isConnected = NO;
    if(self.state == SipStateCallEnding){
        self.state = SipStateCallEnded;
    }
    self.state = SipStateReadyForCall;
    
}

-(void)initialize{

    if(!self.settings){
        return;
    }
    
    if(self.state!=SipStateNone){
        return;
    }
    
    self.state = SipStateInitializing;
    
    pj_status_t status;
    status = [self setup];
    
    if(status!=PJ_SUCCESS){
        [self errorHandler:nil];
        return;
    }
    
    self.state = SipStateReadyForCall;
}

-(void)call{
    
    if(self.state!=SipStateReadyForCall){
        return;
    }
    
    self.state = SipStateStartingCall;
    
    pj_status_t status;
    status = [self pjCall];
    
    if(status!=PJ_SUCCESS){
        [self errorHandler:nil];
        return;
    }
    
}

-(void)endCall{
    if(self.state==SipStateOnCall || self.state==SipStateStartingCall){
        self.state = SipStateCallEnding;
        [self pjEndCall];
        if(self.state != SipStateReadyForCall){
            self.state = SipStateCallEnded;
        }
    }
}

-(void)destroy{
    if(self.state != SipStateNone
       && self.state !=  SipStateInitializing){
        [self pjThreadAutoRegister];
        self.state = SipStateDestroying;
        pjsua_destroy();
        self.state = SipStateNone;
    }
}
-(int)pjCall{
    int MEMSIZE = 4096;
    
    [self pjThreadAutoRegister];
    
    pj_status_t status;
    pj_str_t uri = pj_str((char *)[[NSString stringWithFormat:@"sip:%@@%@:%ld",self.settings.tourID,self.settings.domain, (long)[self.settings.port integerValue]] UTF8String]);
    
    status = pjsua_call_make_call(_acc_id, &uri, 0, NULL, NULL, NULL);
    if (status != PJ_SUCCESS) {
        return status;
    }
    
    // Init record
    if (_pool == NULL || _buffer==NULL) {
        pj_caching_pool_init(&_cp, NULL, 64*1024 );
        _pool = pj_pool_create(&_cp.factory, NULL, PJ_POOL_SIZE+MEMSIZE, MEMSIZE, NULL);
        if (_pool==NULL) {
            return -1;
        }
        _buffer = (char*)pj_pool_alloc(_pool, MEMSIZE*sizeof(char));
        status = pjmedia_mem_capture_create(_pool,_buffer,MEMSIZE,44100,2,882,16,0,&_media_port);
        if (status != PJ_SUCCESS) {
            return status;
        }
        status = pjmedia_mem_capture_set_eof_cb(_media_port,_buffer,cpa_fft_got_data);
        if (status != PJ_SUCCESS) {
            return status;
        }
    }
    
    
    return status;
}
-(void)pjEndCall{
    [self pjThreadAutoRegister];
    pjsua_call_hangup_all();
}
-(NSInteger)pjThreadAutoRegister{
    pj_status_t rc;
    
    if(!pj_thread_is_registered())
    {
        pj_thread_desc *p_thread_desc;
        pj_thread_t* thread_ptr;
        p_thread_desc = (pj_thread_desc *) calloc(1,
                                                  sizeof(pj_thread_desc));
        rc = pj_thread_register("auto_thr%p", *p_thread_desc, &thread_ptr);
    }
    else
    {
        rc = PJ_SUCCESS;
    }
    return rc;
}

-(int)setup{
    [self pjThreadAutoRegister];
    
    pj_status_t status;
    
    // Create pjsua first
    status = pjsua_create();
    if (status != PJ_SUCCESS){
        return -1;
    }
    
    // Init pjsua
    {
        // Init the config structure
        pjsua_config cfg;
        pjsua_config_default (&cfg);
        
        cfg.cb.on_incoming_call = &on_incoming_call;
        cfg.cb.on_call_media_state = &on_call_media_state;
        cfg.cb.on_call_state = &on_call_state;
        // Init the logging config structure
        pjsua_logging_config log_cfg;
        pjsua_logging_config_default(&log_cfg);
        log_cfg.console_level = 0;
        
        // Init the pjsua
        status = pjsua_init(&cfg, &log_cfg, NULL);
        if (status != PJ_SUCCESS){
            return -1;
        }
    }
    
    // Add UDP transport.
    {
        // Init transport config structure
        pjsua_transport_config cfg;
        pjsua_transport_config_default(&cfg);
        cfg.port = 5080;
        
        // Add TCP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
        if (status != PJ_SUCCESS){
            return -1;
        }
    }
    
    // Add TCP transport.
    {
        // Init transport config structure
        pjsua_transport_config cfg;
        pjsua_transport_config_default(&cfg);
        cfg.port = 5080;
        
        // Add TCP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &cfg, NULL);
        if (status != PJ_SUCCESS){
            return -1;
        }
    }
    
    // Initialization is done, now start pjsua
    status = pjsua_start();
    if (status != PJ_SUCCESS) {
        return -1;
    }
    
    // Register the account on local sip server
    {
        pjsua_acc_config cfg;
        
        pjsua_acc_config_default(&cfg);
        
        //        char sipId[MAX_SIP_ID_LENGTH];
        //        sprintf(sipId, "sip:%s@%s", sipUser, sipDomain);
        //        cfg.id = pj_str(sipId);
        //
        //        char regUri[MAX_SIP_REG_URI_LENGTH];
        //        sprintf(regUri, "sip:%s", sipDomain);
        //        cfg.reg_uri = pj_str(regUri);
        //
        //        status = pjsua_acc_add(&cfg, PJ_TRUE, &acc_id);
        //        if (status != PJ_SUCCESS) error_exit("Error adding account", status);
        //char *cfg_id[100];
        NSString *cfg_id = [NSString stringWithFormat:@"sip:%@@%@",self.settings.user,self.settings.domain];
        NSString *cfg_reg_uri = [NSString stringWithFormat:@"sip:%@:%d",self.settings.domain, [self.settings.port intValue]];
        
        cfg.id = pj_str((char *)[cfg_id UTF8String]);
        cfg.reg_uri = pj_str((char *)[cfg_reg_uri UTF8String]);
        cfg.cred_count = 1;
        cfg.cred_info[0].realm = pj_str((char *)[self.settings.realm UTF8String]);
        cfg.cred_info[0].scheme = pj_str("digest");
        cfg.cred_info[0].username = pj_str((char *)[self.settings.user UTF8String]);
        cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        cfg.cred_info[0].data = pj_str((char *)[self.settings.pass UTF8String]);
        
        status = pjsua_acc_add(&cfg, PJ_TRUE, &_acc_id);
        if (status != PJ_SUCCESS) {
            return -1;
        }
        
    }
    return PJ_SUCCESS;
}

-(void)errorHandler:(NSString *)error{
    self.state = SipStateError;
}
-(void)setState:(SipState)state{
    if(_state == state){
        return;
    }
    NSLog(@"Sip state updated to %@",[self stateStr:state]);
    
    SipState previousState = self.state;
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
    [RealtimeManagerHelper updateSipState:self.state];
    if([self.delegate respondsToSelector:@selector(sipStateIsChangedFrom:to:)]){
        [self.delegate sipStateIsChangedFrom:previousState to:self.state];
    }
    [self makeSteps];
}
-(BOOL)canInitialize{
    return self.state == SipStateNone;
}
-(BOOL)canCall{
    return self.state == SipStateReadyForCall;
}
-(BOOL)canEndCall{
    return self.state == SipStateOnCall || self.state == SipStateStartingCall;
}
-(BOOL)canDestroy{
    return !(self.state == SipStateNone || self.state == SipStateInitializing);
}
-(void)setMute:(BOOL)mute{
    _mute = mute;
    [self updateMicVolume];
}
-(void)updateMicVolume{
    if(pjsipConfAudioId>0){
        [self pjThreadAutoRegister];
        pjsua_conf_adjust_tx_level(pjsipConfAudioId, self.isMute ? 0. : 1.);
    }
}
@end
