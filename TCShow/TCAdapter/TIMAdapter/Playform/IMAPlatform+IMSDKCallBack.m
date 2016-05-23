//
//  IMAPlatform+IMSDKCallBack.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform+IMSDKCallBack.h"

// 所有回调中的核心逻辑最终都放入到主线程中执行

@implementation IMAPlatform (IMSDKCallBack)

#pragma mark - TIMConnListener

/**
 *  网络连接成功
 */
- (void)onConnSucc
{
    self.isConnected = YES;
    
    TCQALNetwork net = [[QalSDKProxy sharedInstance] getNetType];
    [self changeToNetwork:net];
}

/**
 *  网络连接失败
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onConnFailed:(int)code err:(NSString*)err
{
    
    self.isConnected = NO;
    DebugLog(@"网络连接失败");
}

/**
 *  网络连接断开
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onDisconnect:(int)code err:(NSString*)err
{
    
    self.isConnected = NO;
    DebugLog(@"网络连接断开 code = %d, err = %@", code, err);
}


/**
 *  连接中
 */
- (void)onConnecting
{
    DebugLog(@"连接中");
}

#pragma mark - TIMUserStatusListener

/**
 *  踢下线通知
 */

static BOOL kIsAlertingForceOffline = NO;
- (void)onForceOffline
{
    
    if (!kIsAlertingForceOffline)
    {
        [[IMAAppDelegate sharedAppDelegate] popToRootViewController];
        kIsAlertingForceOffline = YES;
        DebugLog(@"踢下线通知");
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"下线通知" message:@"您的帐号于另一台手机上登录。" cancelButtonTitle:@"退出" otherButtonTitles:@[@"重新登录"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0)
            {
                // 退出
                [self logout:^{
                    [[IMAAppDelegate sharedAppDelegate] enterLoginUI];
                } fail:^(int code, NSString *msg) {
                    [[IMAAppDelegate sharedAppDelegate] enterLoginUI];
                }];
            }
            else
            {
                [self offlineLogin];
                // 重新登录
                [self login:self.host.loginParm succ:nil fail:^(int code, NSString *msg) {
                    [[IMAAppDelegate sharedAppDelegate] enterLoginUI];
                }];
            }
            
            kIsAlertingForceOffline = NO;
            
        }];
        [alert show];
    }
    
}

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err
{
    DebugLog(@"断线重连失败");
}


#pragma mark -TIMRefreshListener

- (void)onRefresh
{
    // 重新刷新会话列列
}

@end




@implementation IMAPlatform (GroupAssistantListener)

/**
 *  有新用户加入群时的通知回调
 *
 *  @param groupId     群ID
 *  @param membersInfo 加群用户的群资料（TIMGroupMemberInfo*）列表
 */
-(void) onMemberJoin:(NSString *)groupId membersInfo:(NSArray *)membersInfo
{
    DebugLog(@"groupId = %@, membersInfo = %@", groupId, membersInfo);
}

/**
 *  有群成员退群时的通知回调
 *
 *  @param groupId 群ID
 *  @param members 退群成员的identifier（NSString*）列表
 */
-(void) onMemberQuit:(NSString*)groupId members:(NSArray*)members
{
    DebugLog(@"groupId = %@, membersInfo = %@", groupId, members);
}

/**
 *  群成员信息更新的通知回调
 *
 *  @param groupId     群ID
 *  @param membersInfo 更新后的群成员资料（TIMGroupMemberInfo*）列表
 */
-(void) onMemberUpdate:(NSString*)groupId membersInfo:(NSArray*)membersInfo
{
    DebugLog(@"groupId = %@, membersInfo = %@", groupId, membersInfo);
}

/**
 *  加入群的通知回调
 *
 *  @param groupInfo 加入群的群组资料
 */
-(void) onGroupAdd:(TIMGroupInfo*)groupInfo
{
    //    DebugLog(@"groupInfo = %@", groupInfo);
    //    IMAUser *group = (IMAGroup *) [self.contactMgr getUserByGroupId:groupInfo.group];
    //    if (!group)
    //    {
    //        IMAGroup *gr = [[IMAGroup alloc] initWithInfo:groupInfo];
    //        [self.contactMgr onAddGroup:gr];
    //    }
}

/**
 *  解散群的通知回调
 *
 *  @param groupId 解散群的群ID
 */
-(void) onGroupDelete:(NSString*)groupId
{
    //    DebugLog(@"groupInfo = %@", groupId);
    //    IMAUser *group = (IMAGroup *) [self.contactMgr getUserByGroupId:groupId];
    //    if (group)
    //    {
    //        [self.contactMgr removeUser:group];
    //    }
}

/**
 *  群资料更新的通知回调
 *
 *  @param groupInfo 更新后的群资料信息
 */
-(void) onGroupUpdate:(TIMGroupInfo*)groupInfo
{
    //    DebugLog(@"groupInfo = %@", groupInfo);
    //    IMAGroup *group = (IMAGroup *) [self.contactMgr getUserByGroupId:groupInfo.group];
    //    if (group)
    //    {
    //        [group changeGroupInfo:groupInfo];
    //    }
}

@end
