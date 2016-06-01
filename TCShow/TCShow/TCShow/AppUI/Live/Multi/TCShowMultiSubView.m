//
//  TCShowMultiSubView.m
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowMultiSubView.h"

@implementation TCShowMultiSubView

#define kInviteTimeOut 30

- (instancetype)initWith:(id<AVMultiUserAble>)interactUser
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _interactUser = interactUser;
        [_interactUser setAvInvisibleInteractView:self];
        
        [self addOwnViews];
        [self configOwnViews];
    }
    
    return self;
}

- (instancetype)initWithSelf:(id<AVMultiUserAble>)currentUser
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _interactUser = currentUser;
        [_interactUser setAvInvisibleInteractView:self];
        
        [self addTapGesture];
    }
    return self;
}

- (void)addOwnViews
{
    _receiverHeadIcon = [[UIImageView alloc] init];
    _receiverHeadIcon.contentMode = UIViewContentModeScaleAspectFill;
    _receiverHeadIcon.clipsToBounds = YES;
    [self addSubview:_receiverHeadIcon];
    
    _stateTip = [[UILabel alloc] init];
    _stateTip.textAlignment = NSTextAlignmentCenter;
    _stateTip.font = [UIFont systemFontOfSize:13];
    _stateTip.backgroundColor = [UIColor clearColor];
    _stateTip.textColor = [UIColor whiteColor];
    _stateTip.numberOfLines = 0;
    _stateTip.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_stateTip];
    
    _hangUp = [[UIButton alloc] init];
    [_hangUp setBackgroundImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
    [_hangUp setBackgroundImage:[UIImage imageNamed:@"phone_hover"] forState:UIControlStateHighlighted];
    [_hangUp addTarget:self action:@selector(onHangUp) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hangUp];
    
    _stateTip.text = @"呼叫中\n……";
    
    // 一分钟内应答
    [self onStartInvite:kInviteTimeOut];
}

- (void)onHangUp
{
    if ([_delegate respondsToSelector:@selector(onMultiSubViewHangUp:)])
    {
        [_delegate onMultiSubViewHangUp:self];
    }
}

- (void)configOwnViews
{
    [_receiverHeadIcon sd_setImageWithURL:[NSURL URLWithString:[_interactUser imUserIconUrl]] placeholderImage:kDefaultUserIcon];
}

- (void)onStartInvite:(NSInteger)sec
{
    [_interactUser setAvMultiUserState:AVMultiUser_Interact_Inviting];
    
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:sec target:self selector:@selector(onInviteTimeOver) userInfo:nil repeats:NO];
    
}

- (void)onInviteTimeOver
{
    DebugLog(@"邀请超时, 对方没有应答");
    if ([_delegate respondsToSelector:@selector(onMultiSubViewInviteTimeout:)])
    {
        [_delegate onMultiSubViewInviteTimeout:self];
    }
}

- (void)willRemove
{
    [_interactUser setAvMultiUserState:AVMultiUser_Guest];
    [_interactUser setAvInvisibleInteractView:nil];
    
    [_timer invalidate];
    _timer = nil;
}

- (void)startConnect
{
    [_interactUser setAvMultiUserState:AVMultiUser_Interact_Connecting];
    
    _stateTip.text = @"请求画面\n……";
}

- (void)onConnectSucc
{
    [_interactUser setAvMultiUserState:AVMultiUser_Interact];
    
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _receiverHeadIcon.alpha = 0;
        _stateTip.alpha = 0;
        _hangUp.alpha = 0;
    } completion:^(BOOL finished) {

        [_receiverHeadIcon removeFromSuperview];
        _receiverHeadIcon = nil;
    
        [_stateTip removeFromSuperview];
        _stateTip = nil;

        [_hangUp removeFromSuperview];
        _hangUp = nil;
        
    
        [self addTapGesture];
    }];
    
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

- (void)onClick:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {    
    if ([_delegate respondsToSelector:@selector(onMultiSubViewClick:)])
    {
        [_delegate onMultiSubViewClick:self];
    }
}
}

//// 对应因视频中断，导致没有画面过来
//- (void)onVideoLost
//{
//    [_interactUser setAvMultiUserState:AVMultiUser_Interact_Losting];
//    
//    _headMask.hidden = NO;
//    _stateTip.hidden = NO;
//    
//    _stateTip.text = @"用户离线";
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _receiverHeadIcon.frame = self.bounds;
    _stateTip.frame = self.bounds;
    
    if (_hangUp)
    {
        [_hangUp sizeWith:CGSizeMake(50, 20)];
        [_hangUp layoutParentCenter];
        [_hangUp alignParentBottomWithMargin:10];
        
        [_stateTip scaleToAboveOf:_hangUp];
    }
}



@end
