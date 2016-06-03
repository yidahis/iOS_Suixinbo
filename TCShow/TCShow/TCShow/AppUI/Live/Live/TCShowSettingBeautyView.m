//
//  TCShowSettingBeautyView.m
//  live
//
//  Created by AlexiChen on 16/2/25.
//  Copyright © 2016年 kenneth. All rights reserved.
//

#import "TCShowSettingBeautyView.h"

@interface TCShowBeautyTipView : UIView
{
    UIImageView *_tipBg;
    UILabel     *_tip;
}

- (void)setBeauty:(CGFloat)beauty;

@end


@implementation TCShowBeautyTipView

- (instancetype)init
{
    if (self = [super init])
    {
        _tipBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beautyTip"]];
        [self addSubview:_tipBg];
        
        _tip = [[UILabel alloc] init];
        _tip.font = [UIFont systemFontOfSize:13];
        _tip.adjustsFontSizeToFitWidth = YES;
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.textColor = [UIColor whiteColor];
        [self addSubview:_tip];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tipBg.frame = self.bounds;
    _tip.frame = CGRectMake(0, 2, self.bounds.size.width, self.bounds.size.height - 10);
    
}

- (void)setBeauty:(CGFloat)beauty
{
    _tip.text = [NSString stringWithFormat:@"美颜度 %d％", (int)(100 * beauty)];
}
@end



@interface TCShowSettingBeautyView ()
{
    TCShowBeautyTipView *_tipView;
}

@end

@implementation TCShowSettingBeautyView

- (void)addOwnViews
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    _clearBg = [[UIView alloc] init];
    [self addSubview:_clearBg];
    
    _sliderBack = [[UIView alloc] init];
    _sliderBack.backgroundColor = kWhiteColor;
    _sliderBack.clipsToBounds = NO;
    [self addSubview:_sliderBack];
    
    _slider = [[UISlider alloc] init];
    [_sliderBack addSubview:_slider];
    
    
    UIImage *img = [UIImage imageNamed:@"beauty_slider"];
    [_slider setThumbImage:img forState:UIControlStateNormal];
    [_slider setThumbImage:img forState:UIControlStateSelected];
    [_slider setThumbImage:img forState:UIControlStateHighlighted];
    [_slider addTarget:self action:@selector(onBeautyChanged:) forControlEvents:UIControlEventValueChanged];
    [_sliderBack addSubview:_slider];
    
    _tipView = [[TCShowBeautyTipView alloc] init];
    [_sliderBack addSubview:_tipView];
    _tipView.frame = CGRectMake(0, 0, 75, 27);
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_clearBg addGestureRecognizer:tap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self moveTip];
}


- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    _clearBg.frame = rect;
    
    [_sliderBack sizeWith:CGSizeMake(rect.size.width, 60)];
    [_sliderBack alignParentBottom];
    
    rect = _sliderBack.bounds;
    _slider.frame = CGRectInset(rect, 30, 20);
}

- (void)onBeautyChanged:(id)sender
{
    [self moveTip];
    if (_changeCompletion)
    {
        _changeCompletion(_slider.value);
    }
}

- (void)moveTip
{
    CGRect tipFrame = _tipView.frame;
    CGRect rect = _slider.frame;
    tipFrame.origin.y = rect.origin.y - tipFrame.size.height;
    CGFloat value = _slider.value;
    tipFrame.origin.x = rect.origin.x + value * rect.size.width - tipFrame.size.width/2;
    _tipView.frame = tipFrame;
    [_tipView setBeauty:_slider.value];
}


- (void)onTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self close];
    }
}

- (void)close
{
#if kSupportFTAnimation
    [self animation:^(id selfPtr) {
        [_slider slideOutTo:kFTAnimationBottom duration:0.25 delegate:nil];
        [self fadeOut:0.25 delegate:nil];
    } duration:0.3 completion:^(id selfPtr) {
        [self removeFromSuperview];
    }];
#else
    [self removeFromSuperview];
#endif
}

- (void)setBeauty:(CGFloat)beauty
{
    _slider.value = beauty;
    [self moveTip];
}
@end
