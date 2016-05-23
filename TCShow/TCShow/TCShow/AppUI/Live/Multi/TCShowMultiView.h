//
//  TCShowMultiView.h
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TCShowMultiView;

@protocol TCShowMultiViewDelegate <NSObject>

- (void)onMultiView:(TCShowMultiView *)render inviteTimeOut:(id<AVMultiUserAble>)user;

- (void)onMultiView:(TCShowMultiView *)render hangUp:(id<AVMultiUserAble>)user;

- (void)onMultiView:(TCShowMultiView *)render clickSub:(id<AVMultiUserAble>)user;

@end

@interface TCShowMultiView : UIView<TCShowMultiSubViewDelegate>
{
    NSMutableArray  *_multiOverlays;
}

@property (nonatomic, weak) id<TCShowMultiViewDelegate> delegate;


- (TCShowMultiSubView *)overlayOf:(id<AVMultiUserAble>)user;


// 发起者调用
- (void)inviteInteractWith:(id<AVMultiUserAble>)user;
- (void)cancelInteractWith:(id<AVMultiUserAble>)user;
- (void)onRefuesedAndRemove:(id<AVMultiUserAble>)user;
- (void)requestViewOf:(id<AVMultiUserAble>)user;

- (void)onRequestViewOf:(id<AVMultiUserAble>)user complete:(BOOL)succ;
// 打开相机的时候这渡状态
// user为当前用户自己，当其打开像机后，界面上分配窗口给他
- (void)addWindowFor:(id<AVMultiUserAble>)user;

- (void)replaceViewOf:(id<AVMultiUserAble>)user with:(id<AVMultiUserAble>)main;


// 被拒移除

@end
