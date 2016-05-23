//
//  TCShowLiveMsg.h
//  TCShow
//
//  Created by AlexiChen on 16/4/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVIMMsg.h"

@interface TCShowLiveMsg : AVIMMsg

@property (nonatomic, assign) BOOL isMsg;               // NO：进入消息，YES：聊天消息
@property (nonatomic, strong) UIColor *nameColor;       // 显示名字的颜色

@property (nonatomic, strong) NSAttributedString *avimMsgRichText;
@property (nonatomic, assign) CGSize avimMsgShowSize;

+ (CGFloat)defaultShowHeightOf:(TCShowLiveMsg *)item inSize:(CGSize)size;

- (instancetype)initWith:(id<IMUserAble>)user message:(NSString *)message;

@end
