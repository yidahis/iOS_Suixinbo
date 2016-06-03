//
//  TCShowHost.h
//  TCShow
//
//  Created by AlexiChen on 16/4/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost.h"

extern NSString *const kTCShow_ExitLastRoomNotification;
extern NSString *const kTCShow_LocationSuccNotification;
extern NSString *const kTCShow_LocationFailNotification;

@interface TCShowHost : IMAHost<CLLocationManagerDelegate>
{
     CLLocationManager   *_lbsManager;
}



@property (nonatomic, assign) BOOL showLocation;            // 是否显示位置，默认NO
@property (nonatomic, strong) LocationItem *lbsInfo;        // 地理位置

@property (nonatomic, assign) int avRoomId;                 // AVRoomID

@property (nonatomic, strong) ImageSignItem *imgSign;       // 直播封面sig

@property (nonatomic, copy) NSString *liveCover;            // 直播封面地址

- (void)startLbs;
#if kIsTCShowSupportIMCustom
- (BOOL)gender;
#endif
@end
