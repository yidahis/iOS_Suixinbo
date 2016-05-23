//
//  C2CViewController.m
//  LiveIMTool
//
//  Created by AlexiChen on 16/4/25.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "C2CViewController.h"

@interface C2CViewController ()

@property (nonatomic, strong) NSTimer *sendTimer;
@property (nonatomic, strong) TIMConversation *conversation;
@property (nonatomic, assign) NSInteger msgIndex;

@end

@implementation C2CViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTapBlankToHideKeyboardGesture];
    
    //    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(onSetBackColor)];
    //    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    //
    //    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onSetBackRedColor) userInfo:nil repeats:YES];
    
}


- (IBAction)onStart:(UIButton *)sender
{
    // 测试泻染与动画占CPU问题
    // 互动直播中尽量少用repeate动画
    //    // 单独跑点CPU15%
    //    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(onSetBackColor)];
    //    self.link.frameInterval = 3;
    //    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    //
    //    // 单独跑CPU占1%
    ////    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onSetBackRedColor) userInfo:nil repeats:YES];
    ////    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    //    sender.backgroundColor = kYellowColor;
    //    [sender startGlowingWithColor:kRedColor fromIntensity:1 toIntensity:0.2 repeat:YES];
    //
    //// 两个叠加起来就到35%左右。。。。。。。
    //    return;
    
    
    self.startButton.enabled = NO;
    
    _recvID.enabled = NO;
    _msgCount.enabled = NO;
    
    [self startSendTimer];
}


- (IBAction)onStop:(UIButton *)sender
{
    self.msgIndex = 0;
    self.startButton.enabled = YES;
    
    _recvID.enabled = YES;
    _msgCount.enabled = YES;
    
    [_sendTimer invalidate];
    _sendTimer = nil;
    // 观众退群
}


- (void)startSendTimer
{
    _conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:[_recvID text]];
    
    CGFloat inde = [_msgCount.text floatValue];
    _sendTimer = [NSTimer scheduledTimerWithTimeInterval:inde target:self selector:@selector(onSendMsg) userInfo:nil repeats:YES];
}

- (void)onSendMsg
{
    NSString *text = [NSString stringWithFormat:@"%d, message from %@", (int)(self.msgIndex++), _recvID.text];
    
    TIMTextElem *elem = [[TIMTextElem alloc] init];
    elem.text = text;
    
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    [_conversation sendMessage:msg succ:^{
        DebugLog(@"发送 %@ 成功", msg);
    } fail:^(int code, NSString *msg) {
        DebugLog(@"发送消息失败");
    }];
}



@end
