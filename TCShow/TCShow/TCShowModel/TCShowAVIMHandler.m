//
//  TCShowAVIMHandler.m
//  TCShow
//
//  Created by AlexiChen on 16/4/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowAVIMHandler.h"

@implementation TCShowAVIMHandler


- (id<AVIMMsgAble>)onRecvSenderEnterLiveRoom:(id<IMUserAble>)sender
{
    TCShowLiveMsg *lm = [[TCShowLiveMsg alloc] initWith:sender message:@"进来了"];
    [lm prepareForRender];
    lm.isMsg = NO;
    return lm;
}
- (id<AVIMMsgAble>)onRecvSenderExitLiveRoom:(id<IMUserAble>)sender
{
    TCShowLiveMsg *lm = [[TCShowLiveMsg alloc] initWith:sender message:@"离开了"];
    [lm prepareForRender];
    lm.isMsg = NO;
    return lm;
}

- (id<AVIMMsgAble>)cacheRecvGroupSender:(id<IMUserAble>)sender textMsg:(NSString *)msg
{
    TCShowLiveMsg *lm = [[TCShowLiveMsg alloc] initWith:sender message:msg];
    lm.isMsg = YES;
    [lm prepareForRender];
    return lm;
}

@end


@implementation TCShowAVIMMultiHandler

- (id<AVIMMsgAble>)onRecvSenderEnterLiveRoom:(id<IMUserAble>)sender
{
    TCShowLiveMsg *lm = [[TCShowLiveMsg alloc] initWith:sender message:@"进来了"];
    [lm prepareForRender];
    lm.isMsg = NO;
    return lm;
}
- (id<AVIMMsgAble>)onRecvSenderExitLiveRoom:(id<IMUserAble>)sender
{
    TCShowLiveMsg *lm = [[TCShowLiveMsg alloc] initWith:sender message:@"离开了"];
    [lm prepareForRender];
    lm.isMsg = NO;
    return lm;
}

- (id<AVIMMsgAble>)cacheRecvGroupSender:(id<IMUserAble>)sender textMsg:(NSString *)msg
{
    TCShowLiveMsg *lm = [[TCShowLiveMsg alloc] initWith:sender message:msg];
    lm.isMsg = YES;
    [lm prepareForRender];
    return lm;
}



@end
