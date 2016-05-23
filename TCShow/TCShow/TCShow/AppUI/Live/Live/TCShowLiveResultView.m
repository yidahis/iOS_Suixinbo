//
//  TCShowLiveResultView.m
//  TCShow
//
//  Created by AlexiChen on 16/5/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveResultView.h"

@implementation TCShowLiveResultView

- (instancetype)initWith:(TCShowLiveListItem *)roomItem completion:(MenuAction)completion
{
    if (self = [super init])
    {
        [self configOwnViewsWith:roomItem];
        [_back setClickAction:completion];
        
        self.backgroundColor = [kBlackColor colorWithAlphaComponent:0.7];
    }
    return self;
}

- (void)configOwnViewsWith:(TCShowLiveListItem *)item
{
    _title.text = @"直播结束啦!";
    
    NSInteger liveDur = [item timeSpan];
    NSInteger liveHour = liveDur / 3600;
    NSInteger liveMin = (liveDur - liveHour * 3600) / 60;
    NSInteger liveSec = liveDur - liveHour * 3600 - 60 *liveMin;
    _liveTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld\n直播时长", (long)liveHour, (long)liveMin, (long)liveSec];
    
    _liveWatch.text = [NSString stringWithFormat:@"%ld\n观看人数", (long)item.watchCount];
    
    _livePraise.text = [NSString stringWithFormat:@"%ld\n获赞数量", (long)item.admireCount];
}

- (void)addOwnViews
{
    _title = [[UILabel alloc] init];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.font = [UIFont boldSystemFontOfSize:32];
    _title.textColor = kWhiteColor;
    [self addSubview:_title];
    
    _liveTime = [[UILabel alloc] init];
    _liveTime.textAlignment = NSTextAlignmentCenter;
    _liveTime.font = [UIFont boldSystemFontOfSize:20];
    _liveTime.textColor = kWhiteColor;
    _liveTime.numberOfLines = 0;
    _liveTime.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_liveTime];
    
    _liveWatch = [[UILabel alloc] init];
    _liveWatch.textAlignment = NSTextAlignmentCenter;
    _liveWatch.font = [UIFont boldSystemFontOfSize:20];
    _liveWatch.textColor = kWhiteColor;
    _liveWatch.numberOfLines = 0;
    _liveWatch.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_liveWatch];
    
    _livePraise = [[UILabel alloc] init];
    _livePraise.textAlignment = NSTextAlignmentCenter;
    _livePraise.font = [UIFont boldSystemFontOfSize:20];
    _livePraise.textColor = kWhiteColor;
    _livePraise.numberOfLines = 0;
    _livePraise.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_livePraise];
    
    _back = [[MenuButton alloc] init];
    _back.layer.borderColor = [[UIColor flatRedColor] CGColor];
    _back.layer.borderWidth = 1;
    _back.layer.masksToBounds = YES;
    _back.titleLabel.font = [UIFont systemFontOfSize:20];
    [_back setTitle:@"返回首页" forState:UIControlStateNormal];
    [_back setTitleColor:[UIColor flatRedColor] forState:UIControlStateNormal];
    [self addSubview:_back];
}

- (void)relayoutFrameOfSubViews
{
    CGRect rect = self.bounds;
    
    CGFloat off = (rect.size.height - 50 * 4 - 20 * 4 - 44)/2;
    
    [_title sizeWith:CGSizeMake(rect.size.width, 50)];
    [_title alignParentTopWithMargin:off];
    
    [_liveTime sizeWith:CGSizeMake(rect.size.width, 50)];
    [_liveTime layoutBelow:_title margin:20];
    
    [_liveWatch sizeWith:CGSizeMake(rect.size.width, 50)];
    [_liveWatch layoutBelow:_liveTime margin:20];
    
    [_livePraise sizeWith:CGSizeMake(rect.size.width, 50)];
    [_livePraise layoutBelow:_liveWatch margin:20];
    
    [_back sizeWith:CGSizeMake(rect.size.width - 80, 44)];
    [_back layoutParentHorizontalCenter];
    [_back layoutBelow:_livePraise margin:20];
}

@end
