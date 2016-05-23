//
//  TCShowMultiView.m
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowMultiView.h"

@implementation TCShowMultiView



- (void)inviteInteractWith:(id<AVMultiUserAble>)user
{
    if (!user)
    {
        DebugLog(@"互动用户不能为空");
        return;
    }
    
    if (_multiOverlays.count >= 3)
    {
        DebugLog(@"最多显示三路画面");
        return;
    }
    
    TCShowMultiSubView *subRender = [self overlayOf:user];
    
    //    identifier.role = ELiveUserRole_Interact;
    if (subRender)
    {
        DebugLog(@"已存在需要添加");
        return;
    }
    
    subRender = [[TCShowMultiSubView alloc] initWith:user];
    subRender.delegate = self;
    if (!_multiOverlays)
    {
        _multiOverlays = [NSMutableArray array];
    }
    [_multiOverlays addObject:subRender];
    
    [self addSubview:subRender];
    DebugLog(@"======>>>>>>>>>changeFrame");
    [self changeFrame];
    self.hidden = NO;
}

- (void)requestViewOf:(id<AVMultiUserAble>)user
{
    TCShowMultiSubView *view = [self overlayOf:user];
    [view startConnect];
}

- (void)onRequestViewOf:(id<AVMultiUserAble>)user complete:(BOOL)succ
{
    TCShowMultiSubView *view = [self overlayOf:user];
    if (succ)
    {
        [view onConnectSucc];
    }
    else
    {
        [self cancelInteractWith:user];
    }
}

- (void)changeFrame
{
    CGRect frame = self.frame;
    
    CGSize newSize = [self viewSize];
    
    frame.size.height += newSize.height + kDefaultMargin;
    frame.size = newSize;
    
    self.frame = frame;
    [self layoutSubviews];
}


- (void)onRefuesedAndRemove:(id<AVMultiUserAble>)user
{
    TCShowMultiSubView *sub = [self overlayOf:user];
    if (sub)
    {
//        [sub refused:^{
//            [UIView animateWithDuration:0.3 animations:^{
//                [self removeSubRender:identifier];
//            }];
//        }];
        
    }
}

- (TCShowMultiSubView *)overlayOf:(id<AVMultiUserAble>)user
{
    if (!user)
    {
        return nil;
    }
    
    TCShowMultiSubView *renderView = nil;
    for (TCShowMultiSubView *view in _multiOverlays)
    {
        if ([[[view interactUser] imUserId] isEqualToString:[user imUserId]])
        {
            renderView = view;
            break;
        }
    }
    
    return renderView;
}

//- (void)replaceRender:(TCShowMultiSubView *)render with:(TCShowMultiSubView *)mainrender
//{
//    if ([_renderViews containsObject:render] && mainrender)
//    {
//        if (render.superview)
//        {
//            [render removeFromSuperview];
//        }
//        [_renderViews removeObject:render];
//        
//        if (mainrender.superview)
//        {
//            [mainrender removeFromSuperview];
//        }
//        
//        mainrender.frame = render.frame;
//        [self addSubview:mainrender];
//        [_renderViews addObject:mainrender];
//    }
//}

- (void)cancelInteractWith:(id<AVMultiUserAble>)user
{
    if (!user)
    {
        return;
    }
    
    TCShowMultiSubView *renderView = [self overlayOf:user];
    
    if (renderView)
    {
        [renderView willRemove];
        [renderView removeFromSuperview];
        [_multiOverlays removeObject:renderView];
        renderView = nil;

        DebugLog(@"======>>>>>>>>>changeFrame");
        [self changeFrame];
        
        self.hidden = _multiOverlays.count == 0;
    }
}



#define kMargin 8


- (CGSize)viewSize
{
    const CGSize size = kTCShowMultiSubViewSize;
    
    return CGSizeMake(size.width, kMargin + _multiOverlays.count * (kMargin + size.height));
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect = CGRectInset(rect, 0, kDefaultMargin);
    const CGSize size = kTCShowMultiSubViewSize;
    CGRect subRect = CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
    
    for (TCShowMultiSubView *renderView in _multiOverlays)
    {
        renderView.frame = subRect;
        [renderView.interactUser setAvInteractArea:[renderView relativePositionTo:self.window]];
        subRect.origin.y += subRect.size.height + kMargin;
    }
}


- (void)onMultiSubViewInviteTimeout:(TCShowMultiSubView *)sub
{
    [UIView animateWithDuration:0.3 animations:^{
        [self cancelInteractWith:sub.interactUser];
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:@selector(onMultiView:inviteTimeOut:)]) {
            [_delegate onMultiView:self inviteTimeOut:sub.interactUser];
        }
    }];
    
}

- (void)onMultiSubViewClick:(TCShowMultiSubView *)sub
{
    if ([_delegate respondsToSelector:@selector(onMultiView:clickSub:)])
    {
        [_delegate onMultiView:self clickSub:sub.interactUser];
    }
    
}

- (void)onMultiSubViewHangUp:(TCShowMultiSubView *)sub
{
    if ([_delegate respondsToSelector:@selector(onMultiView:hangUp:)])
    {
        [_delegate onMultiView:self hangUp:sub.interactUser];
    }
}

- (void)addWindowFor:(id<AVMultiUserAble>)user
{
    if (!user)
    {
        DebugLog(@"互动用户不能为空");
        return;
    }
    
    if (_multiOverlays.count >= 3)
    {
        DebugLog(@"最多显示三路画面");
        return;
    }
    
    TCShowMultiSubView *subRender = [self overlayOf:user];
    
    //    identifier.role = ELiveUserRole_Interact;
    if (subRender)
    {
        DebugLog(@"已存在需要添加");
        return;
    }
    
    subRender = [[TCShowMultiSubView alloc] initWithSelf:user];
    subRender.delegate = self;
    if (!_multiOverlays)
    {
        _multiOverlays = [NSMutableArray array];
    }
    [_multiOverlays addObject:subRender];
    
    [self addSubview:subRender];
    
    
    DebugLog(@"======>>>>>>>>>changeFrame");
    [self changeFrame];
    self.hidden = NO;
}

- (void)replaceViewOf:(id<AVMultiUserAble>)user with:(id<AVMultiUserAble>)main
{
    TCShowMultiSubView *sub = [self overlayOf:user];
    sub.interactUser = main;
}

@end
