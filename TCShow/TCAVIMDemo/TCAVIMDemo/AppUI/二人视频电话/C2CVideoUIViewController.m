//
//  C2CVideoUIViewController.m
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "C2CVideoUIViewController.h"
#import "C2CVideoViewController.h"

@interface C2CVideoUIViewController ()

@end

@implementation C2CVideoUIViewController


- (instancetype)initWith:(TCAVBaseViewController *)controller
{
    if (self = [super init])
    {
        _liveController = controller;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kClearColor;
}

- (void)onEnterBackground
{
    
}
- (void)onEnterForeground
{
    
}

- (IBAction)switchMainScreen:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        //    [_liveView.bottomView switchToShowMultiInteract:user isMain:NO];
        TCAVMultiLiveViewController *mvc = (TCAVMultiLiveViewController *)_liveController;
        TCAVIMMIManager *mgr = mvc.multiManager;
        
        id<AVMultiUserAble> user = nil;
        
        NSArray *array = mgr.multiResource;
        if (array.count == 2)
        {
            // 找到第一个非主屏用户
            for (NSInteger i = 0; i < array.count; i++)
            {
                id<AVMultiUserAble> u = array[i];
                if (![[u imUserId] isEqualToString:[mgr.mainUser imUserId]]) {
                    user = u;
                    break;
                }
            }
        }
        
        if (user)
        {
            [mvc switchToMainInPreview:user completion:nil];
        }
    }
    
    
}

- (void)assignWindowResourceTo:(id<AVMultiUserAble>)user isInvite:(BOOL)inviteOrAuto
{
    // 后期作互动窗口切换使用
    [user setAvInvisibleInteractView:self.smallView];
    
    // 相对于全屏的位置
    CGRect rect = [self.smallView relativePositionTo:[UIApplication sharedApplication].keyWindow];
    [user setAvInteractArea:rect];
}
- (IBAction)onEnableSpeaker:(UIButton *)sender {
    
     [(TCAVLiveRoomEngine *)_roomEngine asyncEnableMic:!sender.selected completion:^(BOOL succ, NSString *tip) {
         if (succ)
         {
             sender.selected = !sender.selected;
         }
     }];
}
- (IBAction)onEnableMic:(UIButton *)sender
{
    [(TCAVLiveRoomEngine *)_roomEngine asyncSwitchEnableMicCompletion:^(BOOL succ, NSString *tip) {
        if (succ)
        {
            sender.selected = [(TCAVLiveRoomEngine *)_roomEngine isMicEnable];
        }
    }];
}
- (IBAction)onEnableCamera:(UIButton *)sender {
    [(TCAVLiveRoomEngine *)_roomEngine asyncEnableCamera:!sender.selected completion:^(BOOL succ, NSString *tip) {
        if (succ)
        {
            sender.selected = !sender.selected;
        }
    }];
}

- (IBAction)onHangUp:(id)sender
{
    [_liveController exitLive];
}
- (IBAction)onSwitchCamera:(id)sender
{
    [(TCAVLiveRoomEngine *)_roomEngine asyncSwitchCameraWithCompletion:nil];
    
}
- (IBAction)onBeauty:(id)sender {
    _beautySlider.hidden = !_beautySlider.hidden;
}
- (IBAction)onBeautyChanged:(id)sender {
    [(TCAVLiveRoomEngine *)_roomEngine setBeauty:_beautySlider.value];
}

@end
