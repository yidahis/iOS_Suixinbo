//
//  C2CVideoUIViewController.h
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C2CVideoUIViewController : UIViewController<TCAVLiveUIAbleView>

@property (nonatomic, weak) TCAVBaseViewController *liveController;
@property (nonatomic, weak) TCAVBaseRoomEngine *roomEngine;
@property (nonatomic, weak) AVIMMsgHandler *msgHandler;

@property (weak, nonatomic) IBOutlet UIView *smallView;
@property (weak, nonatomic) IBOutlet UISlider *beautySlider;

- (void)onEnterBackground;
- (void)onEnterForeground;

- (void)assignWindowResourceTo:(id<AVMultiUserAble>)user isInvite:(BOOL)inviteOrAuto;
@end
