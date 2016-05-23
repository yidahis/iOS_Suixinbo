//
//  C2CVoiceViewController.m
//  TCAVIntergrateDemo
//
//  Created by AlexiChen on 16/5/16.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "C2CVoiceViewController.h"

@interface C2CVoiceViewController ()

@end

@implementation C2CVoiceViewController

- (void)addLiveView
{
    // 子类重写
    UserAppBaseUIViewController *uivc = [[UserAppBaseUIViewController alloc] initWith:self];
    [self addChild:uivc inRect:self.view.bounds];
    
    _liveView = uivc;
}

- (NSInteger)defaultAVHostConfig
{
    // 添加推荐配置
    return EAVCtrlState_Speaker | EAVCtrlState_Mic;
    
}


@end
