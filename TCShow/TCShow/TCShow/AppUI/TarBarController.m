//
//  TarBarController.m
//  JShow
//
//  Created by AlexiChen on 16/2/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TarBarController.h"


@interface TarBarController ()<UITabBarControllerDelegate>
{
    UIButton *_liveButton;
}

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
    //viewcontrollers
    LivingListViewController *mainvc = [[LivingListViewController alloc] init];
    NavigationViewController *mainNav = [[NavigationViewController alloc] initWithRootViewController:mainvc];
    
    UIViewController *second = [[BaseViewController alloc] init];
    
    SettingViewController *mevc = [[SettingViewController alloc] init];
    NavigationViewController *meNav = [[NavigationViewController alloc] initWithRootViewController:mevc];
    self.viewControllers = [NSArray arrayWithObjects:mainNav, second,meNav,nil];
    self.delegate = self;
    
    //获取tabBarItem
    UITabBarItem *watchLiveItem = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *doLiveItem = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *myCenterItem = [self.tabBar.items objectAtIndex:2];
    //设置tabBarItem背景图标
    [self setTabBarItem:watchLiveItem withNormalImageName:@"video" andSelectedImageName:@"video_hover" andTitle:nil];
    [self setTabBarItem:doLiveItem withNormalImageName:@"" andSelectedImageName:@""  andTitle:@""];
    [self setTabBarItem:myCenterItem withNormalImageName:@"User" andSelectedImageName:@"User_hover" andTitle:nil];
    
    
    
    //我来直播
    _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _liveButton.frame = CGRectMake(self.tabBar.frame.size.width/2-30, -15, 60, 60);
    _liveButton.layer.cornerRadius = 30;
    _liveButton.layer.borderWidth = 5;
    _liveButton.layer.borderColor = kWhiteColor.CGColor;
    _liveButton.layer.masksToBounds = YES;
    
    [_liveButton setImage:[UIImage imageNamed:@"play_hover"] forState:UIControlStateNormal];
    _liveButton.adjustsImageWhenHighlighted = NO;//去除按钮的按下效果（阴影）
    [_liveButton addTarget:self action:@selector(onLiveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma mark 点击我来直播
- (void)onLiveButtonClicked
{
//    DoLiveViewController* live = [[DoLiveViewController alloc] init];
//    live.delegate = (id<DoLiveDelegate>)_watchController;
//    [_watchController presentViewController:live animated:YES completion:nil];
    
#if kShowFuncDisplay
    
    FunctionViewController *vc = [[FunctionViewController alloc] init];
    [[AppDelegate sharedAppDelegate] pushViewController:vc];
#else
    PublishLiveViewController *pvc = [[PublishLiveViewController alloc] init];
    [[AppDelegate sharedAppDelegate] pushViewController:pvc];
#endif
}

#pragma mark 设置tabBarItem默认图标和选中图标

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    return index != 1;
}
- (void)setTabBarItem:(UITabBarItem *) tabBarItem withNormalImageName:(NSString *)normalImageName andSelectedImageName:(NSString *)selectedImageName andTitle:(NSString *)title
{
    [tabBarItem setImage:[[UIImage imageNamed:normalImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setSelectedImage:[[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem setTitle:title];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_liveButton.superview != nil)
    {
        [_liveButton removeFromSuperview];
    }
    [self.tabBar addSubview:_liveButton];
    
//    if(![[MultiIMManager sharedInstance] isLogin])
//    {
//        __weak MBProgressHUD *wh = _HUD;
//        __weak MainTabBarController *ws = self;
//        [_HUD showText:@"正在登录随心播" atMode:MBProgressHUDModeIndeterminate];
//        [[MultiIMManager sharedInstance] loginPhone:[UserInfo sharedInstance].userPhone sig:[UserInfo sharedInstance].userSig succ:^(NSString *msg) {
//            [wh hideText:msg atMode:MBProgressHUDModeText andDelay:1 andCompletion:nil];
//        } fail:^(NSString *err) {
//            [wh hideText:@"登录IM失败" atMode:MBProgressHUDModeText andDelay:1 andCompletion:^{
//                [ws performSegueWithIdentifier:@"toLogin" sender:ws];
//            }];
//        }];
//    }
}

//#pragma mark 消息和连接代理
//- (void)onConnSucc
//{
//    NSNumber* status = [NSNumber numberWithInt:NETWORK_CONN];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMNETWORK object:status];
//}
//- (void)onConnFailed:(int)code err:(NSString*)err
//{
//    NSNumber* status = [NSNumber numberWithInt:NETWORK_FAIL];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMNETWORK object:status];
//}
//- (void)onDisconnect:(int)code err:(NSString*)err
//{
//    NSNumber* status = [NSNumber numberWithInt:NETWORK_DISCONN];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMNETWORK object:status];
//}
@end