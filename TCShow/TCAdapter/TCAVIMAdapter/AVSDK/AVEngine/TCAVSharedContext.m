//
//  TCAVSharedContext.m
//  TCShow
//
//  Created by AlexiChen on 16/5/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kIsUseAVSDKAsLiveScene
#import "TCAVSharedContext.h"

@implementation TCAVSharedContext

static QAVContext *kSharedConext = nil;
static BOOL isQAVContextInitSucc = NO;


+ (QAVContext *)sharedContext
{
    if (!isQAVContextInitSucc)
    {
        return nil;
    }
    return kSharedConext;
}

+ (void)configWithStartedContext:(QAVContext *)context
{
    if (!context && !isQAVContextInitSucc)
    {
        TCAVIMLog(@"配置Context");
        isQAVContextInitSucc = YES;
        kSharedConext = context;
    }
}

+ (void)destroyContext;
{
    if (kSharedConext)
    {
        TCAVIMLog(@"销毁Context");
        QAVResult res = [kSharedConext stopContext:^(QAVResult result) {
            [QAVContext DestroyContext:kSharedConext];
            isQAVContextInitSucc = NO;
        }];
        
        if (res != QAV_OK)
        {
            isQAVContextInitSucc = NO;
            DebugLog(@"stopContext 不成功:%d", (int)res);
        }
    }
}

@end
#endif
