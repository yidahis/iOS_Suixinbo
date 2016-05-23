//
//  IMAAppDelegate.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAAppDelegate.h"

#import "IMALoginViewController.h"

@implementation IMAAppDelegate

// 进入登录界面
// 用户可重写
- (void)enterLoginUI
{
    IMALoginViewController *vc = [[IMALoginViewController alloc] init];
    self.window.rootViewController = vc;
}


//==================================
// URL Scheme处理
- (BOOL)application:(UIApplication*)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame)
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if([url.scheme compare:WX_APP_ID] == NSOrderedSame)
    {
        if ([self.window.rootViewController conformsToProtocol:@protocol(WXApiDelegate)])
        {
            id<WXApiDelegate> lgv = (id<WXApiDelegate>)self.window.rootViewController;
            [WXApi handleOpenURL:url delegate:lgv];
            
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame)
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if([url.scheme compare:WX_APP_ID] == NSOrderedSame)
    {
        if ([self.window.rootViewController conformsToProtocol:@protocol(WXApiDelegate)])
        {
            id<WXApiDelegate> lgv = (id<WXApiDelegate>)self.window.rootViewController;
            [WXApi handleOpenURL:url delegate:lgv];
        }
    }
    
    return YES;
}



@end
