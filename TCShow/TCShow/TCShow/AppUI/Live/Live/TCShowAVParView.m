//
//  TCShowAVParView.m
//  TCShow
//
//  Created by AlexiChen on 16/5/27.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowAVParView.h"

@implementation TCShowAVParView

- (void)onRefrshPARView:(TCAVLiveRoomEngine *)engine
{
    BOOL hasPush = [engine hasPushStream];
    _push.selected = hasPush;

    BOOL hasRec = [engine hasRecord];
    _rec.selected = hasRec;
}
- (void)addOwnViews
{
    UIImage *nor = [UIImage imageWithColor:[RGB(220, 220, 220) colorWithAlphaComponent:0.5]];
    UIImage *hig = [UIImage imageWithColor:[RGB(110, 110, 110) colorWithAlphaComponent:0.5]];
    
    _par = [[UIButton alloc] init];
    [_par setTitle:@"PAR" forState:UIControlStateNormal];
    _par.titleLabel.font = kAppMiddleTextFont;
    [_par addTarget:self action:@selector(onClickPar:) forControlEvents:UIControlEventTouchUpInside];
    [_par setTitleColor:kBlackColor forState:UIControlStateNormal];
    [_par setTitleColor:kWhiteColor forState:UIControlStateSelected];
    
    [_par setBackgroundImage:nor forState:UIControlStateNormal];
    [_par setBackgroundImage:hig forState:UIControlStateSelected];
    
    _par.layer.cornerRadius = 4;
    _par.layer.masksToBounds = YES;
    [self addSubview:_par];
    
    _push = [[UIButton alloc] init];
    
    [_push setTitle:@"开始推流" forState:UIControlStateNormal];
    [_push setTitle:@"关闭推流" forState:UIControlStateSelected];
    [_push addTarget:self action:@selector(onClickPush:) forControlEvents:UIControlEventTouchUpInside];
    _push.titleLabel.font = kAppMiddleTextFont;
    [_push setTitleColor:kBlackColor forState:UIControlStateNormal];
    [_push setTitleColor:kWhiteColor forState:UIControlStateSelected];
    
    [_push setBackgroundImage:nor forState:UIControlStateNormal];
    [_push setBackgroundImage:hig forState:UIControlStateSelected];
    
    _push.layer.cornerRadius = 4;
    _push.layer.masksToBounds = YES;
    
    [self addSubview:_push];
    
    
    
    UIImage *recHig = [UIImage imageWithColor:[kBlueColor colorWithAlphaComponent:0.5]];
    _rec = [[UIButton alloc] init];
    
    [_rec setTitle:@"REC" forState:UIControlStateNormal];
    [_rec addTarget:self action:@selector(onClickRec:) forControlEvents:UIControlEventTouchUpInside];
    _rec.titleLabel.font = kAppMiddleTextFont;
    [_rec setTitleColor:kBlackColor forState:UIControlStateNormal];
    [_rec setTitleColor:kWhiteColor forState:UIControlStateSelected];
    
    [_rec setBackgroundImage:nor forState:UIControlStateNormal];
    [_rec setBackgroundImage:recHig forState:UIControlStateSelected];
    
    _rec.layer.cornerRadius = 4;
    _rec.layer.masksToBounds = YES;
    
    [self addSubview:_rec];
}


- (void)onClickPar:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(onAVParView:clickPar:)])
    {
        [_delegate onAVParView:self clickPar:btn];
    }
}

- (void)onClickPush:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(onAVParView:clickPush:)])
    {
        [_delegate onAVParView:self clickPush:btn];
    }
}

- (void)onClickRec:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(onAVParView:clickRec:)])
    {
        [_delegate onAVParView:self clickRec:btn];
    }
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    NSArray *array = @[_par, _push, _rec];
    [self gridViews:array inColumn:array.count size:CGSizeMake(80, 24) margin:CGSizeMake(3, 3) inRect:rect];
}


@end
