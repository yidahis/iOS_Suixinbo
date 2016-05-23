//
//  TCAVMultiLiveViewController.m
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVMultiLiveViewController.h"

@interface TCAVMultiLiveViewController ()

@end

@implementation TCAVMultiLiveViewController


+ (void)checkInitParam:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if (![user conformsToProtocol:@protocol(AVMultiUserAble)])
    {
        DebugLog(@"因此类中要使用TCAVLiveRoomEngine，为保证其能正常使用，其传入的Host必须要实现AVUserAble");
        NSException *e = [NSException exceptionWithName:@"TCAVLiveRoomEngineHostInVailed" reason:@"必须实现AVUserAble协议" userInfo:nil];
        @throw e;
    }
}

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    [TCAVMultiLiveViewController checkInitParam:info user:user];
    if (self = [super initWith:info user:user])
    {        
        [self addMultiManager];
    }
    return self;
}




- (void)prepareIMMsgHandler
{
    if (!_msgHandler)
    {
        _msgHandler = [[MultiAVIMMsgHandler alloc] initWith:_roomInfo];
        _multiManager.msgHandler = (MultiAVIMMsgHandler *)_msgHandler;
    }
}

- (void)createRoomEngine
{
    id<AVMultiUserAble> ah = (id<AVMultiUserAble>)_currentUser;
    [ah setAvMultiUserState:_isHost ? AVMultiUser_Host : AVMultiUser_Guest];
    [ah setAvCtrlState:[self defaultAVHostConfig]];
    _roomEngine = [[TCAVMultiLiveRoomEngine alloc] initWith:(id<IMHostAble, AVMultiUserAble>)_currentUser enableChat:_enableIM];
    _roomEngine.delegate = self;
}

// 外部分配user窗口位置，此处可在界面显示相应的小窗口
- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr assignWindowResourceTo:(id<AVMultiUserAble>)user isInvite:(BOOL)inviteOrAuto
{
    // TODO:子类去分去配置
}

- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr requestViewComplete:(BOOL)succ
{
    // TODO:子类去分去配置
}

// 外部回收user窗口资源信息
- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr recycleWindowResourceOf:(id<AVMultiUserAble>)user
{
    // TODO:子类去分去配置
}

// 外部界面切换到请求画面操作
- (void)onAVIMMIMManagerRequestHostViewFailed:(TCAVIMMIManager *)mgr
{
    // TODO:子类去分去配置
}

- (void)addRenderInPreview:(id<AVMultiUserAble>)user
{
    [_livePreview addRenderFor:user];
}

- (void)removeRenderInPreview:(id<AVMultiUserAble>)user
{
    [_livePreview removeRenderOf:user];
}

- (void)switchToMainInPreview:(id<AVMultiUserAble>)user completion:(TCAVCompletion)completion
{
    [_multiManager switchAsMainUser:user completion:completion];
}

- (void)exitLive
{
    [_multiManager initiativeCancelInteractUser:(id<AVMultiUserAble>)_currentUser];
    [super exitLive];
}


@end


@implementation TCAVMultiLiveViewController (ProtectedMethod)

- (void)addLivePreview
{
    TCAVMultiLivePreview *preview = [[TCAVMultiLivePreview alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:preview];
    _livePreview = preview;
    
    _multiManager.preview = preview;
    [_livePreview addRenderFor:[_roomInfo liveHost]];
}

- (void)addMultiManager
{
    _multiManager = [[TCAVIMMIManager alloc] init];
    _multiManager.multiDelegate = self;
}

- (void)requestHostViewOnEnterLiveSucc
{
    id<AVMultiUserAble> host = (id<AVMultiUserAble>)[_roomInfo liveHost];
    _multiManager.roomEngine = (TCAVMultiLiveRoomEngine *)_roomEngine;
    [_multiManager registAsMainUser:host isHost:_isHost];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame
{
    NSString *fid = frame.identifier;
    if (fid.length == 0)
    {
        fid = [_currentUser imUserId];
    }
    [_livePreview render:frame mirrorReverse:[engine isFrontCamera] fullScreen:[_multiManager isMainUserByID:fid]];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users exitRoom:(id<AVRoomAble>)room
{
    // 此处，根据具体业务来处理：比如的业务下，支持主播可以退出再进，这样观众可以在线等待就不用退出了
    NSString *roomHostId = [[room liveHost] imUserId];
    for (id<AVMultiUserAble> iu in users)
    {
        NSString *iuid = [iu imUserId];
        if ([iuid isEqualToString:roomHostId])
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
        else
        {
            // 检查是否是互动观众退出了
            id<AVMultiUserAble> iiu = [_multiManager interactUserOf:iu];
            if (iiu)
            {
                NSString *tip = [NSString stringWithFormat:@"互动观众(%@)退出直播", iuid];
                [[HUDHelper sharedInstance] tipMessage:tip delay:2 completion:^{
                    [_multiManager forcedCancelInteractUser:iiu];
                }];
            }
        }
    }
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users event:(QAVUpdateEvent)event
{
    NSString *roomHostId = [[[engine getRoomInfo] liveHost] imUserId];
    // 是否是主播收到的
    
    NSMutableArray *hasCamera = [NSMutableArray array];
    for (id<AVMultiUserAble> iu in users)
    {
        NSString *iuid = [iu imUserId];
        if (![iuid isEqualToString:roomHostId])
        {
            // 检查是否是互动观众退出了
            switch (event)
            {
                case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:
                {
                    
                    TCAVIMEndpoint *p = [[TCAVIMEndpoint alloc] initWith:(QAVEndpoint *)iu];
                    [hasCamera addObject:p];
                    [_multiManager enableInteractUser:iu ctrlState:EAVCtrlState_Camera];
                }
                    
                    break;
                case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
                {
                    [_multiManager disableInteractUser:iu ctrlState:EAVCtrlState_Camera];
                }
                    break;
                case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:
                {
                    [_multiManager enableInteractUser:iu ctrlState:EAVCtrlState_Mic];
                }
                    break;
                case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:
                {
                    [_multiManager disableInteractUser:iu ctrlState:EAVCtrlState_Mic];
                }
                    break;
                default:
                    break;
            }
        }
        
    }
    
    
    if (hasCamera.count)
    {
        DebugLog(@"%@", hasCamera);
        // 改成请求多人的
        [_multiManager requestMultipleViewOf:hasCamera];
    }
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine recvSemiAutoVideo:(NSArray *)users
{
    NSMutableArray *hasCamera = [NSMutableArray array];
    for (NSString *iu in users)
    {
        TCAVIMEndpoint *p = [[TCAVIMEndpoint alloc] initWithID:iu];
        if (p)
        {
            [hasCamera addObject:p];
        }
    }
    [_multiManager addInteractUserOnRecvSemiAutoVideo:hasCamera];
}




@end