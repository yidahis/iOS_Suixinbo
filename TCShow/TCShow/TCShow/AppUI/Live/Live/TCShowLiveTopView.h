//
//  TCShowLiveTopView.h
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCShowLiveTopView;

@class TCShowLiveTimeView;

@protocol TCShowLiveTopViewDelegate <NSObject>

@optional
- (void)onTopViewCloseLive:(TCShowLiveTopView *)topView;

- (void)onTopViewClickHost:(TCShowLiveTopView *)topView host:(id<IMUserAble>)host;

// for 互动直播
- (void)onTopViewClickInteract:(TCShowLiveTopView *)topView;

#if kBetaVersion
- (void)onTopView:(TCShowLiveTopView *)topView clickPAR:(UIButton *)par;
#endif

@end


@protocol TCShowLiveTimeViewDelegate <NSObject>

- (void)onTimViewTimeRefresh:(TCShowLiveTimeView *)topView;

@end


@interface TCShowLiveTimeView : UIView
{
@protected
    MenuButton          *_liveHost;
    ImageTitleButton    *_liveTime;
    ImageTitleButton    *_liveAudience;
    ImageTitleButton    *_livePraise;
    
@protected
    NSTimer             *_liveTimer;
    
@protected
    __weak id<TCShowLiveRoomAble> _room;
}

@property (nonatomic, readonly) MenuButton *liveHost;

@property (nonatomic, weak) id<TCShowLiveTimeViewDelegate> delegate;

- (instancetype)initWith:(id<TCShowLiveRoomAble>)room;

- (void)startLive;
- (void)pauseLive;
- (void)resumeLive;

- (void)onImUsersEnterLive:(NSArray *)array;
- (void)onImUsersExitLive:(NSArray *)array;

- (void)onRefrshPraiseAndAudience;

@end


@interface TCShowLiveTopView : UIView
{
@protected
    TCShowLiveTimeView *_timeView;
    UIButton           *_close;
#if kBetaVersion
    UILabel            *_roomTip;
    UIButton           *_parButton;
#endif
    
@protected
    __weak id<TCShowLiveRoomAble> _room;
    
}
@property (nonatomic, weak) id<TCShowLiveTopViewDelegate> delegate;
@property (nonatomic, readonly) TCShowLiveTimeView *timeView;
@property (nonatomic, weak) TCShowAVIMHandler *imSender;

- (instancetype)initWith:(id<TCShowLiveRoomAble>)room;

- (void)onImUsersEnterLive:(NSArray *)array;
- (void)onImUsersExitLive:(NSArray *)array;

- (void)startLive;
- (void)pauseLive;
- (void)resumeLive;

- (void)onRefrshPraiseAndAudience;


@end
