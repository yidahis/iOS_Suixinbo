//
//  TCAVBaseRoomEngine.h
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * TCAVBaseRoomEngine AVSDK封装的基类，主要将AVSDK进出房间流程作封装
 */


@interface TCAVBaseRoomEngine : NSObject<QAVRoomDelegate, QAVLocalVideoDelegate, QAVRemoteVideoDelegate>
{
@protected
    QAVContext                              *_avContext;
    __weak id<TCAVRoomEngineDelegate>       _delegate;
    

    
@protected
    id<AVRoomAble>                          _roomInfo;          // 房间信息
    id<IMHostAble>                          _IMUser;            // 当前登录IMSDK的用户
    
@protected
    BOOL                                    _isRoomAlive;       // 当前是否在
    BOOL                                    _isAtForeground;    // 当前是否在前台，默认为YES
    BOOL                                    _hasRecvSemiAutoCamera; // 是否收到了推送的视频;
    
@protected
    NSTimer                                 *_firstFrameTimer;  // 首帧画面显示计时器
    BOOL                                    _hasStatisticFirstFrame; // 是否已统计过首帧，如果已统计，后续不再进行统计
    
#if kSupportTimeStatistics
@protected
    // 用于进出房间时间统计
    NSDate                                  *_logStartDate;
#endif
    
}

@property (nonatomic, weak) id<TCAVRoomEngineDelegate> delegate;

- (id<AVRoomAble>)getRoomInfo;

- (id<IMHostAble>)getIMUser;

// 根据当前的用户信息创建直播
// host为当前登录IMSDK的用户，不能为空
- (instancetype)initWith:(id<IMHostAble>)host;

// 当前是主播，还是观众
- (BOOL)isHostLive;

// 主播：开始直播
// 观众：观看直播
- (void)enterLive:(id<AVRoomAble>)room;

// 主播：退出直播
// 观众：退出直播
- (void)exitLive;

// 创建建房间成功，并且在前台
// 主要用于进入房间后的操作audioctrl以及videoctrl的判断，在YES时，才能操作audioctrl以及videoctrl
- (BOOL)isRoomRunning;

// 是否是前置摄像头
- (BOOL)isFrontCamera;

// 程序前后台切换时使用
- (void)onRoomEnterForeground;
- (void)onRoomEnterBackground;


// 获取运行日志
- (NSString *)engineLog;

@end



//================================================
// Protected方法，部份方法供子类重写
// 外部禁止直接调用
@interface TCAVBaseRoomEngine (ProtectedMethod)

#if kSupportTimeStatistics
// 用于时间统计，外部不要重写
- (void)onWillEnterLive;
- (void)onWillExitLive;
#endif

// 因外部可能会重写enterLive方法，如果重写了，子类的子类内部再调[super enterLive] ，可能会有问题
// 用户不要重写此方法
- (void)onRealEnterLive:(id<AVRoomAble>)room;

// 创建房间的信息，重写此方法来修改房间参数
- (QAVMultiParam *)createdAVRoomParam;


// 进入AVRoom成功之后要进行的操作
- (void)onEnterAVRoomSucc;

// startContext完成
- (void)onContextStartComplete:(int)result;

// stopContext完成
- (void)onContextCloseComplete:(NSString *)tip;

- (NSString *)eventTip:(QAVUpdateEvent)event;


// 主要用于统计观众进入僵尸房间(主播异常退出，然后进入的观众requestviewlist成功，但会一直请求不到画面)，较长时间没有画面显示
// 首帧画面计时，
- (void)startFirstFrameTimer;
// 等待第一帧的时长，默认10s
- (NSInteger)maxWaitFirstFrameSec;
// 停步首帧计时
- (void)stopFirstFrameTimer;

@end

