//
//  ConstHeader.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef ConstHeader_h
#define ConstHeader_h

#define kTextRedColor       RGBOF(0xD54A45)

#define kTCShowMultiSubViewSize CGSizeMake(80, 120)

//=========================================================
// CommonLibrary UI样式配置

// 背景色
#define kAppBakgroundColor          RGBOF(0xEFEFF4)

// 导航主色调
#define kNavBarThemeColor             RGBOF(0xDC4B53)


//=========================================================
// CommonLibrary代码开关配置

//=========================================================
// IMSDK相关
// 用户更新为自己的app配置
// 以及IMSDK相关的配置
#define kSdkAppId       @"1400001692"
#define kSdkAccountType @"884"


//=========================================================

#define kDefaultUserIcon            [UIImage imageNamed:@"default_head@2x.jpg"]
#define kDefaultCoverIcon            [UIImage imageNamed:@"default_cover@2x.jpg"]
#define kDefaultSubGroupIcon        [UIImage imageWithColor:kOrangeColor size:CGSizeMake(32, 32)]


#define kAppLargeTextFont       [UIFont systemFontOfSize:16]
#define kAppMiddleTextFont      [UIFont systemFontOfSize:14]
#define kAppSmallTextFont       [UIFont systemFontOfSize:12]

#define kIsTCShowSupportIMCustom 1

#endif /* ConstHeader_h */
