//
//  TCUser.m
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCUser.h"

@implementation TCUser

// 两个用户是否相同，可通过比较imUserId来判断
// 用户IMSDK的identigier
- (NSString *)imUserId
{
    return _uid;
}

// 用户昵称
- (NSString *)imUserName
{
    return _name.length ? _name : _uid;
}

// 用户头像地址
- (NSString *)imUserIconUrl
{
    return _icon;
}

@end
