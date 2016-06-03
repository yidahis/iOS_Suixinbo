//
//  TCShowLiveViewController.m
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveViewController.h"



@implementation TCShowLiveUIViewController

- (void)addOwnViews
{
    id<AVRoomAble> room = [_liveController roomInfo];
    _liveView = [[TCShowLiveView alloc] initWith:(id<TCShowLiveRoomAble>)room];
    _liveView.topView.delegate = self;
    [self.view addSubview:_liveView];
}

- (BOOL)isPureMode
{
    return [_liveView isPureMode];
}

#if kSupportIMMsgCache

- (void)onUIRefreshIMMsg:(AVIMCache *)cache
{
    [_liveView.msgView insertCachedMsg:cache];
    
}

- (void)onUIRefreshPraise:(AVIMCache *)cache
{
    [_liveView onRecvPraise:cache];
}

#endif

- (void)uiStartLive
{
    __weak TCShowLiveUIViewController *ws = self;
    
#if kSupportTimeStatistics
    NSDate *startTime = [NSDate date];
    TCAVIMLog(@"主播进入直播间上报开始:%@", [kTCAVIMLogDateFormatter stringFromDate:startTime]);
#endif
    LiveStartRequest *req = [[LiveStartRequest alloc] initWithHandler:^(BaseRequest *request) {
#if kSupportTimeStatistics
        NSDate *date = [NSDate date];
        TCAVIMLog(@"主播进入直播间上报开始:%@ 成功回调时间:%@ 接口耗时:%0.3f (s)", [kTCAVIMLogDateFormatter stringFromDate:startTime], [kTCAVIMLogDateFormatter stringFromDate:date], [date timeIntervalSinceDate:startTime]);
#endif
        // 上传成功，界面开始计时
        [ws startLiveTimer];
        ws.isPostLiveStart = YES;
        
        
        
    } failHandler:^(BaseRequest *request) {
#if kSupportTimeStatistics
        NSDate *date = [NSDate date];
        TCAVIMLog(@"主播进入直播间上报开始:%@ 失败回调时间:%@ 接口耗时:%0.3f (s)", [kTCAVIMLogDateFormatter stringFromDate:startTime], [kTCAVIMLogDateFormatter stringFromDate:date], [date timeIntervalSinceDate:startTime]);
#endif
        // 上传失败
        [[HUDHelper sharedInstance] tipMessage:[[request response] message] delay:2 completion:^{
            [ws.liveController alertExitLive];
        }];
    }];
    req.liveItem = (TCShowLiveListItem *)self.liveController.roomInfo;
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (void)showLiveResult:(TCShowLiveListItem *)item
{
    [_liveController willExitLiving];
    __weak TCShowLiveUIViewController *ws = self;
    TCShowLiveResultView *resultview = [[TCShowLiveResultView alloc] initWith:item completion:^(id<MenuAbleItem> menu) {
        ws.navigationController.navigationBarHidden = NO;
        [ws.navigationController popToRootViewControllerAnimated:YES];
    }];
    [self.view addSubview:resultview];
    [resultview setFrameAndLayout:self.view.bounds];
    
#if kSupportFTAnimation
    [resultview fadeIn:0.3 delegate:nil];
#endif
}

- (void)onStartPush:(BOOL)succ pushRequest:(TCAVLiveRoomPushRequest *)req
{
    [_liveView.topView onRefrshPARView:(TCAVLiveRoomEngine *)_roomEngine];
}

- (void)onStartRecord:(BOOL)succ recordRequest:(TCAVLiveRoomRecordRequest *)req
{
    [_liveView.topView onRefrshPARView:(TCAVLiveRoomEngine *)_roomEngine];
}

- (void)uiEndLive
{
    DebugLog(@"");
    if (self.isPostLiveStart)
    {
        [_heartTimer invalidate];
        _heartTimer = nil;
        
        [_liveView pauseLive];
        
#if kSupportTimeStatistics
        NSDate *startTime = [NSDate date];
        TCAVIMLog(@"主播退出直播间上报开始:%@", [kTCAVIMLogDateFormatter stringFromDate:startTime]);
#endif
        
        __weak TCShowLiveUIViewController *ws = self;
        LiveEndRequest *req = [[LiveEndRequest alloc] initWithHandler:^(BaseRequest *request) {
#if kSupportTimeStatistics
            NSDate *date = [NSDate date];
            TCAVIMLog(@"主播退出直播间上报开始:%@ 成功回调时间:%@ 接口耗时:%0.3f (s)", [kTCAVIMLogDateFormatter stringFromDate:startTime], [kTCAVIMLogDateFormatter stringFromDate:date], [date timeIntervalSinceDate:startTime]);
#endif
            // 上传成功，界面开始计时
            LiveEndResponseData *rec = (LiveEndResponseData *)request.response.data;
            [ws showLiveResult:rec.record];
        } failHandler:^(BaseRequest *request) {
#if kSupportTimeStatistics
            NSDate *date = [NSDate date];
            TCAVIMLog(@"主播退出直播间上报开始:%@ 失败回调时间:%@ 接口耗时:%0.3f (s)", [kTCAVIMLogDateFormatter stringFromDate:startTime], [kTCAVIMLogDateFormatter stringFromDate:date], [date timeIntervalSinceDate:startTime]);
#endif
            TCShowLiveListItem *item = (TCShowLiveListItem *)[ws.roomEngine getRoomInfo];
            [ws showLiveResult:item];
        }];
        req.liveItem = (TCShowLiveListItem *)self.liveController.roomInfo;;
        [[WebServiceEngine sharedEngine] asyncRequest:req wait:YES];
        
        self.isPostLiveStart = NO;
    }
    else
    {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)startLiveTimer
{
    [_heartTimer invalidate];
    _heartTimer = nil;
    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(onPostHeartBeat) userInfo:nil repeats:YES];
    
    [_liveView startLive];
}

- (void)onPostHeartBeat
{
    LiveHostHeartBeatRequest *req = [[LiveHostHeartBeatRequest alloc] initWithHandler:nil failHandler:^(BaseRequest *request) {
        // 上传心跳失败
        DebugLog(@"上传心跳失败");
    }];
    req.liveItem = (TCShowLiveListItem *)self.liveController.roomInfo;
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (void)onEnterBackground
{
    [self onPostHeartBeat];
    [_liveView pauseLive];
    [_heartTimer invalidate];
    _heartTimer = nil;
    
}
- (void)onEnterForeground
{
    [self onPostHeartBeat];
    [_liveView resumeLive];
    [self startLiveTimer];
}


- (void)setRoomEngine:(TCAVBaseRoomEngine *)roomEngine
{
    _roomEngine = roomEngine;
    [_liveView setRoomEngine:(TCAVLiveRoomEngine *)roomEngine];
}

- (void)setMsgHandler:(AVIMMsgHandler *)msgHandler
{
    _msgHandler = msgHandler;
    _msgHandler.roomIMListner = self;
    [_liveView setMsgHandler:msgHandler];
}

- (void)layoutOnIPhone
{
    [_liveView setFrameAndLayout:self.view.bounds];
}

- (void)onTopViewCloseLive:(TCShowLiveTopView *)topView
{
    [_liveController alertExitLive];
}

- (void)onTopViewClickHost:(TCShowLiveTopView *)topView host:(id<IMHostAble>)host
{
    // 显示主播信息
    UserProfileView *view = [[UserProfileView alloc] init];
    [self.view addSubview:view];
    [view setFrameAndLayout:self.view.bounds];
    [view showUser:host];
    
}

- (void)onTopView:(TCShowLiveTopView *)topView clickPAR:(UIButton *)par
{
    par.selected = !par.selected;
    [_liveView showPar:par.selected];
}

- (void)onTopView:(TCShowLiveTopView *)topView clickPush:(UIButton *)par
{
    if (par.selected)
    {
       [(TCAVLiveRoomEngine *)_roomEngine asyncStopAllPushStreamCompletion:^(BOOL succ, NSString *tip) {
          par.selected = !par.selected;
       }];
    }
    else
    {
        __weak TCAVLiveRoomEngine *wr = (TCAVLiveRoomEngine *)_roomEngine;
        __weak typeof(self) ws = self;
        
        UIActionSheet *testSheet = [[UIActionSheet alloc] init];//[UIActionSheet bk_actionSheetWithTitle:@"请选择照片源"];
        [testSheet bk_addButtonWithTitle:@"HLS推流" handler:^{
            [wr asyncStartPushStream:AV_ENCODE_HLS completion:^(BOOL succ, TCAVLiveRoomPushRequest *req) {
                par.selected = succ;
                [ws showPush:AV_ENCODE_HLS succ:succ request:req];
            }];
            
        }];
        [testSheet bk_addButtonWithTitle:@"RTMP推流" handler:^{
            [wr asyncStartPushStream:AV_ENCODE_RTMP completion:^(BOOL succ, TCAVLiveRoomPushRequest *req) {
                par.selected = succ;
                [ws showPush:AV_ENCODE_RTMP succ:succ request:req];
            }];
            
        }];
        [testSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [testSheet showInView:self.view];
    }
    
}

- (void)onTopView:(TCShowLiveTopView *)topView clickREC:(UIButton *)rec
{
    if (rec.selected)
    {
        [(TCAVLiveRoomEngine *)_roomEngine asyncStopRecordCompletion:^(BOOL succ, TCAVLiveRoomRecordRequest *req) {
            rec.selected = !rec.selected;
            
            NSString *fileId = @"";
            if(req.recordFileIds != nil)
            {
                for(int index = 0; index < req.recordFileIds.count; index++)
                {
                    fileId = [fileId stringByAppendingString:[NSString stringWithFormat:@"%@\n",req.recordFileIds[index]]];
                }
            }
            DebugLog(@"停止录制时的fileId = %@", fileId);
            
            UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:fileId cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
            [alert show];
        }];
    }
    else
    {
        TCAVLiveRoomEngine *re = (TCAVLiveRoomEngine *)_roomEngine;
        [re asyncStartRecordCompletion:^(BOOL succ, TCAVLiveRoomRecordRequest *req) {
            rec.selected = succ;
            [[HUDHelper sharedInstance] tipMessage:succ ? @"开始录制" : @"开启录制失败"];
        }];
    }
    
}

- (void)showPush:(AVEncodeType)type succ:(BOOL)succ request:(TCAVLiveRoomPushRequest *)req
{
    NSString *pushUrl = [req getPushUrl:type];
    if (succ && pushUrl.length > 0)
    {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"推流地址" message:pushUrl cancelButtonTitle:@"拷至粘切板" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:pushUrl];
        }];
        [alert show];
    }
    else
    {
        [[HUDHelper sharedInstance] tipMessage:@"推流不成功"];
    }
    
}


// 收到群聊天消息: (主要是文本类型)
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvGroupMsg:(id<AVIMMsgAble>)msg
{
    [_liveView.msgView insertMsg:msg];
}

- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomGroup:(AVIMCMD *)msg
{
    switch (msg.userAction)
    {
        case AVIMCMD_Praise:
        {
            [_liveView onRecvPraise];
            
        }
            break;
            
        default:
            break;
    }
    
    
}

// 有新用户进入
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver joinGroup:(NSArray *)senders
{
    // do nothing
    // overwrite by the subclass
    [_liveView.topView onImUsersEnterLive:senders];
}

// 有用户退出
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver exitGroup:(NSArray *)senders
{
    // do nothing
    // overwrite by the subclass
    [_liveView.topView onImUsersExitLive:senders];
}


@end

//==================================================================================================================================================================

@implementation TCShowLiveViewController

- (void)addLiveView
{
    TCShowLiveUIViewController *vc = [[TCShowLiveUIViewController alloc] initWith:self];
    [self addChild:vc inRect:self.view.bounds];
    _liveView = vc;
}

- (void)createRoomEngine
{
    id<AVUserAble> ah = (id<AVUserAble>)_currentUser;
    [ah setAvCtrlState:[self defaultAVHostConfig]];
    TCShowLiveRoomEngine *roomEngine = [[TCShowLiveRoomEngine alloc] initWith:(id<IMHostAble, AVUserAble>)_currentUser enableChat:_enableIM];
    // 测试默认开启后置摄像头
    // roomEngine.cameraId = CameraPosBack;
    roomEngine.delegate = self;
    _roomEngine = roomEngine;
    
    if (!_isHost)
    {
        [_liveView setRoomEngine:_roomEngine];
    }
    
}

- (NSInteger)defaultAVHostConfig
{
    
    // 添加推荐配置
    if (_isHost)
    {
        return EAVCtrlState_Mic | EAVCtrlState_Speaker | EAVCtrlState_Camera;
    }
    else
    {
        return EAVCtrlState_Speaker;
    }
}


- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users exitRoom:(id<AVRoomAble>)room
{
    // 此处，根据具体业务来处理：比如的业务下，支持主播可以退出再进，这样观众可以在线等待就不用退出了
    NSString *roomHostId = [[room liveHost] imUserId];
    for (id<IMUserAble> iu in users)
    {
        if ([[iu imUserId] isEqualToString:roomHostId])
        {
            if (!self.isExiting)
            {
                [self willExitLiving];
                // 说明主播退出
                UIAlertView *alert =  [UIAlertView bk_showAlertViewWithTitle:nil message:@"主播已退出当前直播" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self exitLive];
                }];
                [alert show];
                break;
            }
        }
    }
}


- (void)prepareIMMsgHandler
{
    if (!_msgHandler)
    {
        _msgHandler = [[TCShowAVIMHandler alloc] initWith:_roomInfo];
        _liveView.msgHandler = (TCShowAVIMHandler *)_msgHandler;
    }
}
#if kSupportIMMsgCache

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame
{
    [super onAVEngine:engine videoFrame:frame];
    
    [self renderUIByAVSDK];
}

- (void)renderUIByAVSDK
{
    // AVSDK采集为20帧每秒 : 具体数值看云后台配置
    // 可通过此处的控制显示的频率
    _uiRefreshCount++;
    TCShowLiveUIViewController *vc = (TCShowLiveUIViewController *)_liveView;
    
    // 1秒更新点赞
    if (_uiRefreshCount % 40 == 0 && ![vc isPureMode])
    {
        NSDictionary *dic = [_msgHandler getMsgCache];
        AVIMCache *msgcache = dic[@(AVIMCMD_Text)];
        [vc onUIRefreshIMMsg:msgcache];
        
        AVIMCache *praisecache = dic[@(AVIMCMD_Praise)];
        [vc onUIRefreshPraise:praisecache];
    }
}
#endif

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip
{
    [super onAVEngine:engine enableCamera:succ tipInfo:tip];
    if (succ)
    {
        // 调用liveStart接口
        TCShowLiveUIViewController *vc = (TCShowLiveUIViewController *)_liveView;
        [vc uiStartLive];
    }
}

- (void)onExitLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [self releaseIMMsgHandler];
    
    
    [_liveView setMsgHandler:nil];
    
    TCShowLiveUIViewController *vc = (TCShowLiveUIViewController *)_liveView;

    
    if (_isHost)
    {
        // 显示直播结果
        [vc uiEndLive];
    }
    else
    {
        [[HUDHelper sharedInstance] tipMessage:tip delay:0.5 completion:^{
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine onStartPush:(BOOL)succ pushRequest:(TCAVLiveRoomPushRequest *)req
{
    TCShowLiveUIViewController *uivc = (TCShowLiveUIViewController *)_liveView;
    [uivc onStartPush:succ pushRequest:req];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine onRecord:(BOOL)succ recordRequest:(TCAVLiveRoomRecordRequest *)req
{
    TCShowLiveUIViewController *uivc = (TCShowLiveUIViewController *)_liveView;
    [uivc onStartRecord:succ recordRequest:req];
}

@end


