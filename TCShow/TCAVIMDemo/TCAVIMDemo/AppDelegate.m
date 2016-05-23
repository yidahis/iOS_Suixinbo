//
//  AppDelegate.m
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/16.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (instancetype)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)enterMainUI
{
    if (!_liveHost)
    {

        // 用户修改默认主播角色， 主要是uid
        _liveHost = [[TCUser alloc] init];
        _liveHost.uid = @"alexis";
        _liveHost.name = @"alexis";
        _liveHost.icon = nil;
        
        _liveRoom = [[TCAVRoom alloc] init];
        _liveRoom.liveAVRoomId = 3000000;
        _liveRoom.liveHost = _liveHost;
        _liveRoom.liveIMChatRoomId = @"3000000";
        _liveRoom.liveTitle = @"alexis Live";
    }
    self.window.rootViewController = [[TarBarController alloc] init];
}

@end
