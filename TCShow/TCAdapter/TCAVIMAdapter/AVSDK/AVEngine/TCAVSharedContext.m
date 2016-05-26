//
//  TCAVSharedContext.m
//  TCShow
//
//  Created by AlexiChen on 16/5/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kIsUseAVSDKAsLiveScene
#import "TCAVSharedContext.h"

@interface TCAVSharedContext ()

@property (nonnull, strong) QAVContext *sharedContext;

@end

@implementation TCAVSharedContext

static TCAVSharedContext *kSharedConext = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        kSharedConext = [[TCAVSharedContext alloc] init];
    });
    
    return kSharedConext;
}


+ (QAVContext *)sharedContext
{
    return [TCAVSharedContext sharedInstance].sharedContext;
}

+ (void)configWithStartedContext:(QAVContext *)context
{
    if ([TCAVSharedContext sharedInstance].sharedContext)
    {
        [TCAVSharedContext destroyContextCompletion:^{
            [TCAVSharedContext sharedInstance].sharedContext = context;
        }];
    }
    else
    {
        [TCAVSharedContext sharedInstance].sharedContext = context;
    }
    
}

+ (void)configWithStartedContext:(id<IMHostAble>)host completion:(CommonVoidBlock)block
{
    if (kSharedConext == nil)
    {
        QAVContextConfig *config = [[QAVContextConfig alloc] init];
        
        NSString *appid = [host imSDKAppId];
        
        config.sdk_app_id = appid;
        config.app_id_at3rd = appid;
        config.identifier = [host imUserId];
        config.account_type = [host imSDKAccountType];
        QAVContext *context = [QAVContext CreateContext:config];
        
        [context startContext:^(QAVResult result) {
            if (block)
            {
                block();
            }
            [TCAVSharedContext sharedInstance].sharedContext = context;
            DebugLog(@"共享的QAVContext = %p", context);
        }];
    }
}

+ (void)destroyContextCompletion:(CommonVoidBlock)block
{
    if (kSharedConext)
    {
        TCAVIMLog(@"销毁Context");
        QAVResult res = [[TCAVSharedContext sharedInstance].sharedContext stopContext:^(QAVResult result) {
            [QAVContext DestroyContext:[TCAVSharedContext sharedInstance].sharedContext];
            kSharedConext = nil;
            
            if (block)
            {
                block();
            }
        }];
        
        DebugLog(@"res = %d", (int)res);
    }
}

@end
#endif
