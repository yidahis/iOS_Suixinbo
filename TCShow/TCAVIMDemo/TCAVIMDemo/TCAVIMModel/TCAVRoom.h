//
//  TCAVRoom.h
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCAVRoom : NSObject<AVRoomAble>

// 聊天室Id
@property (nonatomic, copy) NSString *liveIMChatRoomId;
@property (nonatomic, strong) id<IMUserAble> liveHost;
@property (nonatomic, assign) int liveAVRoomId;
@property (nonatomic, copy) NSString * liveTitle;



@end
