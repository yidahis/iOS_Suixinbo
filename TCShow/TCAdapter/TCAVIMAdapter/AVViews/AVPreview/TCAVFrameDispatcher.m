//
//  TCAVFrameDispatcher.m
//  TCShow
//
//  Created by AlexiChen on 16/4/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVFrameDispatcher.h"

@implementation TCAVFrameDispatcher

- (void)dispatchVideoFrame:(QAVVideoFrame *)frame isLocal:(BOOL)isLocal isFront:(BOOL)frontCamera isFull:(BOOL)isFull
{
    NSString *renderKey = frame.identifier;
    
    AVGLRenderView *glView = [self.imageView getSubviewForKey:renderKey];
    
    if (glView)
    {
        unsigned int selfFrameAngle = 1;//[self didRotate:YES];
        unsigned int peerFrameAngle = frame.frameDesc.rotate % 4;
        float degree;
        
        if (isLocal)
        {
            selfFrameAngle = 0;
            peerFrameAngle = 0;
            [glView setNeedMirrorReverse:frontCamera];
        }
        else
        {
            [glView setNeedMirrorReverse:NO];
        }
        
        glView.isFloat = !isFull;
        
        
        degree = [self calcRotateAngle:peerFrameAngle selfAngle:selfFrameAngle];
        
        AVGLImage * image = [[AVGLImage alloc] init];
        image.angle = isLocal ? degree + 180.0f : degree;
        image.data = (Byte *)frame.data;
        image.width = (int)frame.frameDesc.width;
        image.height = (int)frame.frameDesc.height;
        image.isFullScreenShow = [self calcFullScr:peerFrameAngle selfAngle:selfFrameAngle];
        image.viewStatus = VIDEO_VIEW_DRAWING;
        image.dataFormat = isLocal ?  Data_Format_NV12  : Data_Format_I420;
        
        [glView setImage:image];
    }
    
}

- (float)calcRotateAngle:(int)peerFrameAngle selfAngle:(int)frameAngle
{
    float degree = 0.0f;
    
    frameAngle = (frameAngle+peerFrameAngle+3)%4;
    
    // 调整显示角度
    switch (frameAngle)
    {
        case 0:
        {
            degree = -180.0f;
        }
            break;
        case 1:
        {
            degree = -90.0f;
        }
            break;
        case 2:
        {
            degree = 0.0f;
        }
            break;
        case 3:
        {
            degree = 90.0f;
        }
            break;
        default:
        {
            degree = 0.0f;
        }
            break;
    }
    
    return degree;
}

- (BOOL)calcFullScr:(int)peerFrameAngle selfAngle:(int)frameAngle
{
    if ((peerFrameAngle & 1) == 0 && (frameAngle & 1) == 0)
    {
        // 对方和自己都是横屏
        return YES;
    }
    else if ((peerFrameAngle & 1) && (frameAngle & 1))
    {
        // 对方和自己都是竖屏
        return YES;
    }
    else if ((peerFrameAngle & 1) == 0 && (frameAngle & 1))
    {
        // 对方横屏，自己竖屏
        return NO;
    }
    else if ((peerFrameAngle & 1) && (frameAngle & 1) == 0)
    {
        // 对方竖屏，自己横屏
        return NO;
    }
    return YES;
}
@end
