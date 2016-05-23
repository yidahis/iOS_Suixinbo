//
//  FunctionViewController.m
//  TCShow
//
//  Created by AlexiChen on 16/4/22.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "FunctionViewController.h"

@implementation FunctionViewController


- (void)configOwnViews
{
    _data = [NSMutableArray array];
    
    MenuItem *item = [[MenuItem alloc] initWithTitle:@"直播" icon:nil action:^(id<MenuAbleItem> menu) {
        IMAHost *host = [IMAPlatform sharedInstance].host;
        
        [host setAvInteractArea:CGRectZero];
        
        if ([[host imUserId] isEqualToString:@"86-18800000000"])
        {
            
            TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
            item.host = host;
            item.title = @"测试直播";
            item.cover = [item.host imUserIconUrl];
            item.avRoomId = 20000;
            item.chatRoomId = @"400000";
            
            TCShowLiveViewController *vc = [[TCShowLiveViewController alloc] initWith:item user:host];
            [[AppDelegate sharedAppDelegate] pushViewController:vc];
        }
        else
        {
            // 进入直播间
            TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
            
            TCShowUser *user = [[TCShowUser alloc] init];
            user.uid = @"86-18800000000";
            item.host = user;
            
            item.title = @"测试直播";
            item.cover = [item.host imUserIconUrl];
            item.avRoomId = 20000;
            item.chatRoomId = @"400000";
            
            TCShowLiveViewController *vc = [[TCShowLiveViewController alloc] initWith:item user:host];
            [[AppDelegate sharedAppDelegate] pushViewController:vc];
            
        }
        
    }];
    [_data addObject:item];
    
    
    item = [[MenuItem alloc] initWithTitle:@"互动直播" icon:nil action:^(id<MenuAbleItem> menu) {
        
        IMAHost *host = [IMAPlatform sharedInstance].host;
        
        [host setAvInteractArea:CGRectZero];
        
        if ([[host imUserId] isEqualToString:@"86-18800000000"])
        {
            // 1. 配置直播房间信息id<AVRoomAble>
            TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
            item.host = host;
            item.title = @"测试直播";
            item.cover = [item.host imUserIconUrl];
            item.avRoomId = 10000;
            item.chatRoomId = @"500000";
            
            // 2.创建直播界面，此处传入的Host为当前本机用户
            TCShowMultiLiveViewController *vc = [[TCShowMultiLiveViewController alloc] initWith:item user:host];
            // 是否需要直播聊天室，默认YES
            // vc.enableIM = YES;
            
            // 3.进入直播界面
            [[AppDelegate sharedAppDelegate] pushViewController:vc];
            
            // 进入界面后，直播界面内部会自动启动直播引擎，然后开始进入直播流程
            
        }
        else
        {
            // 1. 配置直播房间信息id<AVRoomAble>
            // 本处使用测试代码
            // 进入直播间
            TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
            
            // 配置直播间主播信息
            TCShowUser *user = [[TCShowUser alloc] init];
            user.uid = @"86-18800000000";
            item.host = user;
            
            item.title = @"测试直播";
            item.cover = [item.host imUserIconUrl];
            item.avRoomId = 10000;
            item.chatRoomId = @"500000";
            
             // 2.创建直播界面，此处传入的user参数为本机登录IMSDK的用户
            TCShowMultiLiveViewController *vc = [[TCShowMultiLiveViewController alloc] initWith:item user:[IMAPlatform sharedInstance].host];
            // 是否需要直播聊天室，默认YES
            // vc.enableIM = YES;
            
            // 3.进入直播界面
            [[AppDelegate sharedAppDelegate] pushViewController:vc];
            // 进入界面后，直播界面内部会自动启动直播引擎，然后开始进入直播流程
        }
    }];
    [_data addObject:item];
    
}

@end
