//
//  TCAVLivePreview.m
//  TCShow
//
//  Created by AlexiChen on 15/11/16.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "TCAVLivePreview.h"

@implementation TCAVLivePreview

- (void)dealloc
{
    [self stopPreview];
    [_imageView destroyOpenGL];
    _imageView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _imageView = [[AVGLBaseView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = kBlackColor;
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        [_imageView setBackGroundTransparent:YES];
        [self addSubview:_imageView];
        
        @try
        {
            [_imageView initOpenGL];
            
            _frameDispatcher = [[TCAVFrameDispatcher alloc] init];
            _frameDispatcher.imageView = _imageView;
            DebugLog(@"初始化OpenGL成功");
            
        }
        @catch (NSException *exception)
        {
            DebugLog(@"OpenGL 初台化异常");
        }
        @finally
        {
            
        }
    }
    return self;
}

- (void)startPreview
{
    if (_imageView)
    {
        [_imageView startDisplay];
    }
    
}

- (void)stopPreview
{
    if (_imageView)
    {
        [_imageView stopDisplay];
    }
}

- (void)removeRenderOf:(id<IMUserAble>)user
{
    if (user)
    {
        [_imageView removeSubviewForKey:[user imUserId]];
    }
}

- (void)addRenderFor:(id<IMUserAble>)user
{
    if (!user)
    {
        return;
    }
    
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
    
    glView.frame = _imageView.bounds;
    [glView setHasBlackEdge:NO];
    glView.nickView.hidden = YES;
    [glView setBoundsWithWidth:0];
    [glView setDisplayBlock:NO];
    [glView setCuttingEnable:YES];
    
    if (![_imageView isDisplay])
    {
        [_imageView startDisplay];
    }
}

- (void)updateRenderFor:(id<AVMultiUserAble>)user
{
    AVGLRenderView *view = [_imageView getSubviewForKey:[user imUserId]];
    if (!view)
    {
        [self addRenderFor:user];
    }
}

- (void)render:(QAVVideoFrame *)frame mirrorReverse:(BOOL)reverse fullScreen:(BOOL)fullShow
{    
    if ([_imageView isDisplay])
    {
        BOOL isLocal = frame.identifier.length == 0;
        if (isLocal)
        {
            // 为多人的时候要处理
            frame.identifier = [[IMAPlatform sharedInstance].host imUserId];
        }
        
        [_frameDispatcher dispatchVideoFrame:frame isLocal:isLocal isFront:reverse isFull:fullShow];
    }
}

- (void)relayoutFrameOfSubViews
{
    _imageView.frame = self.bounds;
}

@end