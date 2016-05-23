//
//  TCShowModelHeader.h
//  TCShow
//
//  Created by AlexiChen on 16/4/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TCShowModelHeader_h
#define TCShowModelHeader_h

// 更新Demo Code的时候，发布者更多的时候是修改TCAdapter里面的代码
// 添加此文件目录方便用户进行自定义扩展，而不是直接拿TCAdapter里面的代码作修改，直接修改的话，如果新版本有更新的话，用户存在merge操作
// 为更好地与用户已有代码兼容，TCAdapter里面全部使用接口，用户可参照TCShowModel里面的做法，然后接入到自身的逻辑里面

#import "TCModelAble.h"

#import "WebModels.h"

#import "TCShowHost.h"

#import "TCShowLiveMsg.h"

#import "TCShowAVIMHandler.h"

#import "WebServiceHeader.h"

#import "UploadImageHelper.h"

#import "TCShowLiveRoomEngine.h"

#endif /* TCShowModelHeader_h */
