//
//  MainViewController.m
//  TCAVIntergrateDemo
//
//  Created by AlexiChen on 16/5/16.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "MainViewController.h"

@interface TCMenuItem : MenuItem

@property (nonatomic, copy) NSString *funcDesc;

@end


@implementation TCMenuItem

@end







@implementation MainViewController

- (void)configOwnViews
{
    _data = [NSMutableArray array];
    
    TCMenuItem *item = [[TCMenuItem alloc] initWithTitle:@"界面层次梳理" icon:nil action:^(id<MenuAbleItem> menu) {
        AVIMMILayerViewController *vc = [[AVIMMILayerViewController alloc] init];
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }];
    item.funcDesc = @"说明直播界面的层次关系";
    [_data addObject:item];
    
    
    item = [[TCMenuItem alloc] initWithTitle:@"简单直播Demo" icon:nil action:^(id<MenuAbleItem> menu) {
        SimpleLiveViewController *vc = [[SimpleLiveViewController alloc] initWith:[AppDelegate sharedAppDelegate].liveRoom user:[IMAPlatform sharedInstance].host];
        //        vc.enableIM = NO;
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }];
    item.funcDesc = @"主要功能：创建一个简单的直播";
    [_data addObject:item];
    
    item = [[TCMenuItem alloc] initWithTitle:@"一人主播多人开Mic" icon:nil action:^(id<MenuAbleItem> menu) {
        LiveMicViewController *vc = [[LiveMicViewController alloc] initWith:[AppDelegate sharedAppDelegate].liveRoom user:[IMAPlatform sharedInstance].host];
        //        vc.enableIM = NO;
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }];
    item.funcDesc = @"主要功能：创建一个人当主播，多个人连麦（AVRoom音频上行最多6路，本处demo，不作此逻辑判断）";
    [_data addObject:item];
    
    item = [[TCMenuItem alloc] initWithTitle:@"二人语音电话" icon:nil action:^(id<MenuAbleItem> menu) {
        C2CVoiceViewController *vc = [[C2CVoiceViewController alloc] initWith:[AppDelegate sharedAppDelegate].liveRoom user:[IMAPlatform sharedInstance].host];
        //        vc.enableIM = NO;
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }];
    item.funcDesc = @"主要功能：两个人进行语音电话（AVRoom音频上行最多6路，本处demo，不作此逻辑判断）";
    [_data addObject:item];
    
    
    item = [[TCMenuItem alloc] initWithTitle:@"二人视频电话" icon:nil action:^(id<MenuAbleItem> menu) {
        C2CVideoViewController*vc = [[C2CVideoViewController alloc] initWith:[AppDelegate sharedAppDelegate].liveRoom user:[IMAPlatform sharedInstance].host];
        vc.enableIM = NO;
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }];
    item.funcDesc = @"主要功能：仿QQ语音视频聊天";
    [_data addObject:item];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kWTATableCellIdentifier"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kWTATableCellIdentifier"];
    }
    
    TCMenuItem *kv = _data[indexPath.row];
    cell.textLabel.text = [kv title];
    cell.detailTextLabel.text = [kv funcDesc];
    return cell;
}


@end
