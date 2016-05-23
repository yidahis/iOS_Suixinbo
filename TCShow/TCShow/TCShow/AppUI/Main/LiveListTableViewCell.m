//
//  LiveListTableViewCell.m
//  TCShow
//
//  Created by AlexiChen on 16/4/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "LiveListTableViewCell.h"

@implementation LiveListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self addOwnViews];
        [self configWith:_liveItem];
        self.contentView.backgroundColor = RGBOF(0XEFEFF4);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)addOwnViews
{
    _liveCover = [[UIImageView alloc] init];
    [self.contentView addSubview:_liveCover];
    
    _liveType = [[UIButton alloc] init];
    [_liveType setBackgroundImage:[UIImage imageNamed:@"live_type"] forState:UIControlStateNormal];
    [_liveCover addSubview:_liveType];
    
    _liveHostView = [[UIView alloc] init];
    _liveHostView.backgroundColor = kWhiteColor;
    [self.contentView addSubview:_liveHostView];
    
    _liveHost = [[UIButton alloc] init];
    _liveHost.layer.cornerRadius = 22;
    _liveHost.layer.masksToBounds = YES;
    [_liveHostView addSubview:_liveHost];
    
    _liveTitle = [[UILabel alloc] init];
    _liveTitle.font = kAppMiddleTextFont;
    [_liveHostView addSubview:_liveTitle];
    
    _liveHostName = [[UILabel alloc] init];
    _liveHostName.textColor = kGrayColor;
    _liveHostName.font = kAppSmallTextFont;
    [_liveHostView addSubview:_liveHostName];
    
    
    _liveAudience = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    [_liveAudience setImage:[UIImage imageNamed:@"visitors_red"] forState:UIControlStateNormal];
    _liveAudience.titleLabel.adjustsFontSizeToFitWidth = YES;
    _liveAudience.titleLabel.font = kAppSmallTextFont;
    [_liveAudience setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_liveHostView addSubview:_liveAudience];
    
    _livePraise = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    [_livePraise setImage:[UIImage imageNamed:@"like_red"] forState:UIControlStateNormal];
    _livePraise.titleLabel.adjustsFontSizeToFitWidth = YES;
    _livePraise.titleLabel.font = kAppSmallTextFont;
    [_livePraise setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_liveHostView addSubview:_livePraise];
}

- (void)configWith:(id<TCShowLiveRoomAble>)item
{
    id<IMUserAble> host = [item liveHost];
    [_liveCover sd_setImageWithURL:[NSURL URLWithString:[item liveCover]] placeholderImage:kDefaultCoverIcon];
    [_liveHost sd_setImageWithURL:[NSURL URLWithString:[host imUserIconUrl]] forState:UIControlStateNormal placeholderImage:kDefaultUserIcon];
    
    if (item)
    {
        _liveHostName.text = [host imUserName];
        _liveTitle.text = [item liveTitle];
        [_liveAudience setTitle:[NSString stringWithFormat:@"%d", (int)[item liveWatchCount]] forState:UIControlStateNormal];
        [_livePraise setTitle:[NSString stringWithFormat:@"%d", (int)[item livePraise]] forState:UIControlStateNormal];
        
    }
    else
    {
        _liveHostName.text = @"测试直播标题";
        _liveTitle.text = @"测试帐号";
        [_liveAudience setTitle:@"1000" forState:UIControlStateNormal];
        [_livePraise setTitle:@"2000" forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutFrameOfSubViews];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.contentView.bounds;
    
    CGRect coverRect = rect;
    coverRect.size.height = (NSInteger)(rect.size.width * 0.618);
    _liveCover.frame = coverRect;
    
    [_liveType sizeWith:CGSizeMake(60, 30)];
    [_liveType alignParentTopWithMargin:kDefaultMargin];
    [_liveType alignParentLeftWithMargin:kDefaultMargin];
    
    coverRect.origin.y += coverRect.size.height;
    coverRect.size.height = 54;
    _liveHostView.frame = coverRect;
    
    [_liveHost sizeWith:CGSizeMake(44, 44)];
    [_liveHost layoutParentVerticalCenter];
    [_liveHost alignParentLeftWithMargin:kDefaultMargin];
    
    [_liveTitle sizeWith:CGSizeMake(0, 24)];
    [_liveTitle alignTop:_liveHost];
    [_liveTitle layoutToRightOf:_liveHost margin:kDefaultMargin];
    [_liveTitle scaleToParentRightWithMargin:kDefaultMargin];
    
    [_liveHostName sizeWith:CGSizeMake(_liveTitle.bounds.size.width/2, 20)];
    [_liveHostName alignLeft:_liveTitle];
    [_liveHostName layoutBelow:_liveTitle];
    
    [_liveAudience sizeWith:CGSizeMake(_liveTitle.bounds.size.width/4, 20)];
    [_liveAudience alignTop:_liveHostName];
    [_liveAudience layoutToRightOf:_liveHostName];
    
    [_livePraise sameWith:_liveAudience];
    [_livePraise layoutToRightOf:_liveAudience];
}
@end

