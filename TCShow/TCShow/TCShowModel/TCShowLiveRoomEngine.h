//
//  TCShowLiveRoomEngine.h
//  TCShow
//
//  Created by AlexiChen on 16/5/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCAVLiveRoomEngine.h"



// TCAdapter内部逻辑是所有人共用，如果业务逻辑与之不一致，尽量参考下面的做法：
// 用户在自己App内，新增对应的类，将与自身业务逻辑不同的地方重写（重写时注意保持与原类流程一致），不要直接修改TCAdapter里面的代码（后期有更新的话，用户可直接替换代码）
//
// 用户自己注意类继承关系
// TCAVLiveRoomEngine:进入直播，若创建直播聊天室，那么ChatRoomId与AVRoom是可以不一致的
// TCShowLiveRoomEngine:希望ChatRoomId与AVRoom一致，
@interface TCShowLiveRoomEngine : TCAVLiveRoomEngine

@end


@interface TCShowMultiLiveRoomEngine : TCAVMultiLiveRoomEngine

@end
