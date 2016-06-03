//
//  TarBarController.m
//  JShow
//
//  Created by AlexiChen on 16/2/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TarBarController.h"


@interface TarBarController ()<UITabBarControllerDelegate>


@end

@implementation TarBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTabBar];
}

#pragma mark 初始化Tab
- (void)initTabBar
{
    [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor flatWhiteColor] size:CGSizeMake(2, 2)]];
    [[UITabBar appearance] setTintColor:kRedColor];
    
    //viewcontrollers
    MainViewController *mainvc = [[MainViewController alloc] init];
    NavigationViewController *mainNav = [[NavigationViewController alloc] initWithRootViewController:mainvc];
    

    SettingViewController *mevc = [[SettingViewController alloc] init];
    NavigationViewController *meNav = [[NavigationViewController alloc] initWithRootViewController:mevc];
    self.viewControllers = [NSArray arrayWithObjects:mainNav, meNav,nil];
    self.delegate = self;
    
    //获取tabBarItem
    UITabBarItem *mainItem = [self.tabBar.items objectAtIndex:0];
    mainItem.title = @"主界面";
    UITabBarItem *myCenterItem = [self.tabBar.items objectAtIndex:1];
    myCenterItem.title = @"个人中心";
    //设置tabBarItem背景图标
    
}



@end