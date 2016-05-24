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
#if DEBUG
    // 说明是开发
    return @"TCShowDEV";
    
#else
    
#if kAppStoreVersion
    // 上传AppStore时使用的配置
    return @"TCShowAppStore";
#else
    
#if kBetaVersion
    // 说明是用于演示
    return @"TCShowBeta";
#else
    // 说明是测试在用
    return @"TCShowTest";
#endif
    
#endif
    
#endif
    
    
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

- (NSString *)roomControlRole
{
    
#if DEBUG
    // 说明是开发
    return @"TCShowDEV";
    
#else
    
#if kAppStoreVersion
    // 上传AppStore时使用的配置
    return @"TCShowAppStore";
#else
    
#if kBetaVersion
    // 说明是用于演示
    return @"TCShowBeta";
#else
    // 说明是测试在用
    return @"TCShowTest";
#endif
    
#endif
    
#endif
    
    
}

@end