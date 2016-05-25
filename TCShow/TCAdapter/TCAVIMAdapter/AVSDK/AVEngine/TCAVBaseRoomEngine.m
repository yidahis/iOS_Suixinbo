//
//  TCAVBaseRoomEngine.m
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVBaseRoomEngine.h"


@implementation TCAVBaseRoomEngine
{
    BOOL        _hasShowFirstRemoteFrame;
#if kSupportTimeStatistics
    BOOL        _hasShowLocalFirstFrame;
    BOOL        _hasSemiAutoCameraVideo;
#endif
}

- (void)dealloc
{
    DebugLog(@"======>>>>> [%@] %@ 释放成功 <<<<======", [self class], self);
#if kIsUseAVSDKAsLiveScene
#else
    [QAVContext DestroyContext:_avContext];
#endif
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)initWith:(id<IMHostAble>)host
{
    if (!host)
    {
        DebugLog(@"host 信息不能为空");
        NSException *e = [NSException exceptionWithName:@"参数错误" reason:@"host信息不能为空" userInfo:nil];
        @throw e;
    }
    
    if(self = [super init])
    {
        _isAtForeground = YES;
        
#if kIsUseAVSDKAsLiveScene
        // 
        QAVContext *context = [TCAVSharedContext sharedContext];
        DebugLog(@"=====>>>>>使用的QAVContext = %p", context);
        if (context)
        {
            _avContext = context;
            _isUseSharedContext = YES;
        }
        else
#endif
        {
            QAVContextConfig *config = [[QAVContextConfig alloc] init];
            
            NSString *appid = [host imSDKAppId];
            
            config.sdk_app_id = appid;
            config.app_id_at3rd = appid;
            config.identifier = [host imUserId];
            config.account_type = [host imSDKAccountType];
            _avContext = [QAVContext CreateContext:config];
        }
        
       
        
        _IMUser = host;
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    return self;
}

- (id<AVRoomAble>)getRoomInfo
{
    return _roomInfo;
}

- (id<IMHostAble>)getIMUser
{
    return _IMUser;
}

- (BOOL)isHostLive
{
    return [[_IMUser imUserId] isEqualToString:[[_roomInfo liveHost] imUserId]];
}

// 开始直播
- (void)enterLive:(id<AVRoomAble>)room
{
#if kSupportTimeStatistics
    [self onWillEnterLive];
#endif
    [self onRealEnterLive:room];
}

// 停止直播
- (void)exitLive
{
    [self stopFirstFrameTimer];
    
    if (!_isRoomAlive)
    {
        // 都没进房间过，直接返回退出成功
        [_delegate onAVEngine:self exitRoom:_roomInfo succ:YES tipInfo:@"退出成功"];
        return;
    }
    
    _isRoomAlive = NO;
    
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        [_delegate onAVEngine:self exitRoom:_roomInfo succ:YES tipInfo:@"退出成功"];
        return;
    }
#if kSupportTimeStatistics
    if (!_logStartDate)
    {
        [self onWillExitLive];
    }
    TCAVIMLog(@"%@ 开始退出直播:%@", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate]);
#else
    DebugLog(@"开始退出直播");
#endif
    QAVVideoCtrl *ctrl = [_avContext videoCtrl];
    [ctrl setLocalVideoDelegate:nil];
    [ctrl setRemoteVideoDelegate:nil];
    [_avContext exitRoom];
    
}

- (BOOL)isRoomRunning
{
    return _isRoomAlive && _isAtForeground;
}

- (BOOL)isFrontCamera
{
    return [_avContext.videoCtrl isFrontcamera];
}

- (void)creatAVRoom
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    
    QAVMultiParam *param = [self createdAVRoomParam];
    
    if ([[IMAPlatform sharedInstance] isConnected])
    {
        // 检查当前网络
        QAVResult result = [_avContext enterRoom:param delegate:self];
        
        if(QAV_OK != result)
        {
            TCAVIMLog(@"进入AVRoom出错:%d", (int)result);
            __weak TCAVBaseRoomEngine *ws = self;
            [_avContext stopContext:^(QAVResult result) {
                [ws onContextCloseComplete:@"进入房间失败"];
            }];
        }
    }
    else
    {
        TCAVIMLog(@"进入AVRoom出错:当前网络不可用");
        // 检查当前网络
        __weak TCAVBaseRoomEngine *ws = self;
        [_avContext stopContext:^(QAVResult result) {
            [ws onContextCloseComplete:@"当前网络不可用"];
        }];
    }
}



#pragma AVRoomDelegate method

-(void)OnEnterRoomComplete:(int)result
{
    // 进入AV房间
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    if(QAV_OK == result)
    {
        TCAVIMLog(@"进入AV房间成功");
        [self onEnterAVRoomSucc];
    
    }
    else
    {
        TCAVIMLog(@"进入AV房间失败: %d, 开始StopContext", result);
#if kIsUseAVSDKAsLiveScene
        [self onContextCloseComplete:QAV_OK];
#else
        // 不
        __weak TCAVBaseRoomEngine *ws = self;
        [_avContext stopContext:^(QAVResult result) {
            [ws onContextCloseComplete:@"进入AV房间失败"];
        }];
#endif
        
        
    }
}


-(void)OnExitRoomComplete:(int)result
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
#if kSupportTimeStatistics
    NSDate *date = [NSDate date];
    TCAVIMLog(@"%@ 从退房:%@ 到ExitRoom时间:%@ 总耗时:%0.3f (s)", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
#else
    
    DebugLog(@"退出AVRoom完毕");
#endif
    
    __weak TCAVBaseRoomEngine *ws = self;
#if kIsUseAVSDKAsLiveScene
    [ws onContextCloseComplete:nil];
#else
    [_avContext stopContext:^(QAVResult result) {
        [ws onContextCloseComplete:nil];
    }];
#endif
    
}

- (void)OnPrivilegeDiffNotify:(int)privilege
{
    // no nothing
    // overwrite by subclass
}

-(void)OnSemiAutoRecvCameraVideo:(NSArray*)identifierList
{
    TCAVIMLog(@"自动接收到的视频列表:%@", identifierList);
    if (!_hasRecvSemiAutoCamera)
    {
#if kSupportTimeStatistics
        
        if (!_hasSemiAutoCameraVideo)
        {
            _hasSemiAutoCameraVideo = YES;
            NSDate *date = [NSDate date];
            TCAVIMLog(@"%@ 从进房:%@ 到收到推送视频:%@ 总耗时:%0.3f (s)", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
        }
#endif
        [_delegate onAVEngine:self recvSemiAutoVideo:identifierList];
        _hasRecvSemiAutoCamera = YES;
    }
}


- (void)onRoomEnterForeground
{
    _isAtForeground = YES;
}
- (void)onRoomEnterBackground
{
    _isAtForeground = NO;
}

- (NSString *)engineLog
{
    if (_isRoomAlive)
    {
        NSString *videoParam = [_avContext.videoCtrl getQualityTips];
        NSString *audioParam = [_avContext.audioCtrl getQualityTips];
        NSString *commonParam = [_avContext.room getQualityTips];
        return [NSString stringWithFormat:@"Video:\n%@Audio:\n%@Common:\n%@", videoParam, audioParam, commonParam];
    }
    else
    {
        DebugLog(@"[%@] 当前room不是直播状态", [self class]);
        return nil;
    }
}

// 修改角色 此前，角色被设定为在进入房间之前指定、进入房间之后不能动态修改。这个接口的作用就是修改这一设定，即：在进入房间之后也能动态修改角色。业务测可以通过此接口让用户在房间内动态调整音视频、网络参数，如将视频模式从清晰切换成流畅。
// role 角色字符串，可为空，为空时对应后台默认角色，注意传入的参数，要与腾讯云台Spear引擎配置一致
// 修改角色不包括修改音频场景，音频场景仍然需要在进入房间前指定而且进入房间以后不能修改
- (QAVResult)changeAVControlRole:(NSString *)role
{
    if ([self isRoomRunning])
    {
        QAVMultiRoom *room = (QAVMultiRoom *)_avContext.room;
        if ([room respondsToSelector:@selector(ChangeAVControlRole:delegate:)])
        {
            QAVResult res = [room ChangeAVControlRole:role delegate:self];
            return res;
        }
        else
        {
            DebugLog(@"创建房间时，传入的参数不是QAVMultiParam类型，无法修改role");
        }
        
    }
    else
    {
        DebugLog(@"房间状态不正确，无法changeRole");
    }
    return QAV_ERR_FAILED;
}

- (void)OnChangeRoleDelegate:(int)ret_code
{
    if ([_delegate respondsToSelector:@selector(onAVEngine:changeRole:tipInfo:)])
    {
        BOOL succ = ret_code == QAV_OK;
        [_delegate onAVEngine:self changeRole:succ tipInfo:succ ? @"修改成功" : @"修改失败"];
    }
}

- (void)OnEndpointsUpdateInfo:(QAVUpdateEvent)eventID endpointlist:(NSArray *)endpoints
{
    DebugLog(@"endpoints = %@ evenId = %d %@", endpoints, (int)eventID, [self eventTip:eventID]);
    
    if (eventID == QAV_EVENT_ID_ENDPOINT_EXIT)
    {
        if ([_delegate respondsToSelector:@selector(onAVEngine:users:exitRoom:)])
        {
            // 有人退出
            [_delegate onAVEngine:self users:endpoints exitRoom:_roomInfo];
        }
    }
    else if (eventID == QAV_EVENT_ID_ENDPOINT_ENTER)
    {
        if ([_delegate respondsToSelector:@selector(onAVEngine:users:enterRoom:)])
        {
            // 进有进入
            [_delegate onAVEngine:self users:endpoints enterRoom:_roomInfo];
        }
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(onAVEngine:users:event:)])
        {
            // 其他事件监听
            [_delegate onAVEngine:self users:endpoints event:eventID];
        }
    }
    
}



/**
 @brief 本地画面预览回调
 @param 本地视频帧数据
 */
-(void)OnLocalVideoPreview:(QAVVideoFrame*)frameData
{
#if kSupportTimeStatistics
    if (!_hasShowLocalFirstFrame)
    {
        _hasShowLocalFirstFrame = YES;
        NSDate *date = [NSDate date];
        TCAVIMLog(@"%@ 从进房:%@ 到画面显示时间:%@ 整个流程完毕 总耗时 :%0.3f (s)", [self isHostLive] ? @"主播" : @"观众",  [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
        _logStartDate = nil;
    }
#endif
    [_delegate onAVEngine:self videoFrame:frameData];
}

/**
 @brief 本地画面预处理视频回调，修改了data的数据后会在编码后传给服务器。
 @param 本地视频帧数据
 */
-(void)OnLocalVideoPreProcess:(QAVVideoFrame*)frameData
{
    // do nothing
    // over write by subclass
    //    [self onPreProcessLocalVideoFrame:frameData];
    
}

-(void)OnVideoPreview:(QAVVideoFrame*)frameData
{
    if (!_hasShowFirstRemoteFrame)
    {
        _hasShowFirstRemoteFrame = YES;
        
        [self stopFirstFrameTimer];
        if ([_delegate respondsToSelector:@selector(onAVEngineFirstRemoteFrameRender:)])
        {
            DebugLog(@"第一帧画面开始显示");
            [_delegate onAVEngineFirstRemoteFrameRender:self];
        }
        
#if kSupportTimeStatistics
        NSDate *date = [NSDate date];
        TCAVIMLog(@"%@ 从进房:%@ 画面(%@)到达时间:%@ 整个流程完毕 总耗时:%0.3f (s)", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], frameData.identifier, [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
        _logStartDate = nil;
#endif
    }
    [_delegate onAVEngine:self videoFrame:frameData];
}


@end




@implementation TCAVBaseRoomEngine (ProtectedMethod)
#if kSupportTimeStatistics
- (void)onWillEnterLive
{
    if (!_logStartDate)
    {
        _logStartDate = [NSDate date];
        TCAVIMLog(@"%@ 进入房间开始计时:%@", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate]);
    }
}




- (void)onWillExitLive
{
    if (!_logStartDate)
    {
        _logStartDate = [NSDate date];
        TCAVIMLog(@"%@ 退出房间开始间计时:%@", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate]);
    }
}

- (void)onDidExitLive
{
    if (_logStartDate)
    {
        NSDate *date = [NSDate date];
        TCAVIMLog(@"%@ 退出直播流程完毕。开始计时:%@ 结束时间:%@, 总共耗时:%0.3f", [self isHostLive] ? @"主播" : @"观众", [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date], -[_logStartDate timeIntervalSinceDate:date]);
    }
    _logStartDate = nil;
    
}
#endif

- (void)onRealEnterLive:(id<AVRoomAble>)room
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    
    if ([room liveAVRoomId] == 0)
    {
        DebugLog(@"房间id为空");
        [_delegate onAVEngine:self enterRoom:room succ:NO tipInfo:@"房间信息不正确"];
        return;
    }
#if kSupportTimeStatistics
    if (!_logStartDate)
    {
        _logStartDate = [NSDate date];
    }
#endif
    TCAVIMLog(@"-----[%@]>>>>>开始进入直播间：%@", [self isHostLive] ? @"主播" : @"观众", _isUseSharedContext ? @"" : @"StartContext");
    _roomInfo = room;
    
    
#if kIsUseAVSDKAsLiveScene
    if (_isUseSharedContext)
    {
        [self creatAVRoom];
    }
    else
#endif
    {
        __weak TCAVBaseRoomEngine *ws = self;
        [_avContext startContext:^(QAVResult result) {
            [ws onContextStartComplete:(int)result];
        }];
    }
    
    
    
    
}

- (QAVMultiParam *)createdAVRoomParam
{
    QAVMultiParam *param = [[QAVMultiParam alloc] init];
    param.roomID = [_roomInfo liveAVRoomId];
    param.audioCategory = 0;
    param.controlRole = [self roomControlRole];
    param.authBitMap = QAV_AUTH_BITS_DEFAULT;
    param.autoCreateRoom = [self isHostLive];
    param.videoRecvMode = VIDEO_RECV_MODE_SEMI_AUTO_RECV_CAMERA_VIDEO;
    return param;
}

- (NSString *)roomControlRole
{
    // 具体与云平台speae引擎配置有关
    // 所返回的内容必须要与云端一致
    // 若返回nil，使用默认配置
    return nil;
}

- (void)onContextStartComplete:(int)result
{
    if (!_avContext)
    {
        DebugLog(@"avContext已销毁");
        return;
    }
    
#if kIsUseAVSDKAsLiveScene
    if (!_isUseSharedContext)
    {
        // 配置共享的context
        [TCAVSharedContext configWithStartedContext:_avContext];
    }
#endif
    
    if (result == QAV_OK)
    {
        TCAVIMLog(@"StartContext成功，开始进入AVRoom");
        [self creatAVRoom];
    }
    else
    {
        TCAVIMLog(@"StartContextr失败，开始StopContext");
        __weak TCAVBaseRoomEngine *ws = self;
        [_avContext stopContext:^(QAVResult result) {
            [ws onContextCloseComplete:nil];
        }];
    }
    
}

// 进入AVRoom成功之后要进行的操作
- (void)onEnterAVRoomSucc
{
    _isRoomAlive = YES;
    NSString *tip = [self isHostLive] ? @"创建直播间成功" : @"进入直播间成功";
    
#if kSupportTimeStatistics
    
    NSDate *date = [NSDate date];
    TCAVIMLog(@"%@ 从进房:%@ 到创建AVRoom成功:%@ 总耗时:%0.3f (s)", tip, [kTCAVIMLogDateFormatter stringFromDate:_logStartDate], [kTCAVIMLogDateFormatter stringFromDate:date] , -[_logStartDate timeIntervalSinceDate:date]);
#else
    DebugLog(@"%@", tip);
#endif
    [_delegate onAVEngine:self enterRoom:_roomInfo succ:YES tipInfo:tip];
}

- (void)onContextCloseComplete:(NSString *)tip
{
#if kSupportTimeStatistics
    [self onDidExitLive];
#else
    DebugLog(@"退房成功");
#endif
    [_delegate onAVEngine:self exitRoom:_roomInfo succ:YES tipInfo: tip ? tip : @"退出成功"];
}

- (NSString *)eventTip:(QAVUpdateEvent)event
{
    switch (event)
    {
        case QAV_EVENT_ID_NONE:
            return @"no thing";
            break;
        case QAV_EVENT_ID_ENDPOINT_ENTER:
            return @"进入房间";
        case QAV_EVENT_ID_ENDPOINT_EXIT:
            return @"退出房间";
        case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:
            return @"打开摄像头";
        case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
            return @"关闭摄像头";
        case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:
            return @"打开麦克风";
        case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:
            return @"关闭麦克风";
        case QAV_EVENT_ID_ENDPOINT_HAS_SCREEN_VIDEO:
            return @"发屏幕";
        case QAV_EVENT_ID_ENDPOINT_NO_SCREEN_VIDEO:
            return @"不发屏幕";
            
        default:
            return nil;
            break;
    }
}


// 首帧画面计时，
- (void)startFirstFrameTimer
{
    if (_hasStatisticFirstFrame || _hasShowFirstRemoteFrame)
    {
        if (_hasShowFirstRemoteFrame)
        {
            DebugLog(@"首帧画面已显示，不需要再计时");
        }
        
        return;
    }
    DebugLog(@"开始首帧画面计时");
    _hasStatisticFirstFrame = YES;
    
    _firstFrameTimer = [NSTimer scheduledTimerWithTimeInterval:[self maxWaitFirstFrameSec] target:self selector:@selector(onWaitFirstFrameTimeOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_firstFrameTimer forMode:NSRunLoopCommonModes];
}

- (void)onWaitFirstFrameTimeOut
{
    DebugLog(@"请求首帧画面超时");
    if ([_delegate respondsToSelector:@selector(onAVEngineWaitFirstRemoteFrameTimeOut:)])
    {
        [_delegate onAVEngineWaitFirstRemoteFrameTimeOut:self];
    }
}
// 等待第一帧的时长
- (NSInteger)maxWaitFirstFrameSec
{
    return 10;
}
// 停步首帧计时
- (void)stopFirstFrameTimer
{
    if (_firstFrameTimer)
    {    
        [_firstFrameTimer invalidate];
        _firstFrameTimer = nil;
    }
}



@end