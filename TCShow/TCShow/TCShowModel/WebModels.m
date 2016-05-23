//
//  WebModels.m
//  TCShow
//
//  Created by AlexiChen on 15/11/12.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "WebModels.h"

@implementation ImageSignItem

- (BOOL)isVailed
{
    if (!_imageSign.length)
    {
        return NO;
    }
    
    time_t cuetime = [[NSDate date] timeIntervalSince1970];
    // 28天内有效
    BOOL isExpired = (cuetime - _saveSignTime > (1 * 28 * 24* 60 * 60));
    
    return !isExpired;
    
}


@end


//==================================================
@implementation LocationItem

- (instancetype)init
{
    if (self = [super init])
    {
        self.address = @"";
    }
    return self;
}

- (BOOL)isVaild
{
    return _address.length != 0 && _latitude != 0 && _longitude != 0;
}

@end

//==================================================
@implementation TCShowUser : NSObject


- (BOOL)isEqual:(id)object
{
    BOOL isEqual = [super isEqual:object];
    if (!isEqual)
    {
        if ([object isMemberOfClass:[self class]])
        {
            TCShowUser *uo = (TCShowUser *)object;
            
            isEqual = ![NSString isEmpty:uo.uid] && [uo.uid isEqualToString:self.uid];
        }
    }
    
    return isEqual;
}

- (BOOL)isVailed
{
    return ![NSString isEmpty:_uid];
}


- (NSString *)imUserId
{
    return _uid;
}

- (NSString *)imUserName
{
    return ![NSString isEmpty:_username] ? _username : _uid;
}

- (NSString *)imUserIconUrl
{
    return _avatar;
}
@end

//==================================================

@implementation TCShowLiveCustomAction

- (instancetype)init
{
    if (self = [super init])
    {
        _user = [IMAPlatform sharedInstance].host;
    }
    return self;
}

- (NSData *)actionData
{
    NSDictionary *post = [self serializeSelfPropertyToJsonObject];
    if ([NSJSONSerialization isValidJSONObject:post])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:&error];
        if(error)
        {
            DebugLog(@"[%@] Post Json Error: %@", [self class], post);
            return nil;
        }
        
        return data;
    }
    else
    {
        DebugLog(@"[%@] AV Custom Action is not valid: %@", [self class], post);
        return nil;
    }
}

@end


//==================================================
@implementation TCShowLiveListItem

- (NSString *)liveIMChatRoomId
{
    return self.chatRoomId;
}

- (void)setLiveIMChatRoomId:(NSString *)liveIMChatRoomId
{
    self.chatRoomId = liveIMChatRoomId;
}

// 当前主播信息
- (id<IMUserAble>)liveHost
{
    return _host;
}

// 直播房间Id
- (int)liveAVRoomId
{
    return _avRoomId;
}

// 直播标题
- (NSString *)liveTitle
{
    return self.title;
}

- (NSString *)liveCover
{
    return self.cover;
}

- (void)setLiveAudience:(NSInteger)liveAudience
{
    if (liveAudience < 0)
    {
        liveAudience = 0;
    }
    
    if (liveAudience > _liveAudience)
    {
        _watchCount += (liveAudience - _liveAudience);
    }

    _liveAudience = liveAudience;
}

- (void)setLivePraise:(NSInteger)livePraise
{
    if (livePraise < 0)
    {
        livePraise = 0;
    }
    
    _admireCount = livePraise;
}

- (NSInteger)livePraise
{
    return _admireCount;
}

- (void)setLiveDuration:(NSInteger)liveDuration
{
    self.timeSpan = liveDuration;
}

- (NSInteger)liveDuration
{
    return self.timeSpan;
}

// 点赞次数
- (NSString *)livePraiseCount
{
    return [NSString stringWithFormat:@"%d", (int)self.livePraise];
}

// 观众人数
- (NSString *)liveAudienceCount
{
    return [NSString stringWithFormat:@"%d", (int)self.liveAudience];
}


- (NSDictionary *)toLiveStartJson
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json addString:self.title forKey:@"title"];
    [json addString:self.cover forKey:@"cover"];
    [json addString:self.chatRoomId forKey:@"chatRoomId"];
    [json addInteger:self.avRoomId forKey:@"avRoomId"];
    
    
    NSMutableDictionary *host = [[NSMutableDictionary alloc] init];
    
    [host addString:[self.host imUserId] forKey:@"uid"];
    [host addString:[self.host imUserIconUrl] forKey:@"avatar"];
    [host addString:[self.host imUserName] forKey:@"username"];
    [json setObject:host forKey:@"host"];
    
    if (self.lbs)
    {    
        NSDictionary *lbs = [self.lbs serializeSelfPropertyToJsonObject];
        
        [json setObject:lbs forKey:@"lbs"];
    }
    
    return json;
}

- (NSDictionary *)toHeartBeatJson
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json addString:[self.host imUserId] forKey:@"uid"];
    [json addInteger:self.watchCount forKey:@"watchCount"];
    [json addInteger:self.admireCount forKey:@"admireCount"];
    [json addInteger:self.timeSpan forKey:@"timeSpan"];
    return json;
}

- (NSInteger)liveWatchCount
{
    return _watchCount;
}

@end

