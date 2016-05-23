//
//  HostProfileViewController.m
//  TCShow
//
//  Created by AlexiChen on 16/5/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "HostProfileViewController.h"

@implementation HostProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"我的资料";
}

- (void)addHeaderView
{
    
}


- (void)addFooterView
{
}

- (void)configOwnViews
{

    
    __weak HostProfileViewController *ws = self;
    
    IMAHost *host = (IMAHost *)[IMAPlatform sharedInstance].host;
    
    RichCellMenuItem *uid = [[RichCellMenuItem alloc] initWith:@"头像" value:[host imUserIconUrl] type:ERichCell_Icon action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        // 更新头像
        [ws onEditIcon:menu cell:cell];
    }];
    
    RichCellMenuItem *remark = [[RichCellMenuItem alloc] initWith:@"昵称" value:[host imUserName] type:ERichCell_TextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onEditNickName:menu cell:cell];
    }];
    remark.valueAlignment = NSTextAlignmentRight;
    
//    RichCellMenuItem *gender = [[RichCellMenuItem alloc] initWith:@"性别" value:(host.gender ? @"男" : @"女") type:ERichCell_TextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
//        [ws onEditGender:menu cell:cell];
//    }];
//    gender.valueAlignment = NSTextAlignmentRight;
//    
    
    NSString *sigStr = [[NSString alloc] initWithData:host.profile.selfSignature encoding:NSUTF8StringEncoding];
    RichCellMenuItem *sig = [[RichCellMenuItem alloc] initWith:@"签名" value:sigStr type:ERichCell_RichTextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onEditSignature:menu cell:cell];
    }];
    sig.valueAlignment = NSTextAlignmentRight;
    
    
    _datas = [NSMutableArray arrayWithArray:@[uid, remark, sig]];;
}

- (void)onEditIcon:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    [self callImagePickerActionSheet];
}



- (void)onEditNickName:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    EditInfoViewController *vc = [[EditInfoViewController alloc] initWith:@"修改昵称" text:menu.value completion:^(EditInfoViewController *selfPtr, BOOL isFinished) {
        if (isFinished)
        {
            NSString *editText = selfPtr.editText;
            [[IMAPlatform sharedInstance].host asyncSetNickname:editText succ:^{
                [[HUDHelper sharedInstance] tipMessage:@"修改成功"];
                menu.value = editText;
                [(RichMenuTableViewCell *)cell configWith:menu];
            } fail:nil];
            
        }
    }];
    [[AppDelegate sharedAppDelegate] presentViewController:vc animated:YES completion:nil];
}

- (void)onEditSignature:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    __weak UITableView *wt = _tableView;
    EditTextViewController *vc = [[EditTextViewController alloc] initWith:@"修改签名" text:menu.value completion:^(EditInfoViewController *selfPtr, BOOL isFinished) {
        if (isFinished)
        {
            NSString *editText = selfPtr.editText;
            [[IMAPlatform sharedInstance].host asyncSetSignature:editText succ:^{
                [[HUDHelper sharedInstance] tipMessage:@"修改成功"];
                menu.value = editText;
                [(RichMenuTableViewCell *)cell configWith:menu];
                
                NSIndexPath *index = [wt indexPathForCell:cell];
                [wt reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
            } fail:nil];
        }
    }];
    [[AppDelegate sharedAppDelegate] presentViewController:vc animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RichMenuTableViewCell heightOf:_datas[indexPath.row] inWidth:tableView.bounds.size.width];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RichCellMenuItem *item = _datas[indexPath.row];
    
    return [self tableView:tableView cellForItem:item];
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
    RichCellMenuItem *item = _datas[indexPath.row];
    RichMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (item.type != ERichCell_Switch)
    {
        if (item.action)
        {
            item.action(item, cell);
        }
    }
}

@end
