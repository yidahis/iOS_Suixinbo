//
//  TCAVMultiLiveRoomEngine.m
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVMultiLiveRoomEngine.h"

@interface TCAVMultiLiveRoomEngine ()
{
    
    NSInteger _isRequestAllViewTryCount;
}

@end

@implementation TCAVMultiLiveRoomEngine




- (void)dealloc
{
    [self asyncCancelAllRequestView];
}


- (instancetype)initWith:(id<IMHostAble>)host
{
    if (![host conformsToProtocol:@protocol(AVMultiUserAble)])
    {
        NSException *e = [NSException exceptionWithName:@"TCAVLiveRoomEngineHostInVailed" reason:@"必须实现AVMultiUserAble协议" userInfo:nil];
        @throw e;
    }
    
    
    if ([super initWith:host])
    {
        _isRequestAllViewTryCount = 0;
    }
    return self;
}


- (instancetype)initWith:(id<IMHostAble, AVUserAble>)host enableChat:(BOOL)enable
{
    if (![host conformsToProtocol:@protocol(AVMultiUserAble)])
    {
        NSException *e = [NSException exceptionWithName:@"TCAVLiveRoomEngineHostInVailed" reason:@"必须实现AVMultiUserAble协议" userInfo:nil];
        @throw e;
    }
    if (self = [super initWith:host])
    {
        _enableChat = enable;
    }
    return self;
}

- (NSInteger)canRequestMore
{
    return [self maxRequestViewCount] - _multiUser.count;
}
- (NSInteger)maxRequestViewCount
{
    if (_hasEnabelCamera)
    {
        return 3;
    }
    return 4;
}

- (void)onEnableCameraComplete:(int)cameraid enable:(BOOL)enable result:(int)result needNotify:(BOOL)needNotify completion:(TCAVCompletion)completion
{
    if (result == QAV_OK)
    {
        // 处理成成功
        _hasEnabelCamera = enable;
    }
    [super onEnableCameraComplete:cameraid enable:enable result:result needNotify:needNotify completion:completion];
    
}

- (BOOL)hasEnableCameraBeforeEnterBackground
{
    if ([self isHostLive])
    {
        return _hasEnableCameraBeforeEnterBackground;
    }
    else
    {
        return [self isCameraEnable];
    }
}

// ower write super method

// 添加到待请求队列
- (BOOL)addRequestViewUser:(id<AVMultiUserAble>)user
{
    BOOL needAdd = YES;
    NSString *userid = [user imUserId];
    NSString *curId = [_IMUser imUserId];
    for (NSInteger i = 0; i < _multiUser.count; i++)
    {
        id<IMUserAble> iu = [_multiUser objectAtIndex:i];
        
        NSString *iuid = [iu imUserId];
        
        if ([iuid isEqualToString:userid])
        {
            DebugLog(@"已经上请求的列表中---> requestAllView");
            needAdd = NO;
            break;
        }
        
        if ([curId isEqualToString:userid])
        {
            // 本地用户不能添加到请求列表中
            DebugLog(@"本地用户不能添加到请求列表中----> requestAllView");
            needAdd = NO;
            break;
        }
    }
    
    
    
    if (!_multiUser)
    {
        _multiUser = [[NSMutableArray alloc] init];
    }
    
    if (_multiUser.count >= [self maxRequestViewCount])
    {
        DebugLog(@"已经超出最大画面请求数量----> requestAllView");
        needAdd = NO;
    }
    
    DebugLog(@"请求%@的画面", [user imUserId]);
    if (needAdd)
    {
        [_multiUser addObject:user];
    }
    
    return needAdd;
}

// 异步请求用户user的画面
- (void)asyncRequestViewOf:(id<AVMultiUserAble>)user
{
    // 先更新数据
    [self addRequestViewUser:user];
    
    [self requestAllView];
}

- (void)asyncRequestMultiViewsOf:(NSArray *)users
{
    if (users.count)
    {
        for (id<AVMultiUserAble> user in users)
        {
            [self addRequestViewUser:user];
        }
    }
    
    [self requestAllView];
}




- (void)requestAllView
{
    if ([self beforeTryCheck:nil])
    {
        // 每次有新的请求过来，则重试次数重置
        _isRequestAllViewTryCount = 0;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(realRequestAllView) object:nil];
        
        [self realRequestAllView];
    }
    
    
}

- (void)realRequestAllView
{
    if (_multiUser.count > 0)
    {
        NSMutableArray *typeArray = [NSMutableArray array];
        NSMutableArray *idlist = [NSMutableArray array];
        for (NSInteger i = 0; i < _multiUser.count; i++)
        {
            id<IMUserAble> iu = [_multiUser objectAtIndex:i];
            [idlist addObject:[iu imUserId]];
            [typeArray addObject:@(QAVVIDEO_SRC_TYPE_CAMERA)];
        }
        
        
        DebugLog(@"QAVEndpoint requestViewList : %@", idlist);
        __weak TCAVMultiLiveRoomEngine *ws = self;
        int res = [QAVEndpoint requestViewList:_avContext identifierList:idlist srcTypeList:typeArray ret:^(QAVResult result) {
            [ws onRequestViewListCallBack:result ];
        }];
        if (res != QAV_OK)
        {
            DebugLog(@"QAVEndpoint requestViewList 直接返回: %d", res);
        }
    }
}

- (void)onRequestViewListCallBack:(QAVResult)result
{
    if (QAV_OK == result)
    {
        DebugLog(@"realRequestAllView 成功, 重试次数 : %d", (int)_isRequestAllViewTryCount);
        // 说明请求成功
        _isRequestAllViewTryCount = 0;
        [self startFirstFrameTimer];
        [_requestViewDelegate onAVMLRoomEngine:self requestView:YES];
    }
    else
    {
        _isRequestAllViewTryCount++;
        
        if (_isRequestAllViewTryCount <= [self maxRequestViewCount])
        {
            DebugLog(@"realRequestAllView 失败, 重试次数 : %d，继续得试", (int)_isRequestAllViewTryCount);
            // 继续重试
            [self performSelector:@selector(realRequestAllView) withObject:nil afterDelay:1];
        }
        else
        {
            DebugLog(@"realRequestAllView 失败, 重试次数 : %d", (int)_isRequestAllViewTryCount);
            [_requestViewDelegate onAVMLRoomEngine:self requestView:NO];
            _isRequestAllViewTryCount = 0;
            
            // 是否是请求主播画面不成功
            [self checkRequestHostViewFailed];
        }
        
    }
}


- (void)checkRequestHostViewFailed
{
    if (_multiUser.count == 1)
    {
        id<AVMultiUserAble> user = _multiUser[0];
        
        if ([[user imUserId] isEqualToString:[[_roomInfo liveHost] imUserId]])
        {
            if ([_delegate respondsToSelector:@selector(onAVEngine:requestViewOf:succ:tipInfo:)])
            {
                [_delegate onAVEngine:self requestViewOf:user succ:NO tipInfo:@"请求主播画面失败"];
            }
        }
    }
}


- (void)removeRequestViewUser:(id<AVMultiUserAble>)user
{
    id<IMUserAble> ru = nil;
    for (NSInteger i = 0; i < _multiUser.count; i++)
    {
        id<IMUserAble> iu = [_multiUser objectAtIndex:i];
        if ([[iu imUserId] isEqualToString:[user imUserId]])
        {
            ru = iu;
            break;
        }
    }
    
    if (!ru)
    {
        DebugLog(@"不在请求的列表中");
        return;
    }
    
    [_multiUser removeObject:ru];
}
// 异步取消user的画面
- (void)asyncCancelRequestViewOf:(id<AVMultiUserAble>)user
{
    [self removeRequestViewUser:user];
    
    [self requestAllView];
}

- (void)asyncCancelRequestMultiViewsOf:(NSArray *)users
{
    if (users.count)
    {
        for (id<AVMultiUserAble> user in users)
        {
            [self removeRequestViewUser:user];
        }
    }
    
    [self requestAllView];
}

// 异步取消所有人的画面
- (void)asyncCancelAllRequestView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(realRequestAllView) object:nil];
    [QAVEndpoint cancelAllview:_avContext ret:nil];
    [_multiUser removeAllObjects];
}


// 是否是已上传画面的
- (BOOL)isConnectedCamera
{
    return _hasEnabelCamera;
}

// 是否支持美颜
- (BOOL)isSupporBeauty
{
    return _isSupportBeauty && _isRoomAlive && _hasEnabelCamera;
}


@end


@implementation TCAVMultiLiveRoomEngine (ProtectedMethod)

- (NSInteger)requestViewMaxTryCount
{
    return 5;
}

- (void)requestViewOfHostOnAVSDKCallBack:(NSArray *)endpoints
{
    // 非主播才去进行请求
    // do nothing，多人互动时，因界面上存在资源分配，交由- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users event:(QAVUpdateEvent)event; 中处理
}


@end
