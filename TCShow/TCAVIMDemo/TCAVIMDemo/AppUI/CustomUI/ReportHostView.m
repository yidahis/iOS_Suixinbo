//
//  ReportHostView.m
//  TCShow
//
//  Created by AlexiChen on 16/5/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "ReportHostView.h"

@implementation ReportHostView

- (void)addOwnViews
{
    _backView = [[UIView alloc] init];
    _backView.backgroundColor = [kBlackColor colorWithAlphaComponent:0.3];
    [self addSubview:_backView];
    
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = kWhiteColor;
    _contentView.layer.cornerRadius = kDefaultMargin;
    _contentView.layer.masksToBounds = YES;
    [self addSubview:_contentView];
    
    _title = [[UILabel alloc] init];
    _title.font = kAppLargeTextFont;
    _title.textAlignment = NSTextAlignmentCenter;
    _title.text = @"请选择你的举报原因";
    [_contentView addSubview:_title];
    
    _ad = [self createButton:@"垃圾营销"];
    _fake = [self createButton:@"不实信息"];
    _harm = [self createButton:@"有害信息"];
    _illegal = [self createButton:@"违法信息"];
    _obscene = [self createButton:@"淫秽信息"];
    
    
    
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = kAppLargeTextFont;
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:kRedColor forState:UIControlStateHighlighted];
    [btn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor flatRedColor]] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor flatDarkRedColor]] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:btn];
    
    _cancel = btn;
    
    
}

- (void)relayoutFrameOfSubViews
{
    _backView.frame = self.bounds;
    
    [_contentView sizeWith:CGSizeMake(240, 275)];
    [_contentView alignParentCenter];

    [_title sizeWith:CGSizeMake(220, 30)];
    [_title alignParentTopWithMargin:kDefaultMargin];
    [_title layoutParentHorizontalCenter];
    
    [_ad sameWith:_title];
    [_ad layoutBelow:_title margin:kDefaultMargin];
    
    [_fake sameWith:_title];
    [_fake layoutBelow:_ad margin:kDefaultMargin];
    
    [_harm sameWith:_title];
    [_harm layoutBelow:_fake margin:kDefaultMargin];
    
    [_illegal sameWith:_title];
    [_illegal layoutBelow:_harm margin:kDefaultMargin];
    
    [_obscene sameWith:_title];
    [_obscene layoutBelow:_illegal margin:kDefaultMargin];
    
    [_cancel sameWith:_title];
    [_cancel layoutBelow:_obscene margin:kDefaultMargin];
    
}

- (UIButton *)createButton:(NSString *)title
{
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = kAppLargeTextFont;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kRedColor forState:UIControlStateNormal];
    [btn setTitleColor:kWhiteColor forState:UIControlStateHighlighted];
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:kRedColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [kRedColor CGColor];
    [_contentView addSubview:btn];
    return btn;
}

- (void)onClick:(UIButton *)btn
{
#if kSupportFTAnimation
    [self animation:^(id selfPtr) {
        [_backView fadeOut:0.25 delegate:nil];
        [_contentView slideOutTo:kFTAnimationTop duration:0.25 delegate:nil];
    } duration:0.3 completion:^(id selfPtr) {
        
        if (_cancel != btn)
        {
            [[HUDHelper sharedInstance] tipMessage:@"举报成功"];
        }
        [self removeFromSuperview];
    }];
#else
    if (_cancel != btn)
    {
        [[HUDHelper sharedInstance] tipMessage:@"举报成功"];
}
    [self removeFromSuperview];
#endif
}


- (void)showUser:(id<IMUserAble>)user
{
#if kSupportFTAnimation
    [_backView fadeIn:0.25 delegate:nil];
    [_contentView slideInFrom:kFTAnimationTop duration:0.25 delegate:nil];
#else
    _backView.hidden = NO;
    _contentView.hidden = NO;
#endif
}

@end
