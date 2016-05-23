
//
//  SettingViewController.m
//  JShow
//
//  Created by AlexiChen on 16/2/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "SettingViewController.h"

#import "TLSSDK/TLSHelper.h"

#import "QALSDK/QalSDKProxy.h"

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
}

- (void)addHeaderView
{
    
}

- (void)onExit
{
    [[HUDHelper sharedInstance] syncLoading:@"正在退出"];
    [[IMAPlatform sharedInstance] logout:^{
        [[HUDHelper sharedInstance] syncStopLoadingMessage:@"退出成功" delay:0.5 completion:^{
            [[AppDelegate sharedAppDelegate] enterLoginUI];
        }];
        
    } fail:^(int code, NSString *err) {
        [[HUDHelper sharedInstance] syncStopLoadingMessage:IMALocalizedError(code, err) delay:2 completion:^{
            [[AppDelegate sharedAppDelegate] enterLoginUI];
        }];
    }];
}

- (void)addFooterView
{
    UIView *footer = [[UIView alloc] init];
    __weak SettingViewController *ws = self;
    MenuButton *exitBtn = [[MenuButton alloc] initWithTitle:@"退出登录" action:^(id<MenuAbleItem> menu) {
        [ws onExit];
    }];
    [exitBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    exitBtn.frame = CGRectMake(20, 10, self.view.bounds.size.width - 40, 40);
    [exitBtn setBackgroundImage:[UIImage imageWithColor:RGBOF(0xE84A4B) size:CGSizeMake(32, 32)] forState:UIControlStateNormal];
    exitBtn.layer.cornerRadius = 4;
    exitBtn.layer.masksToBounds = YES;
    [footer addSubview:exitBtn];
    exitBtn.titleLabel.font = kAppMiddleTextFont;
    footer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    
    _tableView.tableFooterView = footer;
    
}

- (void)configOwnViews
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    
    NSMutableArray *array = [NSMutableArray array];
    
    MenuItem *info = [[MenuItem alloc] initWithTitle:@"编辑个人信息" icon:nil action:^(id<MenuAbleItem> menu) {
        HostProfileViewController *vc = [[HostProfileViewController alloc] init];
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }];
    [array addObject:info];
    
    MenuItem *about = [[MenuItem alloc] initWithTitle:@"关于随心播" icon:nil action:^(id<MenuAbleItem> menu) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *info = [NSString stringWithFormat:@"App版本号：%@\nIMSDK版本号：%@\nAVSDK版本号:%@", version, [[TIMManager sharedInstance] GetVersion], [QAVContext getVersion]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"关于随心播" message:info delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
    }];
    [array addObject:about];
    [dic setObject:array forKey:@(0)];
    
    
    
#if kAppStoreVersion
#else
    __weak SettingViewController *ws = self;
    IMAPlatformConfig *cfg = [IMAPlatform sharedInstance].localConfig;
    
    RichCellMenuItem *testEnv = [[RichCellMenuItem alloc] initWith:@"测试环境" value:nil type:ERichCell_Switch action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onSwitchEnvironment:menu cell:cell];
    }];
    testEnv.tipMargin = 20;
    testEnv.tipColor = kBlackColor;
    testEnv.valueColor = kGrayColor;
    testEnv.switchValue = cfg.environment;
    
    RichCellMenuItem *consoleLog = [[RichCellMenuItem alloc] initWith:@"控制台日志" value:nil type:ERichCell_Switch action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onSwitchConsoleLog:menu cell:cell];
    }];
    consoleLog.tipMargin = 20;
    consoleLog.tipColor = kBlackColor;
    consoleLog.valueColor = kGrayColor;
    consoleLog.switchValue = cfg.enableConsoleLog;
    
    NSString *tip = [cfg getLogLevelTip];
    RichCellMenuItem *logLevel = [[RichCellMenuItem alloc] initWith:@"日志级别" value:tip type:ERichCell_TextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onConsoleLevel:menu cell:cell];
    }];
    logLevel.tipMargin = 20;
    logLevel.tipColor = kBlackColor;
    logLevel.valueAlignment = NSTextAlignmentRight;
    logLevel.valueColor = kGrayColor;
    
    RichCellMenuItem *version = [[RichCellMenuItem alloc] initWith:@"SDK版本号" value:nil type:ERichCell_TextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onVersionShow];
    }];
    version.tipMargin = 20;
    version.tipColor = kBlackColor;
    version.valueColor = kGrayColor;
    
    
    [dic setObject:@[testEnv, consoleLog, logLevel, version] forKey:@(1)];
#endif
    _settings = dic;
}

- (void)onSwitchEnvironment:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"切换环境，下次启动时才生效。" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        RichMenuTableViewCell *rcell = (RichMenuTableViewCell *)cell;
        if (buttonIndex == 1)
        {
            rcell.onSwitch.on = !rcell.onSwitch.on;
            menu.switchValue = rcell.onSwitch.on;
            [[IMAPlatform sharedInstance].localConfig chageEnvTo:rcell.onSwitch.on];
        }
        
    }];
    [alert show];
}

- (void)onSwitchConsoleLog:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"修改控制台日志，下次启动时才生效。" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        RichMenuTableViewCell *rcell = (RichMenuTableViewCell *)cell;
        if (buttonIndex == 1)
        {
            IMAPlatformConfig *cfg = [IMAPlatform sharedInstance].localConfig;
            rcell.onSwitch.on = !rcell.onSwitch.on;
            [cfg chageEnableConsoleTo:rcell.onSwitch.on];
            menu.switchValue = rcell.onSwitch.on;
        }
    }];
    [alert show];
}


- (void)onConsoleLevel:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    __weak SettingViewController *ws = self;
    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"修改日志级别，下次启动时才生效。" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        RichMenuTableViewCell *rcell = (RichMenuTableViewCell *)cell;
        if (buttonIndex == 1)
        {
            NSDictionary *dic = [IMAPlatformConfig logLevelTips];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] init];
            
            IMAPlatformConfig *cfg = [IMAPlatform sharedInstance].localConfig;
            NSArray *array = [dic allKeys];
            for (NSString *key in array)
            {
                [sheet bk_addButtonWithTitle:key handler:^{
                    NSInteger level = (NSInteger)[(NSNumber *)[dic valueForKey:key] integerValue];
                    [cfg chageLogLevelTo:level];
                    menu.value = [cfg getLogLevelTip];
                    [rcell configWith:menu];
                }];
            }
            
            [sheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
            [sheet showInView:ws.view];
        }
    }];
    [alert show];
}

- (void)onVersionShow
{
    NSString *imVersion = [[TIMManager sharedInstance] GetVersion];
    NSString *tlsVersion = [[TLSHelper getInstance] getSDKVersion];
    NSString *qalVersion = [[QalSDKProxy sharedInstance] getSDKVer];
    
    NSString *myMessage = [NSString stringWithFormat:@"IMSDK Version:%@\r\nTLSSDK Version:%@\r\nQALSDK Version:%@",imVersion, tlsVersion,qalVersion];
    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"SDK版本号" message:myMessage cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
    [alert show];
}


- (RichCellMenuItem *)itemOf:(NSIndexPath *)indexPath
{
    NSArray *array = _settings[@(indexPath.section)];
    RichCellMenuItem *item = array[indexPath.row];
    return item;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_settings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = _settings[@(section)];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return kDefaultCellHeight;
    }
    else
    {
        return [RichMenuTableViewCell heightOf:[self itemOf:indexPath] inWidth:tableView.bounds.size.width];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kWTATableCellIdentifier"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"kWTATableCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = kAppMiddleTextFont;
        }
        
        NSArray *array = _settings[@(indexPath.section)];
        MenuItem *kv = array[indexPath.row];
        cell.textLabel.text = [kv title];
        return cell;
        
    }
    else
    {
        RichCellMenuItem *item = [self itemOf:indexPath];
        
        return [self tableView:tableView cellForItem:item];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForItem:(RichCellMenuItem *)item
{
    
    NSString *reuse = [RichCellMenuItem reuseIndentifierOf:item.type];
    RichMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell)
    {
        cell = [[RichMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    [cell configWith:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSArray *array = _settings[@(indexPath.section)];
        MenuItem *kv = array[indexPath.row];
        [kv menuAction];
        
    }
    else
    {
        RichCellMenuItem *item = [self itemOf:indexPath];
        RichMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (item.type != ERichCell_Switch)
        {
            if (item.action)
            {
                item.action(item, cell);
            }
        }
    }
}
@end
