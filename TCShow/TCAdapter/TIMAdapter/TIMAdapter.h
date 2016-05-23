//
//  TIMAdapter.h
//  TIMAdapter
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ImSDK/ImSDK.h>

#import <TLSSDK/TLSHelper.h>

#import <QALSDK/QalSDKProxy.h>


// 用户更新为自己的app配置
// TLS，以及IMSDK相关的配置

#define kTLSAppid       @"1400001692"
#define kSdkAppId       @"1400001692"
#define kSdkAccountType @"884"


#define kQQAccountType  1
#define kWXAccountType  2

/**
 * QQ和微信sdk参数配置
 */

#define QQ_APP_ID @"222222"
#define QQ_OPEN_SCHEMA @"tencent222222"

#define WX_APP_ID @"wx65f71c2ea2b122da"
#define WX_OPEN_KEY @"69aed8b3fd41ed72efcfbdbca1e99a27"

// 演求个人资料里面的如何增加扩展字段
#define kIMCustomFlag @"Tag_Profile_Custom_1400001692_Param"


#define IMALocalizedError(intCode, enStr) NSLocalizedString(([NSString stringWithFormat:@"%d", (int)intCode]), enStr)


#import "IMAPlatformHeaders.h"

#import "IMAAppDelegate.h"

#import "IMALoginViewController.h"


#import "AVIMHeader.h"