//
//  TCModelAble.h
//  TCShow
//
//  Created by AlexiChen on 16/4/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// 用户可以在此处增加在AVIMAble.h在提到的接口方法


@protocol TCShowLiveRoomAble <AVRoomAble>

// 直播时间
@property (nonatomic, assign) NSInteger liveDuration;

// 点赞数
@property (nonatomic, assign) NSInteger livePraise;

// 在线人数
@property (nonatomic, assign) NSInteger liveAudience;

// 封面
- (NSString *)liveCover;

- (NSInteger)liveWatchCount;
@end
