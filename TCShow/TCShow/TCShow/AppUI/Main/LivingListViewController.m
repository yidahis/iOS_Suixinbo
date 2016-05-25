
//
//  LivingListViewController.m
//  JShow
//
//  Created by AlexiChen on 16/2/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LivingListViewController.h"

@implementation LivingListViewController

- (void)addOwnViews
{
    [super addOwnViews];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (BOOL)hasData
{
    BOOL has = _datas.count != 0;
    return has;
}

- (void)addRefreshScrollView
{
    [super addRefreshScrollView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"最新直播";

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self onRefreshLive];
}

- (void)onRefreshLive
{
    if (!_datas)
    {
        _datas = [NSMutableArray array];
    }
    [self pinHeaderView];
    [self refresh];
}


- (void)onLiveRequestSucc:(LiveListRequest *)req
{
    [_datas removeAllObjects];
    [self onLoadMoreLiveRequestSucc:req];
}


- (void)showNoDataView
{
    ImageTitleButton *btn = (ImageTitleButton *)_noDataView;
    [btn setTitle:@"很抱歉，暂时没有主播开启直播" forState:UIControlStateNormal];
}

- (void)onRefresh
{
    _pageItem.pageIndex = 0;
    
    __weak typeof(self) ws = self;

    LiveListRequest *req = [[LiveListRequest alloc] initWithHandler:^(BaseRequest *request) {
        LiveListRequest *wreq = (LiveListRequest *)request;
        [ws onLiveRequestSucc:wreq];
    } failHandler:^(BaseRequest *request) {
        [ws allLoadingCompleted];
    }];
    req.pageItem = _pageItem;
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (void)onLoadMoreLiveRequestSucc:(LiveListRequest *)req
{
    TCShowLiveList *resp = (TCShowLiveList *)req.response.data;
    [_datas addObjectsFromArray:resp.recordList];
    self.canLoadMore = resp.recordList.count >= req.pageItem.pageSize;
    _pageItem.pageIndex++;
    [self reloadData];
}

- (void)onLoadMore
{
    __weak typeof(self) ws = self;
    LiveListRequest *req = [[LiveListRequest alloc] initWithHandler:^(BaseRequest *request) {
        LiveListRequest *wreq = (LiveListRequest *)request;
        [ws onLoadMoreLiveRequestSucc:wreq];
    } failHandler:^(BaseRequest *request) {
        [ws allLoadingCompleted];
    }];
    req.pageItem = _pageItem;
    [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = (NSInteger) (0.618 * tableView.bounds.size.width + 54 + 10);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LiveListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveListTableViewCell"];
    if(cell == nil)
    {
        cell = [[LiveListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LiveListTableViewCell"];
    }
    
    id<TCShowLiveRoomAble> room = _datas[indexPath.row];
    
    [cell configWith:room];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![IMAPlatform sharedInstance].isConnected)
    {
        [HUDHelper alert:@"当前无网络"];
        return;
    }
    // 进入直播间
    TCShowLiveListItem *item = _datas[indexPath.row];
    TCShowMultiLiveViewController *vc = [[TCShowMultiLiveViewController alloc] initWith:item user:[IMAPlatform sharedInstance].host];
    [[AppDelegate sharedAppDelegate] pushViewController:vc];
    
}

@end
