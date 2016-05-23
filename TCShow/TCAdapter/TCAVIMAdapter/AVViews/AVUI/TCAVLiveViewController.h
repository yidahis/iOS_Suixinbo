//
//  TCAVLiveViewController.h
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVBaseViewController.h"

// 用子于类重写UI交互层逻辑
@protocol TCAVLiveUIAbleView <NSObject>

@required

@property (nonatomic, weak) TCAVBaseViewController *liveController;
@property (nonatomic, weak) TCAVBaseRoomEngine *roomEngine;
@property (nonatomic, weak) AVIMMsgHandler *msgHandler;

- (instancetype)initWith:(TCAVBaseViewController *)controller;

- (void)onEnterBackground;
- (void)onEnterForeground;

@end


// =========================================================================
// 直播时，分离出来的界面基类，以供用户自定义
@interface TCAVLiveBaseViewController : BaseViewController<AVIMMsgListener, TCAVLiveUIAbleView, AVIMMsgListener>
{
@protected
    __weak TCAVBaseViewController   *_liveController;
    __weak TCAVBaseRoomEngine       *_roomEngine;
    __weak AVIMMsgHandler           *_msgHandler;
    
}

@property (nonatomic, weak) TCAVBaseViewController *liveController;
@property (nonatomic, weak) TCAVBaseRoomEngine *roomEngine;
@property (nonatomic, weak) AVIMMsgHandler *msgHandler;


- (instancetype)initWith:(TCAVBaseViewController *)controller;

// over write by subclass
- (void)onEnterBackground;
- (void)onEnterForeground;

@end

//===========================================================================

// 主要将是AVSDK进入直播间后，到开启摄像头，以及画面渲染逻辑
// 并添加：支持IM时(_enableIM = YES)，直播聊天互动接入(具体AVIMMsgListener事件回调作空实现，待子类重写)
// 注意：界面中不要做太多的动画，非常耗CPU
@interface TCAVLiveViewController : TCAVBaseViewController
{
@protected
    TCAVLivePreview                     *_livePreview;
    
@protected
    // 将用户自定的的直播界面与直播控制器分离
    // 主要控制IM相关的逻辑
    id<TCAVLiveUIAbleView>              _liveView;
    
@protected
    BOOL                _enableIM;      // 是否需要支持IM，在viewDidLoad之前设置才有效，默认为YES
    AVIMMsgHandler      *_msgHandler;   // 直播间内消息处理模块
}
@property (nonatomic, assign) BOOL enableIM;
@property (nonatomic, readonly) TCAVLivePreview *livePreview;

@end


@interface TCAVLiveViewController (ProtectedMethod)

// 进入到直播间成功后，请求主播画面
- (void)requestHostViewOnEnterLiveSucc;

// 添加最底层渲染层
- (void)addLivePreview;

// 添加界面上的交互层
- (void)addLiveView;

- (void)layoutLiveView;

- (NSInteger)defaultAVHostConfig;

- (NSString *)cameraAuthorizationTip;

- (void)prepareIMMsgHandler;

- (void)releaseIMMsgHandler;

@end
