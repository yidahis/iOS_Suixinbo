//
//  AVIMMsgHandler.h
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

// 主要处理直播房间中的IM消息
// AVIMMsgHandler内处理的TIMMessage只包含一个Elem情况，不处理多个Elem，使用时请不要发送多个elem情况
@class AVIMMsgHandler;

@protocol AVIMMsgListener <NSObject>


@required

// 收到群聊天消息: (主要是文本类型)
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvGroupMsg:(id<AVIMMsgAble>)msg;

// 群主解散群消息，或后台自动解散
- (void)onIMHandler:(AVIMMsgHandler *)receiver deleteGroup:(id<IMUserAble>)sender;

// 有新用户进入
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver joinGroup:(NSArray *)senders;

// 有用户退出
// senders是id<IMUserAble>类型
- (void)onIMHandler:(AVIMMsgHandler *)receiver exitGroup:(NSArray *)senders;

// 收到自定义C2C消息
// 用户自行解析
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomC2C:(AVIMCMD *)msg;

// 收到自定义的Group消息
// 用户自行解析
- (void)onIMHandler:(AVIMMsgHandler *)receiver recvCustomGroup:(AVIMCMD *)msg;

@end

// 内部收发消息会作缓存，处理成要显示的消息后，然后外部主动刷新时，再拿到缓存消息进行显示
// 本类中发消息从主线程中进入，收消息后马上进入子线程处理，处理完成后再返回主界面刷新


@interface AVIMMsgHandler : NSObject<TIMMessageListener, TIMGroupMemberListener>
{
@protected
    id<AVRoomAble>          _imRoomInfo;            // 房间信息
    TIMConversation         *_chatRoomConversation; // 群会话上下文
    
@protected
    AVIMRunLoop             *_msgRunLoop;           // 消息处理线程
    
@protected
    __weak id<AVIMMsgListener> _roomIMListner;
}

@property (nonatomic, weak) id<AVIMMsgListener> roomIMListner;
//@property (nonatomic, readonly) NSMutableArray *roomMembers;

// 外部逻辑保证imRoom对应的直播聊天室已经创建成功
- (instancetype)initWith:(id<AVRoomAble>)imRoom;

// 进入直播间
- (void)enterLiveChatRoom:(TIMSucc)block fail:(TIMFail)fail;

// 退出直播间
- (void)exitLiveChatRoom:(TIMSucc)block fail:(TIMFail)fail;;

// 成员发群消息
- (void)sendMessage:(NSString *)msg;

// 释放相关的引用
- (void)releaseIMRef;

// 发送自定义的消息

- (void)sendCustomGroupMsg:(AVIMCMD *)elem succ:(TIMSucc)succ fail:(TIMFail)fail;

- (void)sendCustomC2CMsg:(AVIMCMD *)elem toUser:(id<IMUserAble>)recv succ:(TIMSucc)succ fail:(TIMFail)fail;;

@end


@interface AVIMMsgHandler (ProtectedMethod)

// 供子类重写

// C2C消息时，查不到用户的头像信息
- (id<IMUserAble>)syncGetC2CUserInfo:(NSString *)identifier;

// 发送点赞消息，AVIMMsgHandler里是空方法，供子类重写
// 用户可根据业务需要，使用群或C2C发送
// 另外点赞消息产生的动画，大量产生时非常耗性能，建议观众端从业务上处理，不要频繁发送，demo中是只允许1秒点一次
- (void)sendLikeMessage;

// 收到群自定义消息处理
// 返回的是界面上待处理的消息内容，最终放入
- (void)onRecvGroupSender:(id<IMUserAble>)sender textMsg:(NSString *)msg;

// 收到群自定义消息处理
- (void)onRecvGroupSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;

// 重写多人互动时
- (BOOL)onHandleRecvMultiGroupSender:(id<IMUserAble>)sender customMsg:(id<AVIMMsgAble>)cachedMsg;

// 收到C2C自定义消息
- (void)onRecvC2CSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;

// sender进入直播间
- (id<AVIMMsgAble>)onRecvSenderEnterLiveRoom:(id<IMUserAble>)sender;
- (id<AVIMMsgAble>)onRecvSenderExitLiveRoom:(id<IMUserAble>)sender;

// 如果delayDisplay这YES时，重写以下方法
- (id<AVIMMsgAble>)cacheRecvGroupSender:(id<IMUserAble>)sender textMsg:(NSString *)msg;
- (id<AVIMMsgAble>)cacheRecvGroupSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;
- (id<AVIMMsgAble>)cacheRecvC2CSender:(id<IMUserAble>)sender customMsg:(TIMCustomElem *)msg;

@end