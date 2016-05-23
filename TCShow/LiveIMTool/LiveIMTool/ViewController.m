//
//  ViewController.m
//  LiveIMTool
//
//  Created by AlexiChen on 16/4/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSTimer *sendTimer;
@property (nonatomic, strong) TIMConversation *conversation;
@property (nonatomic, assign) NSInteger msgIndex;

@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTapBlankToHideKeyboardGesture];
    
//    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(onSetBackColor)];
//    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//    
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onSetBackRedColor) userInfo:nil repeats:YES];
    
}

- (void)onSetBackColor
{
    NSInteger count;
    for (NSInteger i = 0; i < 1000000; i++)
    {
        count++;
    }
    self.view.backgroundColor = kRandomFlatColor;
    
}

- (void)onSetBackRedColor
{
    self.view.backgroundColor = kRedColor;
    
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
    
    _groupNum.enabled = NO;
    _msgCount.enabled = NO;
    _mesText.enabled = NO;
    
    
    NSString *groupId = [_groupNum text];
    
    
    __weak ViewController *ws = self;
    // 观众加群
    [[TIMGroupManager sharedInstance] JoinGroup:groupId msg:nil succ:^{
        [ws startSendTimer];
    } fail:^(int code, NSString *string) {
        
        if (code == 10013)
        {
            [ws startSendTimer];
        }
        else
        {
            NSLog(@"----->>>>>观众加入直播聊天室失败");
        }
        
    }];
}


- (IBAction)onStop:(UIButton *)sender
{
    self.msgIndex = 0;
    self.startButton.enabled = YES;
    
    _groupNum.enabled = YES;
    _msgCount.enabled = YES;
    _mesText.enabled = YES;
    
    [_sendTimer invalidate];
    _sendTimer = nil;
    // 观众退群
    [[TIMGroupManager sharedInstance] QuitGroup:[_groupNum text] succ:nil fail:nil];
}


- (void)startSendTimer
{
    _conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:[_groupNum text]];
    
    CGFloat inde = [_msgCount.text floatValue];
    _sendTimer = [NSTimer scheduledTimerWithTimeInterval:inde target:self selector:@selector(onSendMsg) userInfo:nil repeats:YES];
}

- (void)onSendMsg
{
    NSString *text = [NSString stringWithFormat:@"%d, %@", (int)(self.msgIndex++), _mesText.text];
    
    TIMTextElem *telem = [[TIMTextElem alloc] init];
    telem.text = text;
    
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:telem];
    
    [_conversation sendMessage:msg succ:^{
        DebugLog(@"发送 %@ 成功", msg);
    } fail:^(int code, NSString *msg) {
        DebugLog(@"发送消息失败");
    }];

    // do nothing
    AVIMCMD *cmd = [[AVIMCMD alloc] initWith:AVIMCMD_Praise];
    
    TIMCustomElem *elem = [[TIMCustomElem alloc] init];
    elem.data = [cmd packToSendData];
    
    TIMMessage *timMsg = [[TIMMessage alloc] init];
    [timMsg addElem:elem];
    
    [_conversation sendLikeMessage:timMsg succ:^{
        DebugLog(@"发送成功");
    } fail:^(int code, NSString *msg) {
         DebugLog(@"发送失败");
    }];
}



@end
