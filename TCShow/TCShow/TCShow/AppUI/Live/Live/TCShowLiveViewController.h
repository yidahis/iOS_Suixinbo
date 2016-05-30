//
//  TCShowLiveViewController.h
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveViewController.h"


// 主要控制直播时界面的IM交互逻辑
@interface TCShowLiveUIViewController : TCAVLiveBaseViewController<TCShowLiveTopViewDelegate>
{
@protected
    TCShowLiveView      *_liveView;
    NSTimer             *_heartTimer;
    BOOL                _isPostLiveStart;
}

@property (nonatomic, assign) BOOL isPostLiveStart;

#if kSupportIMMsgCache

// 更新消息
- (void)onUIRefreshIMMsg:(AVIMCache *)cache;
// 更新点赞
- (void)onUIRefreshPraise:(AVIMCache *)cache;

#endif

- (BOOL)isPureMode;

- (void)uiStartLive;

- (void)uiEndLive;

- (void)showLiveResult:(TCShowLiveListItem *)item;

- (void)onStartPush:(BOOL)succ pushRequest:(TCAVLiveRoomPushRequest *)req;
- (void)onStartRecord:(BOOL)succ recordRequest:(TCAVLiveRoomRecordRequest *)req;

@end


//==================================================================================================================================================================

@interface TCShowLiveViewController : TCAVLiveViewController
{
#if kSupportIMMsgCache
    // 方案一:
    // 使用AVSDK刷新时，注意SDK的回调频繁为一秒多少次，调试时注意AVSDK频率，
    // 不适用于互动直播的场景，但可以比较灵活的控制不同的消息进行刷新控制
    NSInteger           _uiRefreshCount;
    
    // 方案二:
    // 其他方案，也可以通过计时器去做设置刷新界面的BOOL值，
    // 然后在- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame;
    // 回调里面发现可以刷新界面，然后再做更新界面操作，本质是一样的
    // 缺点：所有消息都是固定频率刷新
    // 在TCShowMultiLiveViewController 中进行演示
#endif
}

#if kSupportIMMsgCache
// 使用AVSDK刷新时，注意SDK的回调频繁为一秒多少次，调试时注意AVSDK频率，
// 直播场景下，因为每个人的只有一路视频，所有收发消息，完会可以靠roomEngine - (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame; 回调处理
// 互动直播场景下，不能这样处理，为各路直播均会走回调，所以单靠_uiRefreshCount来护刷新是不行的
// 互动直播场景下再介绍具体处理方式
- (void)renderUIByAVSDK;
#endif



@end



