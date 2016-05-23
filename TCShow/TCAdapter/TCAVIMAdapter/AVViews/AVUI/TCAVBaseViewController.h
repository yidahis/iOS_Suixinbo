//
//  TCAVBaseViewController.h
//  TCShow
//
//  Created by AlexiChen on 15/11/16.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "BaseViewController.h"

// 主要将是AVSDK使用简化，主要关注进出房间操作，以及抽取用户需要关注的可重写的事件，没有其他业务逻辑
@interface TCAVBaseViewController : BaseViewController<TCAVRoomEngineDelegate, TIMUserStatusListener>
{
@protected
    TCAVBaseRoomEngine              *_roomEngine;
    id<AVRoomAble>                  _roomInfo;
    
    id<IMHostAble>                  _currentUser;   // 当前使用的用户
    
@protected
    CTCallCenter                    *_callCenter;   // 电话监听
    BOOL                            _isAtForeground;    // 是否在前台
    BOOL                            _isPhoneInterupt; // 是否是电话中断
    BOOL                            _hasHandleCall;
    
@protected
    BOOL                           _isExiting;      // 正在退出，主要是防止界面上多次弹出退出提醒框
    BOOL                           _isHost;         // YES：当前是主播，NO：当前是观众
}

@property (nonatomic, readonly) BOOL isExiting;
@property (nonatomic, readonly) id<IMHostAble> currentUser;
@property (nonatomic, readonly) id<AVRoomAble> roomInfo;

// 创建房间
- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user;

// 警告退出
- (void)alertExitLive;

// 实际退出
- (void)exitLive;

// 外部通过此方法更新_isExiting的值
- (void)willExitLiving;

@end


// 供子类重写
@interface TCAVBaseViewController (ProtectedMethod)

// 添加电话监听: 进入直播成功后监听
- (void)addPhoneListener;

- (void)handlePhostEvent:(CTCall *)call;

// 移除电话监听：退出直播后监听
- (void)removePhoneListener;

// 添加AVSDK相关的监听
- (void)addAVSDKObservers;

// 直播前先开始检查网络
// 无网不进
// wifi：直接进
// 移动网：提示，用户选择性进行
- (void)checkNetWorkBeforeLive;

// 添加网络监听,只在直播的过程中监听，创建房间过程中不监听
// 进入直播成功后监听
- (void)addNetwokChangeListner;

// 网络类型有变化
- (void)onNetworkChanged;

// 网络断开与重联
- (void)onNetworkConnected;

// 退出直播前取消
- (void)removeNetwokChangeListner;

// 创建RoomEngine
- (void)createRoomEngine;

// 因权限原因导致无法正常作用AVSDK时，退出
- (void)exitOnNotPermitted;

// 进入该界面后进行检查
- (void)checkAndEnterAVRoom;

// 退出直播界面
- (void)onExitLiveUI;

// App进入前台处理，主播播重开渲染以及相机
// 如果用户退后台时有作取消取求画面操作（见onAppEnterBackground描述），再进入时，记得进入前台后再[QAVEndpoint requestViewList]来恢复界面
- (void)onAppEnterForeground;

// App退到后台，主播播关渲染以及相机
// App主端端退后台时间过长（90s左右），AVSDK会自动解散直播间，请注意该此逻辑，App自身控制好业务逻辑
// 另外直播过程中，主播需要定时上传心跳，超过一定时间没上传，随心播后台会自动解散IM聊天室，这也会解散直播间
// 另外请注意：该类及其子类中，考虑到体验问题（退后台取消请求画面，进前台再请求画面会比较慢，短时间内体验不好），没有处理这种情况：观众端退后台时，没有取消请求视频数据，AVSDK不编解码，界面上不显示而以。
// 如果用户要处理这样的事件，请自行添加[QAVEndpoint cancelAllview]方法，并在onAppEnterForeground中恢复请求
- (void)onAppEnterBackground;

// 进入直播回调
- (void)onEnterLiveSucc:(BOOL)succ tipInfo:(NSString *)tip;

// 退出直播回调
- (void)onExitLiveSucc:(BOOL)succ tipInfo:(NSString *)tip;

@end