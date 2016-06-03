//
//  TIMAdapterConfig.h
//  TCShow
//
//  Created by AlexiChen on 16/6/2.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TIMAdapterConfig_h
#define TIMAdapterConfig_h


// 用户更新为自己的app配置
// 以及IMSDK相关的配置
#ifndef kSdkAppId
#define kSdkAppId       @"1400001692"
#endif

#ifndef kSdkAccountType
#define kSdkAccountType @"884"
#endif

#ifndef kQQAccountType
#define kQQAccountType  1
#endif

#ifndef kWXAccountType
#define kWXAccountType  2
#endif

/**
 * QQ和微信sdk参数配置
 */
#ifndef QQ_APP_ID
#define QQ_APP_ID @"222222"
#endif

#ifndef QQ_OPEN_SCHEMA
#define QQ_OPEN_SCHEMA @"tencent222222"
#endif

#ifndef WX_APP_ID
#define WX_APP_ID @"wx65f71c2ea2b122da"
#endif

#ifndef WX_OPEN_KEY
#define WX_OPEN_KEY @"69aed8b3fd41ed72efcfbdbca1e99a27"
#endif

// 因随心播中有自定义字段，导致集成时，更新SDK AppID后无法正常登录
// 添加宏控制该逻辑
#ifndef kIsTCShowSupportIMCustom
#define kIsTCShowSupportIMCustom 0
#endif

// 演求个人资料里面的如何增加扩展字段
#if kIsTCShowSupportIMCustom
#define kIMCustomFlag @"Tag_Profile_Custom_1400001692_Param"
#endif

#define IMALocalizedError(intCode, enStr) NSLocalizedString(([NSString stringWithFormat:@"%d", (int)intCode]), enStr)


#endif /* TIMAdapterConfig_h */
