//
//  TCAVMultiLivePreview.m
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVMultiLivePreview.h"

@implementation TCAVMultiLivePreview

- (void)addRenderFor:(id<AVMultiUserAble>)user
{
    // 判断是否已添加
    if (user)
    {
        _imageView.frame = self.bounds;
        
        NSString *uid = [user imUserId];
        AVGLRenderView *glView = [_imageView getSubviewForKey:uid];
        
        if (!glView)
        {
            glView = [[AVGLRenderView alloc] initWithFrame:_imageView.bounds];
            [_imageView addSubview:glView forKey:uid];
        }
        else
        {
            DebugLog(@"已存在的%@渲染画面，不重复添加", uid);
        }
        
        [glView setHasBlackEdge:NO];
        glView.nickView.hidden = YES;
        [glView setBoundsWithWidth:0];
        [glView setDisplayBlock:NO];
        [glView setCuttingEnable:YES];
        
        CGRect rect = [user avInteractArea];
        if (!CGRectIsEmpty(rect))
        {
            [glView setFrame:[user avInteractArea]];
        }
        
        if (![_imageView isDisplay])
        {
            [_imageView startDisplay];
        }
        
    }
}

- (void)updateAllRenderOf:(NSArray *)users
{
    for (id<AVMultiUserAble> user in users)
    {
        AVGLRenderView *glView = [_imageView getSubviewForKey:[user imUserId]];
        if (glView)
        {
            CGRect rect = [user avInteractArea];
            glView.frame = rect;
        }
    }
}


- (void)updateRenderFor:(id<AVMultiUserAble>)user
{
    AVGLRenderView *view = [_imageView getSubviewForKey:[user imUserId]];
    if (!view)
    {
        [self addRenderFor:user];
    }
    else
    {
        CGRect rect = [user avInteractArea];
        DebugLog(@"updateRenderFor======>>>>>>>%@ %@", [user imUserId], NSStringFromCGRect(rect));
        if (!CGRectIsEmpty(rect))
        {
            [view setFrame:rect];
        }
    }
}

- (void)render:(QAVVideoFrame *)frame ofUser:(id<AVMultiUserAble>)user mirrorReverse:(BOOL)reverse isFullScreen:(BOOL)isFullScreen
{
    if ([_imageView isDisplay])
    {
        BOOL isLocal = frame.identifier.length;
        if (isLocal)
        {
            // 为多人的时候要处理
            frame.identifier = [[IMAPlatform sharedInstance].host imUserId];
        }
        
        [_frameDispatcher dispatchVideoFrame:frame isLocal:isLocal isFront:reverse isFull:isFullScreen];
    }
}


- (BOOL)switchRender:(id<AVMultiUserAble>)user withMainUser:(id<AVMultiUserAble>)mainuser
{
    BOOL succ = [_imageView switchSubviewForKey:[user imUserId] withKey:[mainuser imUserId]];
    if (succ)
    {
        UIView *mainView = [mainuser avInvisibleInteractView];
        CGRect mainRect = [mainuser avInteractArea];
        
        UIView *iuView = [user avInvisibleInteractView];
        CGRect iuRect = [user avInteractArea];
        
        [user setAvInvisibleInteractView:mainView];
        [user setAvInteractArea:mainRect];
        
        [mainuser setAvInvisibleInteractView:iuView];
        [mainuser setAvInteractArea:iuRect];
        
        // 更新显示的位置
        [self updateRenderFor:user];
        [self updateRenderFor:mainuser];
        
    }
    return succ;
}

- (BOOL)replaceRender:(id<AVMultiUserAble>)user withUser:(id<AVMultiUserAble>)newUser
{
    // 先交换二者的位置参数
    BOOL succ = [_imageView switchSubviewForKey:[user imUserId] withKey:[newUser imUserId]];
    if (succ)
    {
        UIView *iuView = [user avInvisibleInteractView];
        CGRect iuRect = [user avInteractArea];
        
        [newUser setAvInvisibleInteractView:iuView];
        [newUser setAvInteractArea:iuRect];
        
        // 更新显示的位置
        [self updateRenderFor:newUser];
        [self removeRenderOf:user];
        
    }
    return succ;
}

@end
