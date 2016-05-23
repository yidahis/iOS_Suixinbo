//
//  TCShowMultiSubView.h
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>


// 多人互动直播时：viewcontroller.view控件自底向上顺序为
// 1.TCAVMultiLivePreview
// 2.用户交互界面
// 3.小窗口界面视频
// 但是：直播时，渲染的小窗口视频在TCAVMultiLivePreview，上面有用户交互界面挡住，所以无法直小操作，于是在最顶层加上透明小窗口，通过操作小窗口来切换


@class TCShowMultiSubView;

@protocol TCShowMultiSubViewDelegate <NSObject>

// 邀请超时
- (void)onMultiSubViewInviteTimeout:(TCShowMultiSubView *)sub;

// 挂断
- (void)onMultiSubViewHangUp:(TCShowMultiSubView *)sub;

// 点击
- (void)onMultiSubViewClick:(TCShowMultiSubView *)sub;

@end


@interface TCShowMultiSubView : UIView
{
@protected
    UIImageView *_receiverHeadIcon;
    UILabel     *_stateTip;
    UIButton    *_hangUp;
    
    NSTimer     *_timer;
    
@protected
    __weak id<AVMultiUserAble> _interactUser;
}

@property (nonatomic, weak) id<TCShowMultiSubViewDelegate> delegate;

@property (nonatomic, weak) id<AVMultiUserAble> interactUser;


// 添加后会自动作邀请计时
- (instancetype)initWith:(id<AVMultiUserAble>)interactUser;

// 本地开摄像头的，显示自己窗口时调用,currentUser为当前用户
// 不会添加自动邀请逻辑
- (instancetype)initWithSelf:(id<AVMultiUserAble>)currentUser;

// 即将移除
- (void)willRemove;

// 请求对方画面,一分钟内未请求到，返回请求超时
- (void)startConnect;


// 请求成功
- (void)onConnectSucc;

//// 对应因视频中断，导致没有画面过来
//- (void)onVideoLost;

@end
