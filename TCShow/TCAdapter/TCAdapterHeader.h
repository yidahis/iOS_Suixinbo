//
//  TCAdapterHeader.h
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TCAdapterHeader_h
#define TCAdapterHeader_h


//  内部错误码转写
#define TAVLocalizedError(avErrorTip) NSLocalizedString(avErrorTip, avErrorTip)

// 是否是将AVSDK在直播场景下使用
// 直播场景下，不要频繁切换context（用户使用过程中会不会频繁切换房间，即kIsUseAVSDKAsLiveScene为1, 如果使用不频繁，可以在退出的时候stopContext）
// kIsUseAVSDKAsLiveScene 为 1时，如果用户注销，或被踢下线，此时要stopContext
#define kIsUseAVSDKAsLiveScene 1

// 是否是AppStore版本
#define kAppStoreVersion 0


// 上传AppStore时改为0
// 方便测试去查看房间号等相关信息，以便测试
#if kAppStoreVersion
#define kBetaVersion        0
#else
#define kBetaVersion        1
#endif

// 是否支持消息缓存，而不是立即显示，主要是看大消息量时，立即显示会导致界面卡顿
// 因不清楚各App的消息种类，以及消息类型（是否支持IM等），故放到业务层去处理，各App可依照此处逻辑
// 为0时，立即显示
// 为1时，会按固定频率刷新
#define kSupportIMMsgCache  1


// 用于真机时，测试获取日志
static NSDateFormatter *kTCAVIMLogDateFormatter = nil;

#if DEBUG

// 主要用于腾讯测试同事，获取获取进行统计进房间时间，以及第一帧画面时间，外部用户使用时可改为0
#define kSupportTimeStatistics 1

#define TCAVIMLog(fmt, ...)  {\
                                if (!kTCAVIMLogDateFormatter) \
                                {\
                                    kTCAVIMLogDateFormatter = [[NSDateFormatter alloc] init];\
                                    [kTCAVIMLogDateFormatter setDateStyle:NSDateFormatterMediumStyle];\
                                    [kTCAVIMLogDateFormatter setTimeStyle:NSDateFormatterShortStyle];\
                                    [kTCAVIMLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];\
                                }\
                                NSLog((@"TCAdapter时间统计 时间点:%@ [%s Line %d] ------->>>>>>\n" fmt), [kTCAVIMLogDateFormatter stringFromDate:[NSDate date]], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);\
                            }

#else


#if kAppStoreVersion

// AppStore版本不统计

#define kSupportTimeStatistics 0

// 用于release时，真机下面获取App关键路径日志日志
#define TCAVIMLog(fmt, ...)  /**/
#else

// 主要用于腾讯测试同事，获取获取进行统计进房间时间，以及第一帧画面时间，外部用户使用时可改为0

#define kSupportTimeStatistics 1

// 用于release时，真机下面获取App关键路径日志日志
#define TCAVIMLog(fmt, ...) {\
                                if (!kTCAVIMLogDateFormatter) \
                                { \
                                    kTCAVIMLogDateFormatter = [[NSDateFormatter alloc] init];\
                                    [kTCAVIMLogDateFormatter setDateStyle:NSDateFormatterMediumStyle];\
                                    [kTCAVIMLogDateFormatter setTimeStyle:NSDateFormatterShortStyle];\
                                    [kTCAVIMLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];\
                                }\
                                [[TIMManager sharedInstance] log:TIM_LOG_INFO tag:@"TCAdapter时间统计" msg:[NSString stringWithFormat:(@"时间点:%@ [%s Line %d] ------->>>>>>" fmt), [kTCAVIMLogDateFormatter stringFromDate:[NSDate date]], __PRETTY_FUNCTION__, __LINE__,  ##__VA_ARGS__]];\
                            }

#endif

#endif


// 因调试的时候手机距离较近容易产生啸叫(物理现象：录音机与扬声器较近时)
// 添加开关，调试状态下不打开Mic
#if DEBUG

#define kAVSDKDefaultOpenMic 1

#else

#define kAVSDKDefaultOpenMic 1

#endif


// 导入索引头文件

#import "AVIMAble.h"

#import "TCAVIMMIManager.h"

#import "TIMAdapter.h"

#import "TCAVIMAdapter.h"



#endif /* TCAdapterHeader_h */
