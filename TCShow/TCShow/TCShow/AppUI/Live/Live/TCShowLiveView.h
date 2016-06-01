//
//  TCShowLiveView.h
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShowLiveView : UIView<TCShowLiveBottomViewDelegate, TCShowLiveTimeViewDelegate>
{
@protected
    UITextView                  *_parTextView;
    
@protected
    TCShowLiveTopView           *_topView;

    
    TCShowLiveMessageView       *_msgView;
    TCShowLiveBottomView        *_bottomView;
    
    TCShowLiveInputView         *_inputView;
    BOOL                         _inputViewShowing;
    
@protected
    __weak id<TCShowLiveRoomAble>   _room;
    __weak TCAVLiveRoomEngine       *_roomEngine;
    __weak AVIMMsgHandler           *_msgHandler;
}

@property (nonatomic, readonly) TCShowLiveTopView *topView;
@property (nonatomic, readonly) TCShowLiveMessageView *msgView;
@property (nonatomic, readonly) TCShowLiveBottomView *bottomView;

@property (nonatomic, weak) TCAVLiveRoomEngine *roomEngine;
@property (nonatomic, weak) AVIMMsgHandler *msgHandler;
@property (nonatomic, readonly) BOOL isPureMode;


- (instancetype)initWith:(id<TCShowLiveRoomAble>)room;

- (void)hideInputView;

- (void)startLive;
- (void)pauseLive;
- (void)resumeLive;

- (void)onRecvPraise;
#if kSupportIMMsgCache
- (void)onRecvPraise:(AVIMCache *)cache;
#endif

- (void)onTapBlank:(UITapGestureRecognizer *)tap;

- (void)showPar:(BOOL)show;
- (void)onRefreshPAR;

// for 多人互动
- (void)onClickSub:(id<AVMultiUserAble>)user;

@end
