//
//  TCUser.h
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCUser : NSObject<IMUserAble, AVMultiUserAble>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;

@property (nonatomic, assign) NSInteger avCtrlState;
@property (nonatomic, assign) NSInteger avMultiUserState;
@property (nonatomic, assign) CGRect avInteractArea;
@property (nonatomic, weak) UIView *avInvisibleInteractView;


@end
