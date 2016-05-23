//
//  UserAppBaseUIViewController.m
//  TCAVIntergrateDemo
//
//  Created by AlexiChen on 16/5/16.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "UserAppBaseUIViewController.h"

@interface UserAppBaseUIViewController ()

@end

@implementation UserAppBaseUIViewController


- (void)addOwnViews
{
    _closeUI = [[UIButton alloc] init];
    [_closeUI setTitle:@"关闭" forState:UIControlStateNormal];
    _closeUI.backgroundColor = [kLightGrayColor colorWithAlphaComponent:0.5];
    [_closeUI addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeUI];
}


- (void)layoutOnIPhone
{
    [_closeUI sizeWith:CGSizeMake(60, 44)];
    [_closeUI alignParentTop];
    [_closeUI alignParentRight];
}

- (void)onClose
{
    [_liveController alertExitLive];
}



@end
