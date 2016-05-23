//
//  TCAVLiveViewController.m
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveViewController.h"


@implementation TCAVLiveBaseViewController

- (instancetype)initWith:(TCAVBaseViewController *)controller
{
    if (self = [super init])
    {
        _liveController = controller;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kClearColor;
}

- (void)onEnterBackground
{
    
}
- (void)onEnterForeground
{
    
}

- (void)setMsgHandler:(AVIMMsgHandler *)msgHandler
{
    _msgHandler = msgHandler;
    _msgHandler.roomIMListner = self;
}


// 收到群聊天消息: (主要是文本类型)
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvGroupMsg:(id<AVIMMsgAble>)msg
{
    // do nothing
    // overwrite by the subclass
}


// 收到C2C自定义消息
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomC2C:(id<AVIMMsgAble>)msg
{
    // do nothing
    // overwrite by the subclass
    
}

// 收到群自定义消息
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomGroup:(id<AVIMMsgAble>)msg
{
    // do nothing
    // overwrite by the subclass
    
}



// 群主解散群消息，或后台自动解散
- (void)onIMHandler:(AVIMMsgHandler *)receiver deleteGroup:(id<IMUserAble>)sender
{
    // do nothing
    // overwrite by the subclass
    
    if (![_liveController isExiting])
    {
        [_liveController willExitLiving];
        // 说明主播退出
        UIAlertView *alert =  [UIAlertView bk_showAlertViewWithTitle:nil message:@"直播群已解散" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [_liveController exitLive];
        }];
        [alert show];
    }
    
}

// 有新用户进入
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver joinGroup:(NSArray *)senders
{
    // do nothing
    // overwrite by the subclass
    
}

// 有用户退出
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver exitGroup:(NSArray *)senders
{
    // do nothing
    // overwrite by the subclass
    
}


@end

// ==========================================================

@implementation TCAVLiveViewController

- (void)dealloc
{
    _msgHandler = nil;
    
    [_livePreview stopPreview];
    _livePreview = nil;
}

+ (void)checkInitParam:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if (![user conformsToProtocol:@protocol(AVUserAble)])
    {
        DebugLog(@"因此类中要使用TCAVLiveRoomEngine，为保证其能正常使用，其传入的Host必须要实现AVUserAble");
        NSException *e = [NSException exceptionWithName:@"TCAVLiveRoomEngineHostInVailed" reason:@"必须实现AVUserAble协议" userInfo:nil];
        @throw e;
    }
}

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    [TCAVLiveViewController checkInitParam:info user:user];
    if (self = [super initWith:info user:user])
    {
        _enableIM = YES;
    }
    return self;
}


- (void)addOwnViews
{
    [self addLivePreview];
    [self addLiveView];
}

- (void)layoutOnIPhone
{
    _livePreview.frame = self.view.bounds;
    [self layoutLiveView];
}


- (void)exitLive
{
    if (_msgHandler)
    {
        [_livePreview stopPreview];
        [_msgHandler exitLiveChatRoom:^{
            [super exitLive];
        } fail:^(int code, NSString *msg) {
            [super exitLive];
        }];
        
    }
    else
    {
        [super exitLive];
    }
}


- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip
{
    DebugLog(@"%@", tip);
    if (!succ)
    {
        DebugLog(@"----->>>>>打开相机失败");
        [[HUDHelper sharedInstance] tipMessage:tip delay:2 completion:^{
            [self alertExitLive];
        }];
    }
    else
    {
        if (_isHost)
        {
            [_liveView setRoomEngine:_roomEngine];
        }
    }
    
}

//- (void)onAVEngine:(TCAVBaseRoomEngine *)engine preProcessLocaVideoFrame:(QAVVideoFrame *)frame
//{
//    
//    if ([engine isFrontCamera])
//    {
//        // 接收者通过判断是 frame.frameDesc.rotate / 4 != 0判断画面前前置摄像头取到的
//        // 当前字段未使用，暂不处理
//        //        frame.roomID += 4;
//        //        frame.frameDesc.a
//    }
//}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine recvSemiAutoVideo:(NSArray *)users
{
    // do nothing in this class
    // overwrite by the subclass
    [_livePreview addRenderFor:[_roomInfo liveHost]];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame
{
    [_livePreview render:frame mirrorReverse:[engine isFrontCamera] fullScreen:YES];
}

- (void)onAppEnterForeground
{
    [super onAppEnterForeground];
    [_livePreview startPreview];
    [_liveView onEnterForeground];
}

- (void)onAppEnterBackground
{
    [super onAppEnterBackground];
    [_livePreview stopPreview];
    [_liveView onEnterBackground];
}

@end



@implementation TCAVLiveViewController (ProtectedMethod)

- (void)addLivePreview
{
    _livePreview = [[TCAVLivePreview alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_livePreview];
    
    [_livePreview addRenderFor:[_roomInfo liveHost]];
}


- (void)addLiveView
{
    // 子类重写
    TCAVLiveBaseViewController *uivc = [[TCAVLiveBaseViewController alloc] initWith:self];
    [self addChild:uivc inRect:self.view.bounds];
    
    _liveView = uivc;
}

- (void)layoutLiveView
{
    // 子类重写
}

- (NSInteger)defaultAVHostConfig
{
    
    // 添加推荐配置
    if (_isHost)
    {
        return EAVCtrlState_All;
    }
    else
    {
        return EAVCtrlState_Speaker;
    }
}


- (void)prepareIMMsgHandler
{
    if (!_msgHandler)
    {
        _msgHandler = [[AVIMMsgHandler alloc] initWith:_roomInfo];
    }
}

- (void)releaseIMMsgHandler
{
    _msgHandler.roomIMListner = nil;
    [_msgHandler releaseIMRef];
}

- (void)createRoomEngine
{
    id<AVUserAble> ah = (id<AVUserAble>)_currentUser;
    [ah setAvCtrlState:[self defaultAVHostConfig]];
    _roomEngine = [[TCAVLiveRoomEngine alloc] initWith:(id<IMHostAble, AVUserAble>)_currentUser enableChat:_enableIM];
    _roomEngine.delegate = self;
    
    if (!_isHost)
    {
        [_liveView setRoomEngine:_roomEngine];
    }
    
}

- (void)onExitLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [self releaseIMMsgHandler];
    
    [_liveView setMsgHandler:nil];
    
    [super onExitLiveSucc:succ tipInfo:tip];
}


- (void)onEnterLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [super onEnterLiveSucc:succ tipInfo:tip];
    
    if (succ)
    {
        if (_enableIM)
        {
            [self prepareIMMsgHandler];
            [_liveView setMsgHandler:_msgHandler];
        }
        
        if (!_isHost)
        {
            _liveView.roomEngine = (TCAVLiveRoomEngine *)_roomEngine;
        }
        
        [self requestHostViewOnEnterLiveSucc];
        
        // TODO:改成调后台接口成功后调用
        [_msgHandler enterLiveChatRoom:nil fail:nil];
        
    }
}

- (void)requestHostViewOnEnterLiveSucc
{
    if (!_isHost)
    {
        // 观人进入后房间后，请求主播画面，主播不做事情
        // 请求主播画面
        [(TCAVLiveRoomEngine *)_roomEngine asyncRequestHostView];
    }
}

- (NSString *)cameraAuthorizationTip
{
    return _isHost ? @"没有权限访问您的相机，无法进行直播，请在“设置－隐私－相机”中允许使用" : @"没有权限访问您的相机，无法观看直播，请在“设置－隐私－相机”中允许使用";
}

- (void)checkAndEnterAVRoom
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        // 没有权限，到设置中打开权限
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertView *alterView = [UIAlertView bk_showAlertViewWithTitle:@"相机授权" message:[self cameraAuthorizationTip] cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self exitOnNotPermitted];
            }];
            [alterView show];
        });

        return;
    }
    else
    {
        
        // 获取麦克风权限
        AVAudioSession *avSession = [AVAudioSession sharedInstance];
        if ([avSession respondsToSelector:@selector(requestRecordPermission:)])
        {
            [avSession requestRecordPermission:^(BOOL available) {
                if (!available)
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIAlertView *alterView = [UIAlertView bk_showAlertViewWithTitle:@"录音授权" message:@"请在“设置-隐私-麦克风”中允许访问麦克风。" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            [self exitOnNotPermitted];
                        }];
                        [alterView show];
                    });
                }
                else
                {
                    [super checkAndEnterAVRoom];
                }
            }];
        }

        
    }
}


@end