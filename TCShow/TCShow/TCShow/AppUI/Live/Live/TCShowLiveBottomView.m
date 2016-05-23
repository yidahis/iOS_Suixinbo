//
//  TCShowLiveBottomView.m
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveBottomView.h"

@implementation TCShowLiveBottomView

#if kSupportIMMsgCache
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _praiseImageCache = [NSMutableArray array];
        
        // 创建点赞消息缓存
        _praiseImageCache = [NSMutableArray array];
        
        // 预先缓存点赞动画图片，主要是防止在收到大量点赞消息时，因加载资源的耗时
        UIImage *img = [UIImage imageNamed:@"img_like"];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatRedColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatDarkRedColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatGreenColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatDarkGreenColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatBlueColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatDarkBlueColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatTealColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatDarkTealColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatPurpleColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatDarkPurpleColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatYellowColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatDarkYellowColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatOrangeColor]]];
        [_praiseImageCache addObject:[img imageWithTintColor:[UIColor flatDarkOrangeColor]]];
        
        _praiseAnimationCache = [NSMutableArray array];
        
    }
    return self;
}
#endif


- (void)onTurnLED:(MenuButton *)btn
{
    btn.selected = !btn.selected;
    
    // 是否有麦克风
    // 是否有摄像头
    // 打开LED
    [_roomEngine turnOnFlash:btn.selected];
}

- (void)onSwitchCamera:(MenuButton *)btn
{
    btn.enabled = NO;
    // 打开LED
    [_roomEngine asyncSwitchCameraWithCompletion:^(BOOL succ, NSString *tip) {
        btn.enabled = YES;
    }];
}

- (void)onEnableInteractCamera:(MenuButton *)btn
{
    if ([_multiDelegate respondsToSelector:@selector(onBottomView:operateCameraOf:fromButton:)])
    {
        [_multiDelegate onBottomView:self operateCameraOf:_showUser fromButton:btn];
    }
}

- (void)onEnableInteractMic:(MenuButton *)btn
{
    if ([_multiDelegate respondsToSelector:@selector(onBottomView:operateMicOf:fromButton:)])
    {
        [_multiDelegate onBottomView:self operateMicOf:_showUser fromButton:btn];
    }
}

- (void)onSwitchToMain:(MenuButton *)btn
{
    if ([_multiDelegate respondsToSelector:@selector(onBottomView:switchToMain:fromButton:)])
    {
        [_multiDelegate onBottomView:self switchToMain:_showUser fromButton:btn];
    }
    
    _lastFunc &= ~EFunc_Multi_SwitchToMain;
    [self showFunc:_lastFunc];
}

- (void)onCancelInteract:(MenuButton *)btn
{
    if ([_multiDelegate respondsToSelector:@selector(onBottomView:cancelInteractWith:fromButton:)])
    {
        [_multiDelegate onBottomView:self cancelInteractWith:_showUser fromButton:btn];
    }
}


- (void)onBeautyChanged:(CGFloat)value
{
    _lastFloatBeauty = value;
    
    NSInteger be = (NSInteger)((value + 0.05) * 10);
    
    [_roomEngine setBeauty:be];
}
- (void)onSetBeauty
{
    TCShowSettingBeautyView *beautyView = [[TCShowSettingBeautyView alloc] init];
    [self.superview addSubview:beautyView];
    
    __weak TCShowLiveBottomView *ws = self;
    beautyView.changeCompletion = ^(CGFloat value){
        [ws onBeautyChanged:value];
    };
    
    [beautyView setFrameAndLayout:self.superview.bounds];
    
    if (_showUser && _lastFloatBeauty == 0)
    {
        // 说明只是当前自己
        _lastFloatBeauty = ([_roomEngine getBeauty] * 10)/100.0;
    }
    
    [beautyView setBeauty:_lastFloatBeauty];
}


- (void)setRoomEngine:(TCAVLiveRoomEngine *)roomEngine
{
    _roomEngine = roomEngine;
    
    BOOL isHost = [_roomEngine isHostLive];
    
    _lastFunc = EFunc_LocalAll & ~EFunc_NonPure & ~EFunc_Share;
    
    NSInteger func =  _lastFunc;
    func = isHost ? func | EFunc_LED : func & ~EFunc_LED;
    func = [_roomEngine isSupporBeauty] ? func | EFunc_Beauty : func & ~EFunc_Beauty;
    func = [_roomEngine isMicEnable] ? func | EFunc_Mic : func & ~EFunc_Mic;
    func = [_roomEngine isCameraEnable] ? func |EFunc_Camera : func & ~EFunc_Camera;
    func = [_roomEngine isSpeakerEnable] ? func | EFunc_Speaker : func & ~EFunc_Speaker;
    func = !isHost ? func | EFunc_MSG : func & ~EFunc_MSG;
    
    if (func != _lastFunc)
    {
        [self showFunc:func];
        [self slideInFrom:kFTAnimationBottom duration:0.25 delegate:nil];
    }
    
    _lastFloatBeauty = ([roomEngine getBeauty] * 10)/100.0;
}

- (void)onSwtichMic:(MenuButton *)btn
{
    btn.selected = !btn.selected;
    btn.enabled = NO;
    // 打开LED
    [_roomEngine asyncEnableMic:btn.selected completion:^(BOOL succ, NSString *tip) {
        btn.enabled = YES;
    }];
}

- (void)onSwtichSpeaker:(MenuButton *)btn
{
    btn.selected = !btn.selected;
    btn.enabled = NO;
    // 打开LED
    [_roomEngine asyncEnableSpeaker:btn.selected completion:^(BOOL succ, NSString *tip) {
        btn.enabled = YES;
    }];
}

- (void)onSwitchToPureMode
{
    _nonPureFunc = _lastFunc;
    [self showFunc:EFunc_NonPure];
    
    if ([_delegate respondsToSelector:@selector(onBottomViewSwitchToPureMode:)])
    {
        [_delegate onBottomViewSwitchToPureMode:self];
    }
}

- (void)onSwitchToNonPureMode
{
    [self showFunc:_nonPureFunc];
    if ([_delegate respondsToSelector:@selector(onBottomViewSwitchToNonPureMode:)])
    {
        [_delegate onBottomViewSwitchToNonPureMode:self];
    }
    _nonPureFunc = 0;
    
}

- (void)onComment:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(onBottomViewSwitchToMessage:fromButton:)])
    {
        btn.enabled = NO;
        [_delegate onBottomViewSwitchToMessage:self fromButton:btn];
    }
}

- (void)onPraise:(UIButton *)btn
{
    if (!_showUser)
    {
        if ([_roomEngine isHostLive])
        {
            return;
        }
        
    }
    else
    {
        if ([[[IMAPlatform sharedInstance].host imUserId] isEqualToString:[[[_roomEngine getRoomInfo] liveHost] imUserId]])
        {
            return;
        }
    }
    
    btn.enabled = NO;
    if ([_delegate respondsToSelector:@selector(onBottomViewSendPraise:fromButton:)])
    {
        [_delegate onBottomViewSendPraise:self fromButton:btn];
    }
    // 点赞消息产生的动画，大量产生时非常耗性能，建议观众端不要频繁发送
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
    });
}

- (void)addFunc:(NSInteger)funcid
{
    MenuButton *menuBtn = nil;
    __weak TCShowLiveBottomView *ws = self;
    switch (funcid)
    {
        case EFunc_LED:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"flash"] action:^(MenuButton *menu) {
                [ws onTurnLED:menu];
            }];
            [menuBtn setImage:[UIImage imageNamed:@"flash_hover"] forState:UIControlStateSelected];
        }
            break;
        case EFunc_MSG :
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"comment"] action:^(MenuButton *menu) {
                [ws onComment:menu];
            }];
            
            [menuBtn setImage:[UIImage imageNamed:@"comment_hover"] forState:UIControlStateHighlighted];
        }
            break;
            
        case EFunc_Camera:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"camera"] action:^(MenuButton *menu) {
                [ws onSwitchCamera:menu];
            }];
        }
            break;
        case EFunc_Beauty:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"beauty"] action:^(MenuButton *menu) {
                [ws onSetBeauty];
            }];
            [menuBtn setImage:[UIImage imageNamed:@"beauty_hover"] forState:UIControlStateHighlighted];
        }
            break;
        case EFunc_Mic:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"mic_shut"] action:^(MenuButton *menu) {
                [ws onSwtichMic:menu];
            }];
            [menuBtn setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateSelected];
            menuBtn.selected = [_roomEngine isMicEnable];
        }
            break;
        case EFunc_Speaker:
        {
            //            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"speaker_disable"] action:^(MenuButton *menu) {
            //                [ws onSwtichSpeaker:menu];
            //            }];
            //            [menuBtn setImage:[UIImage imageNamed:@"speaker_enable"] forState:UIControlStateSelected];
            //            menuBtn.selected = [_roomEngine isSpeakerEnable];
        }
            break;
        case EFunc_Share:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"share"] action:^(MenuButton *menu) {
                // do nothing
            }];
            [menuBtn setImage:[UIImage imageNamed:@"share_hover"] forState:UIControlStateHighlighted];
        }
            break;
        case EFunc_Pure:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"full_screen"] action:^(MenuButton *menu) {
                [ws onSwitchToPureMode];
            }];
        }
            break;
        case EFunc_NonPure:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"normal"] action:^(MenuButton *menu) {
                [ws onSwitchToNonPureMode];
            }];
        }
            break;
        case EFunc_Praise:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"like"] action:^(MenuButton *menu) {
                [ws onPraise:menu];
            }];
            [menuBtn setImage:[UIImage imageNamed:@"like_hover"] forState:UIControlStateHighlighted];
            
        }
            break;
            
            // 多人
        case EFunc_Multi_Camera:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"camera_on"] action:^(MenuButton *menu) {
                [ws onEnableInteractCamera:menu];
            }];
            [menuBtn setImage:[UIImage imageNamed:@"camera_click"] forState:UIControlStateHighlighted];
            //            menuBtn.selected = [_showUser avCtrlState] & EAVCtrlState_Camera;
        }
            break;
        case EFunc_Multi_Mic:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"mic"] action:^(MenuButton *menu) {
                [ws onEnableInteractMic:menu];
            }];
            [menuBtn setImage:[UIImage imageNamed:@"mic_click"] forState:UIControlStateHighlighted];
            //            menuBtn.selected = [_showUser avCtrlState] & EAVCtrlState_Mic;
        }
            break;
            
        case EFunc_Multi_SwitchToMain:
        {
            //            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"full_screen"] action:^(MenuButton *menu) {
            //                [ws onSwitchToMain:menu];
            //            }];
        }
            break;
            
        case EFunc_Multi_CancelInteract:
        {
            menuBtn = [[MenuButton alloc] initWithTitle:nil icon:[UIImage imageNamed:@"exit_interact"] action:^(MenuButton *menu) {
                [ws onCancelInteract:menu];
            }];
        }
            break;
            
        default:
            break;
    }
    
    if (menuBtn)
    {
        menuBtn.tag = funcid;
        [self addSubview:menuBtn];
        [_showFuncs addObject:menuBtn];
    }
}

- (void)showFunc:(NSInteger)func
{
    _lastFunc = func;
    if (!_showFuncs)
    {
        _showFuncs = [NSMutableArray array];
    }
    if (_showFuncs.count)
    {
        for (UIView *view in self.subviews)
        {
            [view removeFromSuperview];
        }
        [_showFuncs removeAllObjects];
    }
    
    
    
    NSUInteger op = EFunc_LED;
    do
    {
        if (op & func)
        {
            [self addFunc:op];
            func -= op;
        }
        op = op << 1;
        
    } while (func > 0);
    
    [self relayoutFrameOfSubViews];
    
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    rect = CGRectInset(rect, 0, (rect.size.height - 40)/2);
    
    if (_showFuncs.count > 1)
    {
        [self alignSubviews:_showFuncs horizontallyWithPadding:0 margin:0 inRect:rect];
    }
    else if (_showFuncs.count == 1)
    {
        UIView *view = _showFuncs[0];
        [view sizeWith:CGSizeMake(40, 40)];
        [view alignParentRightWithMargin:15];
        [view layoutParentVerticalCenter];
    }
    
    
    MenuButton *like = [self viewWithTag:EFunc_Praise];
    if (like)
    {
        _heartRect = [like.imageView relativePositionTo:self.superview];
    }
}

- (void)showLikeHeart
{
    if (_nonPureFunc == 0)
    {
        // 非纯净模式下显示点赞消息
        [self showLikeHeartStartRect:_heartRect];
    }
}
#if kSupportIMMsgCache
- (void)showLikeHeart:(AVIMCache *)cache
{
    if (_nonPureFunc == 0)
    {
        if (cache.count)
        {
            // 非纯净模式下显示点赞消息
            [self showLikeHeartStartRect:_heartRect count:cache.count > 5 ? 5 : cache.count];
        }
        else
        {
            // 没有的时候，释放缓存
            if (_praiseAnimationCache.count)
            {
                UIImageView *imageView = [_praiseAnimationCache objectAtIndex:0];
                [_praiseAnimationCache removeObject:imageView];
                [imageView removeFromSuperview];
            }
        }
    }
}
#endif

- (BOOL)isPureMode
{
    return !(_nonPureFunc == 0);
}


- (CAAnimation *)hearAnimationFrom:(CGRect)frame
{
    //位置
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.beginTime = 0.5;
    animation.duration = 2.5;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount= 0;
    animation.calculationMode = kCAAnimationCubicPaced;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPoint point0 = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    
    CGPathMoveToPoint(curvedPath, NULL, point0.x, point0.y);
    
    float x11 = point0.x - arc4random() % 30 + 30;
    float y11 = frame.origin.y - arc4random() % 60 ;
    float x1 = point0.x - arc4random() % 15 + 15;
    float y1 = frame.origin.y - arc4random() % 60 - 30;
    CGPoint point1 = CGPointMake(x1, y1);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, x11, y11, point1.x, point1.y);
    
    int conffset2 = self.superview.bounds.size.width * 0.2;
    int conffset21 = self.superview.bounds.size.width * 0.1;
    float x2 = point0.x - arc4random() % conffset2 + conffset2;
    float y2 = arc4random() % 30 + 240;
    float x21 = point0.x - arc4random() % conffset21  + conffset21;
    float y21 = (y2 + y1) / 2 + arc4random() % 30 - 30;
    CGPoint point2 = CGPointMake(x2, y2);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, x21, y21, point2.x, point2.y);
    
    animation.path = curvedPath;
    
    CGPathRelease(curvedPath);
    
    //透明度变化
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:0];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.beginTime = 0;
    opacityAnim.duration = 3;
    
    //比例
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //        int scale = arc4random() % 5 + 5;
    scaleAnim.fromValue = [NSNumber numberWithFloat:.0];//[NSNumber numberWithFloat:((float)scale / 10)];
    scaleAnim.toValue = [NSNumber numberWithFloat:1];
    scaleAnim.removedOnCompletion = NO;
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.duration = .5;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects: scaleAnim,opacityAnim,animation, nil];
    animGroup.duration = 3;
    
    return animGroup;
}

- (void)showLikeHeartStartRect:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc ] initWithFrame:frame];
    imageView.image = [[UIImage imageNamed:@"img_like"] imageWithTintColor:[UIColor randomFlatDarkColor]];
    [self.superview addSubview:imageView];
    imageView.alpha = 0;
    
    
    [imageView.layer addAnimation:[self hearAnimationFrom:frame] forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
    
}
#if kSupportIMMsgCache
- (void)showLikeHeartStartRect:(CGRect)frame count:(NSInteger)count
{
    for (int i = 0; i < count; i++)
    {
        [self showLikeHeartStartRectFrameCache:frame];
    }
}


- (void)showLikeHeartStartRectFrameCache:(CGRect)frame
{
    UIImageView *imageView = nil;
    if (_praiseAnimationCache.count)
    {
        imageView = [_praiseAnimationCache objectAtIndex:0];
        [_praiseAnimationCache removeObject:imageView];
        imageView.frame = frame;
        imageView.hidden = NO;
    }
    else
    {
        imageView = [[UIImageView alloc ] initWithFrame:frame];
        imageView.image = _praiseImageCache[arc4random()%_praiseImageCache.count];
        [self.superview addSubview:imageView];
    }
    imageView.alpha = 0;
    
    [imageView.layer addAnimation:[self hearAnimationFrom:frame] forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_praiseAnimationCache addObject:imageView];
    });
    
    
}

#endif

- (void)updateShowFunc
{
    // 不记住状态，不作处理
    //    if (_showUser)
    //    {
    //        [self switchToShowMultiInteract:_showUser isMain:YES];
    //         主要是像头，跟Mic
    //        UIButton *mic = (UIButton *)[self viewWithTag:EFunc_Mic];
    //        mic.selected = [_roomEngine isMicEnable];
    //
    //
    //        UIButton *mmic = (UIButton *)[self viewWithTag:EFunc_Multi_Mic];
    //        mmic.selected = [_showUser avCtrlState] & EAVCtrlState_Mic;
    //    }
}

- (void)switchToShowMultiInteract:(id<AVMultiUserAble>)showUser isMain:(BOOL)main
{
    NSString *liveHostId = [[[_roomEngine getRoomInfo] liveHost] imUserId];
    
    _showUser = showUser;
    
    NSString *showUserId = [showUser imUserId];
    
    BOOL hasUpdate = NO;
    
    BOOL isPure = _lastFunc == EFunc_NonPure;
    
    if ([_roomEngine isHostLive])
    {
        // 主播端
        if ([liveHostId isEqualToString:showUserId])
        {
            // 切回到主播
            NSInteger func =  [self onGetWatchHostFunc:main];
            // 互动观众要有Mic
            func |= EFunc_Mic;
            if (_lastFunc != func)
            {
                [self showFunc:func];
                hasUpdate = YES;
            }
        }
        else
        {
            // 当前非主播视角
            NSInteger multiFunc = EFunc_MultiAll & ~EFunc_NonPure;
            
            if (!main)
            {
                // 全屏显示
                multiFunc |= EFunc_Multi_SwitchToMain;
            }
            else
            {
                // 非全屏显示
                multiFunc &= ~EFunc_Multi_SwitchToMain;
            }
            
            if (_lastFunc != multiFunc)
            {
                [self showFunc:multiFunc];
                hasUpdate = YES;
            }
        }
    }
    else
    {
        // 观众端
        if ([showUserId isEqualToString:[[_roomEngine getIMUser] imUserId]])
        {
            // 是否是看的自己
            // 互动观众看自己
            NSInteger func = [self onGetWatchHostFunc:main];
            // 能发消息
            func |= EFunc_LED | EFunc_MSG | EFunc_Multi_CancelInteract;
            
            // 互动观众要有Mic
            func |= EFunc_Mic;
            
            
            if (!main)
            {
                // 全屏显示
                func |= EFunc_Multi_SwitchToMain;
            }
            else
            {
                // 非全屏显示
                func &= ~EFunc_Multi_SwitchToMain;
            }
            
            
            if (_lastFunc != func)
            {
                [self showFunc:func];
                hasUpdate = YES;
            }
        
        }
        else
        {
            // 观众看主播
            NSInteger func = EFunc_MSG | EFunc_Speaker | EFunc_Pure | EFunc_Praise;
            
            if (!main)
            {
                // 全屏显示
                func |= EFunc_Multi_SwitchToMain;
            }
            else
            {
                // 非全屏显示
                func &= ~EFunc_Multi_SwitchToMain;
            }
            
            if (_lastFunc != func)
            {
                [self showFunc:func];
                hasUpdate = YES;
            }
        }
        
    }
    
    if (hasUpdate && isPure)
    {
        if ([_delegate respondsToSelector:@selector(onBottomViewSwitchToNonPureMode:)])
        {
            [_delegate onBottomViewSwitchToNonPureMode:self];
        }
    }
}

- (NSInteger)onGetWatchHostFunc:(BOOL)isMain
{
    NSInteger func =  EFunc_LocalAll & ~EFunc_NonPure & ~EFunc_Share;;
    func = [_roomEngine isHostLive] ? func | EFunc_LED : func & ~EFunc_LED;
    func = [_roomEngine isSupporBeauty] ? func | EFunc_Beauty : func & ~EFunc_Beauty;
    func = [_roomEngine isMicEnable] ? func | EFunc_Mic : func & ~EFunc_Mic;
    func = [_roomEngine isCameraEnable] ? func |EFunc_Camera : func & ~EFunc_Camera;
    func = [_roomEngine isSpeakerEnable] ? func | EFunc_Speaker : func & ~EFunc_Speaker;
    func = ![_roomEngine isHostLive] ? func | EFunc_MSG : func & ~EFunc_MSG;
    
    if (!isMain)
    {
        func |= EFunc_Multi_SwitchToMain;
    }
    
    
    return func;
    
}

@end
