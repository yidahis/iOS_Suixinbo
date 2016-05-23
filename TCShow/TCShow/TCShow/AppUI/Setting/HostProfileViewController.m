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
    
    TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
    
    RichCellMenuItem *uid = [[RichCellMenuItem alloc] initWith:@"头像" value:[host imUserIconUrl] type:ERichCell_Icon action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        // 更新头像
        [ws onEditIcon:menu cell:cell];
    }];
    
    RichCellMenuItem *remark = [[RichCellMenuItem alloc] initWith:@"昵称" value:[host imUserName] type:ERichCell_TextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onEditNickName:menu cell:cell];
    }];
    remark.valueAlignment = NSTextAlignmentRight;
    
    RichCellMenuItem *gender = [[RichCellMenuItem alloc] initWith:@"性别" value:(host.gender ? @"男" : @"女") type:ERichCell_TextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onEditGender:menu cell:cell];
    }];
    gender.valueAlignment = NSTextAlignmentRight;
    
    
    NSString *sigStr = [[NSString alloc] initWithData:host.profile.selfSignature encoding:NSUTF8StringEncoding];
    RichCellMenuItem *sig = [[RichCellMenuItem alloc] initWith:@"签名" value:sigStr type:ERichCell_RichTextNext action:^(RichCellMenuItem *menu, UITableViewCell *cell) {
        [ws onEditSignature:menu cell:cell];
    }];
    sig.valueAlignment = NSTextAlignmentRight;
    
    
    _datas = [NSMutableArray arrayWithArray:@[uid, remark, gender, sig]];;
}

- (void)onEditIcon:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    [self callImagePickerActionSheet];
}

- (void)onEditGender:(RichCellMenuItem *)menu cell:(UITableViewCell *)cell
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    
    TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
    NSArray *array = @[@"女", @"男"];
    for (NSString *key in array)
    {
        [sheet bk_addButtonWithTitle:key handler:^{
            
            [host asyncSetGender:[key isEqualToString:@"男"] succ:^{
                [[HUDHelper sharedInstance] tipMessage:@"修改成功"];
                menu.value = (host.gender ? @"男" : @"女");
                [(RichMenuTableViewCell *)cell configWith:menu];
            } fail:nil];
        }];
    }
    
    [sheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [sheet showInView:self.view];

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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    UIImage *cutImage = [self cutImage:image];
    
    
    RichCellMenuItem *iconItem = _datas[0];
// 上传图片
    __weak UITableView *wt = _tableView;
    [[UploadImageHelper shareInstance] upload:cutImage completion:^(NSString *imageSaveUrl) {
        
        IMAHost *host = [[IMAPlatform sharedInstance] host];
        
        [host asyncSetFaceUrl:imageSaveUrl succ:^{
            host.profile.faceURL = imageSaveUrl;
            
            iconItem.value = [host imUserIconUrl];
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [wt reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
            
            [[HUDHelper sharedInstance] tipMessage:@"头像修改成功"];
        } fail:^(int code, NSString *msg) {
            [[HUDHelper sharedInstance] tipMessage:@"更新IM头像失败"];
        }];
        
        
    } failed:^(NSString *failTip) {
        [[HUDHelper sharedInstance] tipMessage:@"上传图像到COS失败"];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)cutImage:(UIImage *)image
{
    CGSize pubSize = CGSizeMake(100, 100);
    if (image)
    {
        CGSize imgSize = image.size;
        CGFloat pubRation = pubSize.height / pubSize.width;
        CGFloat imgRatio = imgSize.height / imgSize.width;
        if (fabs(imgRatio -  pubRation) < 0.01)
        {
            // 直接上传
            return image;
        }
        else
        {
            if (imgRatio > 1)
            {
                // 长图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.width, (NSInteger)(imgSize.width * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake(0, (image.size.height - upSize.height)/2, upSize.width, upSize.height)];
                return upimg;
            }
            else
            {
                // 宽图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.height, (NSInteger)(imgSize.height * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake((image.size.width - upSize.width)/2, 0, upSize.width, upSize.height)];
                return upimg;
            }
        }
    }
    
    return image;
}

- (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [image drawInRect:drawRect];
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
