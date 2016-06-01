//
//  TCShowLiveRoomEngine.m
//  TCShow
//
//  Created by AlexiChen on 16/5/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveRoomEngine.h"

@implementation TCShowLiveRoomEngine

- (void)enterIMLiveChatRoom:(id<AVRoomAble>)room
{
#if kSupportTimeStatistics
    [self onWillEnterLive];
#endif
    
    __weak TCAVLiveRoomEngine *ws = self;
    __weak id<TCAVRoomEngineDelegate> wd = _delegate;
    __weak id<AVRoomAble> wr = room;
    
#if kSupportTimeStatistics
    __weak NSDate *wl = _logStartDate;
#endif
    BOOL isHost = [self isHostLive];
    [[IMAPlatform sharedInstance] asyncEnterAVChatRoomWithAVRoomID:room succ:^(id<AVRoomAble> room) {
#if kSupportTimeStatistics
        NSDate *date = [NSDate date];
        
        TCAVIMLog(@"%@ 从进房到进入IM聊天室（%@）: 开始进房时间:%@ 创建聊天室完成时间:%@ 总耗时 :%0.3f (s)", isHost ? @"主播" : @"观众", [room liveIMChatRoomId] , [kTCAVIMLogDateFormatter stringFromDate:wl], [kTCAVIMLogDateFormatter stringFromDate:date] , -[wl timeIntervalSinceDate:date]);
#endif
        [ws onRealEnterLive:room];
    } fail:^(int code, NSString *msg) {
        [wd onAVEngine:ws enterRoom:wr succ:NO tipInfo:isHost ? @"创建直播聊天室失败" : @"加入直播聊天室失败"];
    }];
}


- (NSString *)roomControlRole
{
    // Spear上配置对应的有用户角色与配置
    if ([self isHostLive])
    {
        // 主播进入直播间对应的角色名
        return @"LiveHost";
    }
    else
    {
        // 观从进入直播间对应的角色名
        return @"NormalGuest";
    }
}


@end


@implementation TCShowMultiLiveRoomEngine

- (void)enterIMLiveChatRoom:(id<AVRoomAble>)room
{
#if kSupportTimeStatistics
    [self onWillEnterLive];
#endif
    
    __weak TCAVLiveRoomEngine *ws = self;
    __weak id<TCAVRoomEngineDelegate> wd = _delegate;
    __weak id<AVRoomAble> wr = room;
#if kSupportTimeStatistics
    __weak NSDate *wl = _logStartDate;
#endif
    BOOL isHost = [self isHostLive];
    [[IMAPlatform sharedInstance] asyncEnterAVChatRoomWithAVRoomID:room succ:^(id<AVRoomAble> room) {
#if kSupportTimeStatistics
        NSDate *date = [NSDate date];
        TCAVIMLog(@"%@ 从进房到进入IM聊天室（%@）: 开始进房时间:%@ 创建聊天室完成时间:%@ 总耗时 :%0.3f (s)", isHost ? @"主播" : @"观众", [room liveIMChatRoomId] , [kTCAVIMLogDateFormatter stringFromDate:wl], [kTCAVIMLogDateFormatter stringFromDate:date] , -[wl timeIntervalSinceDate:date]);
#endif
        [ws onRealEnterLive:room];
    } fail:^(int code, NSString *msg) {
        [wd onAVEngine:ws enterRoom:wr succ:NO tipInfo:isHost ? @"创建直播聊天室失败" : @"加入直播聊天室失败"];
    }];
}

- (NSString *)interactUserRole
{
    return @"InteractUser";
}

@end