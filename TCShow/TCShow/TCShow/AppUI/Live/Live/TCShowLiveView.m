//
//  TCShowLiveView.m
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveView.h"

@implementation TCShowLiveView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWith:(id<TCShowLiveRoomAble>)room
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _room = room;
        [self addOwnViews];
        [self configOwnViews];
    }
    return self;
}

- (void)configOwnViews
{
    [self registerKeyBoardNotification];
}


- (void)registerKeyBoardNotification
{
    //添加键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
}

#pragma mark - notification handler

#pragma mark -
#pragma mark Responding to keyboard events
- (void)onKeyboardDidShow:(NSNotification *)notification
{
    if ([_inputView isInputViewActive])
    {
        NSDictionary *userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        
        [UIView animateWithDuration:animationDuration animations:^{
            CGFloat ky = keyboardRect.origin.y;
            
            CGRect rect = _bottomView.frame;
            rect = CGRectInset(rect, 0, 10);
            rect.origin.y = ky - rect.size.height - (keyboardRect.origin.y + keyboardRect.size.height - self.bounds.size.height);;
            _inputView.frame = rect;
            [_msgView scaleToAboveOf:_inputView margin:kDefaultMargin];
        }];
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification
{
    if (![_inputView isInputViewActive])
    {
        NSDictionary* userInfo = [notification userInfo];
        
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        
        [UIView animateWithDuration:animationDuration animations:^{
            [_inputView alignParentBottomWithMargin:10];
            [_msgView scaleToAboveOf:_bottomView margin:kDefaultMargin];
        }];
    }
}

- (void)startLive
{
    [_topView startLive];
}
- (void)pauseLive
{
    [_topView pauseLive];
}
- (void)resumeLive
{
    [_topView resumeLive];
}

- (void)onRecvPraise
{
    NSInteger praise = [_room livePraise];
    [_room setLivePraise:praise + 1];
    [_bottomView showLikeHeart];
}

#if kSupportIMMsgCache
- (void)onRecvPraise:(AVIMCache *)cache
{
    NSInteger praise = [_room livePraise];
    [_room setLivePraise:praise + cache.count];
    
    [_topView onRefrshPraiseAndAudience];
    
    [_bottomView showLikeHeart:cache];
    
    [self onRefreshPAR];
}
#endif

- (void)setRoomEngine:(TCAVLiveRoomEngine *)roomEngine
{
    _roomEngine = roomEngine;
    [_topView onRefrshPARView:roomEngine];
    _bottomView.roomEngine = roomEngine;
}

- (void)addTopView
{
    _topView = [[TCShowLiveTopView alloc] initWith:_room];
    _topView.timeView.delegate = self;
    [self addSubview:_topView];
}


- (void)addOwnViews
{
    
    _parTextView = [[UITextView alloc] init];
    _parTextView.hidden = YES;
    _parTextView.backgroundColor = [kLightGrayColor colorWithAlphaComponent:0.5];
    _parTextView.editable = NO;
    [self addSubview:_parTextView];
    
    [self addTopView];
    
    _msgView = [[TCShowLiveMessageView alloc] init];
    [self addSubview:_msgView];
    
    _bottomView = [[TCShowLiveBottomView alloc] init];
    _bottomView.delegate = self;
    [self addSubview:_bottomView];
    
    _inputView = [[TCShowLiveInputView alloc] init];
    _inputView.limitLength = 32;
    _inputView.hidden = YES;
    
    __weak TCShowLiveView *ws = self;
    [_inputView addSendAction:^(id selfptr) {
        [ws sendMessage];
    }];
    
    [self addSubview:_inputView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBlank:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_msgView addGestureRecognizer:tap];
    
}

- (void)onTapBlank:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
    if ([_bottomView isPureMode] || _inputViewShowing)
    {
        return;
    }

        if ([_inputView isInputViewActive])
        {
            [_inputView resignFirstResponder];
        }
        else
        {
            if (!_inputView.hidden)
            {
                [self showActionPanel];
            }
        }
    }
}

- (void)showActionPanel
{
    if (_inputView.hidden)
    {
        return;
    }
    
    _inputView.text = nil;
    [_inputView resignFirstResponder];
    [_inputView fadeOut:0.3 delegate:nil];
    [_bottomView fadeIn:0.3 delegate:nil];
    
}

- (void)hideInputView
{
    [self showActionPanel];
}

- (void)sendMessage
{
    
#if DEBUG
    if (_inputView.text.length == 0)
    {
        [_msgHandler sendMessage:@"这是一个测试"];
    }
    else
    {
        [_msgHandler sendMessage:_inputView.text];
    }
#else
    
    NSString *msg = [_inputView.text trim];
    if (msg.length == 0)
    {
        [[HUDHelper sharedInstance] tipMessage:@"内容不能为空"];
        return;
    }
    
    [_msgHandler sendMessage:_inputView.text];
    [_inputView resignFirstResponder];
    [self showActionPanel];
#endif
    
}
- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    [_topView setFrameAndLayout:CGRectMake(0, 0, rect.size.width, 110)];
    
    [_bottomView sizeWith:CGSizeMake(rect.size.width, 60)];
    [_bottomView alignParentBottomWithMargin:0];
    [_bottomView relayoutFrameOfSubViews];
    
    [_inputView sameWith:_bottomView];
    [_inputView shrinkVertical:10];
    [_inputView relayoutFrameOfSubViews];
    
    [_msgView sizeWith:CGSizeMake((NSInteger)(rect.size.width * 0.7), 210)];
    [_msgView layoutBelow:_topView margin:kDefaultMargin];
    [_msgView scaleToAboveOf:_bottomView margin:kDefaultMargin];
    [_msgView relayoutFrameOfSubViews];
    
    [_parTextView sameWith:_topView];
    [_parTextView layoutBelow:_topView margin:kDefaultMargin];
    [_parTextView scaleToAboveOf:_bottomView margin:kDefaultMargin];

}


- (void)setMsgHandler:(AVIMMsgHandler *)msgHandler
{
    _msgHandler = msgHandler;
    _topView.imSender = (TCShowAVIMHandler *)msgHandler;
}

- (void)onBottomViewSwitchToPureMode:(TCShowLiveBottomView *)bottomView
{
    if (_inputView && !_inputView.hidden)
    {
        if (_inputView.isInputViewActive)
        {
            [_inputView resignFirstResponder];
        }
        
        [_inputView slideOutTo:kFTAnimationBottom duration:0.25 delegate:nil];
        
    }
    _isPureMode = YES;
    [_topView slideOutTo:kFTAnimationTop duration:0.25 delegate:nil];
    [_msgView changeToMode:YES];
    _msgHandler.isPureMode = YES;
    [_msgView slideOutTo:kFTAnimationLeft duration:0.25 delegate:nil];
}
- (void)onBottomViewSwitchToNonPureMode:(TCShowLiveBottomView *)bottomView
{
    _isPureMode = NO;
    [_topView slideInFrom:kFTAnimationTop duration:0.25 delegate:nil];
    [_msgView changeToMode:NO];
    _msgHandler.isPureMode = NO;
    [_msgView slideInFrom:kFTAnimationLeft duration:0.25 delegate:nil];
}

- (void)onBottomViewSwitchToMessage:(TCShowLiveBottomView *)bottomView fromButton:(UIButton *)button
{
    if (_inputViewShowing)
    {
        return;
    }
    _inputViewShowing = YES;
    [self animation:^(id selfPtr) {
        [_inputView becomeFirstResponder];
        [_bottomView fadeOut:0.25 delegate:nil];
        [_inputView fadeIn:0.25 delegate:nil];
    } duration:1 completion:^(id selfPtr) {
        button.enabled = YES;
        _inputViewShowing = NO;
    }];
}

- (void)onBottomViewSendPraise:(TCShowLiveBottomView *)bottomView fromButton:(UIButton *)button
{
    [_msgHandler sendLikeMessage];
    [_bottomView showLikeHeart];
    
    [_room setLivePraise:[_room livePraise] + 1];
    
}

- (void)onTimViewTimeRefresh:(TCShowLiveTimeView *)topView
{

}

- (void)onRefreshPAR
{
    if (!_parTextView.hidden)
    {
        NSString *log = [_roomEngine engineLog];
        if (log)
        {
            _parTextView.text = log;
        }
    }
}
- (void)showPar:(BOOL)hidden
{
    if ([_roomEngine isCameraEnable])
    {
        _parTextView.hidden = !hidden;
    }
    else
    {
        [[HUDHelper sharedInstance] tipMessage:@"PAR需要在相机打开情况下才有效"];
    }
}


- (void)onClickSub:(id<AVMultiUserAble>)user
{
    [self.bottomView switchToShowMultiInteract:user isMain:YES];
}
@end
