//
//  TCShowMultiLiveViewController.h
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveViewController.h"

@class TCShowMultiUserListView;

@protocol TCShowMultiUserListViewDelegate <NSObject>

@required

- (BOOL)onUserListView:(TCShowMultiUserListView *)view isInteratcUser:(id<AVMultiUserAble>)user;
- (void)onUserListView:(TCShowMultiUserListView *)view clickUser:(id<AVMultiUserAble>)user;

@end

@interface TCShowMultiUserListView : UIView<UITableViewDataSource, UITableViewDelegate>
{
@protected
    UIView          *_backView;
    UITableView     *_tableView;
@protected
    NSArray         *_userList;
}

@property (nonatomic, weak) id<TCShowMultiUserListViewDelegate> delegate;

- (instancetype)initWith:(NSArray *)array;

- (void)show;

@end

//=========================================================================

@interface TCShowMultiUILiveViewController : TCShowLiveUIViewController<TCShowMultiUserListViewDelegate, TCShowMultiViewDelegate, TCShowLiveBottomViewMultiDelegate>

- (void)assignWindowResourceTo:(id<AVMultiUserAble>)user isInvite:(BOOL)inviteOrAuto;
- (void)recycleWindowResourceTo:(id<AVMultiUserAble>)user;
- (void)requestViewOf:(id<AVMultiUserAble>)user;
- (void)updateUserCtrlState:(id<AVMultiUserAble>)user;

- (void)onRequestViewCompleted:(BOOL)succ;

@end

//=========================================================================
@interface TCShowMultiLiveViewController : TCAVMultiLiveViewController
#if kSupportIMMsgCache
{

// 方案一:TCShowLiveViewController 演示了
// 使用AVSDK刷新时，注意SDK的回调频繁为一秒多少次，调试时注意AVSDK频率，
// NSInteger           _uiRefreshCount;

// 方案二:
// 其他方案，也可以通过计时器去做设置刷新界面的BOOL值，
// 然后在- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame;
// 回调里面发现可以刷新界面，然后再做更新界面操作，本质是一样的
// 在TCShowMultiLiveViewController 中进行演示
// 如果
    BOOL        _canRenderNow;
    NSTimer     *_renderTimer;
}

- (void)startRenderTimer;
- (void)stopRenderTimer;

#endif

@end
