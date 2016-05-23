//
//  TCShowLiveTopView.m
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveTopView.h"


@implementation TCShowLiveTimeView

- (instancetype)initWith:(id<TCShowLiveRoomAble>)room
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _room = room;
        [self addOwnViews];
        [self configOwnViews];
        
        self.backgroundColor = [kBlackColor colorWithAlphaComponent:0.3];
        self.layer.cornerRadius = 25;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (BOOL)isHost
{
    return [[IMAPlatform sharedInstance].host isCurrentLiveHost:_room];
}

- (void)addOwnViews
{
    _liveHost = [[MenuButton alloc] init];
    _liveHost.layer.cornerRadius = 22;
    _liveHost.layer.masksToBounds = YES;
    [self addSubview:_liveHost];
    
    
    if ([self isHost])
    {
        _liveTime = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
        [_liveTime setImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
        [_liveTime setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [self addSubview:_liveTime];
    }
    else
    {
        _liveTime = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightLeft];
        [_liveTime setTitleColor:kWhiteColor forState:UIControlStateNormal];
        _liveTime.titleLabel.adjustsFontSizeToFitWidth = YES;
        _liveTime.titleLabel.textAlignment = NSTextAlignmentLeft;
        _liveTime.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_liveTime];
    }
    
    _liveAudience = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    [_liveAudience setImage:[UIImage imageNamed:@"visitor_white"] forState:UIControlStateNormal];
    _liveAudience.titleLabel.adjustsFontSizeToFitWidth = YES;
    _liveAudience.titleLabel.font = kAppSmallTextFont;
    [_liveAudience setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self addSubview:_liveAudience];
    
    _livePraise = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    [_livePraise setImage:[UIImage imageNamed:@"like_white"] forState:UIControlStateNormal];
    _livePraise.titleLabel.adjustsFontSizeToFitWidth = YES;
    _livePraise.titleLabel.font = kAppSmallTextFont;
    [_livePraise setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self addSubview:_livePraise];
    
}

- (void)onClickHost
{
    
}
- (void)configOwnViews
{
    NSString *url = [[_room liveHost] imUserIconUrl];
    [_liveHost sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:kDefaultUserIcon];
    
    if ([self isHost])
    {
        [_liveTime setTitle:@"00:00" forState:UIControlStateNormal];
    }
    else
    {
        [_liveTime setTitle:[[_room liveHost] imUserName] forState:UIControlStateNormal];
    }
    
    [_liveAudience setTitle:[NSString stringWithFormat:@"%d", (int)[_room liveAudience]] forState:UIControlStateNormal];
    [_livePraise setTitle:[NSString stringWithFormat:@"%d", (int)[_room livePraise]] forState:UIControlStateNormal];
    
}

- (void)relayoutFrameOfSubViews
{
    [_liveHost sizeWith:CGSizeMake(44, 44)];
    [_liveHost layoutParentVerticalCenter];
    [_liveHost alignParentLeftWithMargin:3];
    
    [_liveTime sizeWith:CGSizeMake(20, 20)];
    [_liveTime alignTop:_liveHost];
    [_liveTime layoutToRightOf:_liveHost margin:3];
    [_liveTime scaleToParentRightWithMargin:10];
    
    [_liveAudience sizeWith:CGSizeMake(_liveTime.bounds.size.width/2, _liveTime.bounds.size.height)];
    [_liveAudience alignLeft:_liveTime];
    [_liveAudience alignBottom:_liveHost];
    
    [_livePraise sameWith:_liveAudience];
    [_livePraise layoutToRightOf:_liveAudience];
    
    
}

- (void)startLive
{
    [_liveTimer invalidate];
    _liveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onLiveTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_liveTimer forMode:NSRunLoopCommonModes];
    

}

- (void)onLiveTimer
{
    if ([self isHost])
    {

        NSInteger dur = [_room liveDuration] + 1;
        [_room setLiveDuration:dur];
        
        NSString *durStr = nil;
        if (dur > 3600)
        {
            int h = (int)dur/3600;
            int m = (int)(dur - h *3600)/60;
            int s = (int)dur%60;
            durStr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
        }
        else
        {
            int m = (int)dur/60;
            int s = (int)dur%60;
            durStr = [NSString stringWithFormat:@"%02d:%02d", m, s];
        }
        
        
        [_liveTime setTitle:durStr forState:UIControlStateNormal];
        [_delegate onTimViewTimeRefresh:self];
    }
}

- (void)onRefrshPraiseAndAudience
{
    [_liveAudience setTitle:[NSString stringWithFormat:@"%d", (int)[_room liveAudience]] forState:UIControlStateNormal];
    [_livePraise setTitle:[NSString stringWithFormat:@"%d", (int)[_room livePraise]] forState:UIControlStateNormal];
}


- (void)pauseLive
{
    if ([self isHost])
    {
        [_liveTimer invalidate];
        _liveTimer = nil;
    }
    
}


- (void)resumeLive
{
    
    [self startLive];
}

- (void)onImUsersEnterLive:(NSArray *)array
{
    [_room setLiveAudience:[_room liveAudience] + array.count];
    [_liveAudience setTitle:[NSString stringWithFormat:@"%d", (int)[_room liveAudience]] forState:UIControlStateNormal];
}
- (void)onImUsersExitLive:(NSArray *)array
{
    [_room setLiveAudience:[_room liveAudience] - array.count];
    [_liveAudience setTitle:[NSString stringWithFormat:@"%d", (int)[_room liveAudience]] forState:UIControlStateNormal];
}


@end

@interface LiveUserViewCell : UICollectionViewCell
{
    UIImageView         *_userIcon;
}

@property (nonatomic, readonly) UIImageView *userIcon;

@end

@implementation LiveUserViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame])
    {
        _userIcon = [[UIImageView alloc] init];
        _userIcon.image = kDefaultUserIcon;
        _userIcon.layer.cornerRadius = 16;
        _userIcon.layer.masksToBounds = YES;
        [self.contentView addSubview:_userIcon];
    }
    return self;
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    CGRect rect = self.contentView.bounds;
    _userIcon.frame = CGRectInset(rect, (rect.size.width - 32)/2, (rect.size.height - 32)/2);
}


@end

@implementation TCShowLiveTopView


- (instancetype)initWith:(id<TCShowLiveRoomAble>)room
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _room = room;
        [self addOwnViewsWith:room];
        [self configOwnViewsWith:room];
    }
    return self;
}

- (void)onImUsersEnterLive:(NSArray *)array
{
    [_timeView onImUsersEnterLive:array];
}
- (void)onImUsersExitLive:(NSArray *)array
{
    [_timeView onImUsersExitLive:array];
}

- (void)onClickClose
{
        
    if (_delegate && [_delegate respondsToSelector:@selector(onTopViewCloseLive:)])
    {
        [_delegate onTopViewCloseLive:self];
    }
}

- (void)startLive
{
    [_timeView startLive];
#if kBetaVersion
    _roomTip.text = [NSString stringWithFormat:@"AV:%d IM:%@", [_room liveAVRoomId], [_room liveIMChatRoomId]];
#endif
}
- (void)pauseLive
{
        
    [_timeView pauseLive];
}
- (void)resumeLive
{
        
    [_timeView resumeLive];
}

- (void)onRefrshPraiseAndAudience
{
    [_timeView onRefrshPraiseAndAudience];
}

- (void)onClickHost
{
        
    if (_delegate && [_delegate respondsToSelector:@selector(onTopViewClickHost:host:)])
    {
        [_delegate onTopViewClickHost:self host:[_room liveHost]];
    }
}

- (void)addOwnViewsWith:(id<TCShowLiveRoomAble>)room
{
        
    _timeView = [[TCShowLiveTimeView alloc] initWith:room];
    
    if (![[[IMAPlatform sharedInstance].host imUserId] isEqualToString:[[room liveHost] imUserId]]) {
        __weak TCShowLiveTopView *ws = self;
        
        [_timeView.liveHost setClickAction:^(id<MenuAbleItem> menu) {
            [ws onClickHost];
        }];
    }
    
    [self addSubview:_timeView];
    
    _close = [[UIButton alloc] init];
    [_close setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_close addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_close];
    
#if kBetaVersion
    _roomTip = [[UILabel alloc] init];
    _roomTip.backgroundColor = [kLightGrayColor colorWithAlphaComponent:0.2];
    _roomTip.textColor = kWhiteColor;
    _roomTip.adjustsFontSizeToFitWidth = YES;
    _roomTip.font = [UIFont systemFontOfSize:9];
    [self addSubview:_roomTip];
    
    _parButton = [[UIButton alloc] init];
    [_parButton setBackgroundImage:[UIImage imageWithColor:[kLightGrayColor colorWithAlphaComponent:0.7]] forState:UIControlStateNormal];
    [_parButton setBackgroundImage:[UIImage imageWithColor:[kDarkGrayColor colorWithAlphaComponent:0.7]] forState:UIControlStateSelected];
    [_parButton addTarget:self action:@selector(onClickPar:) forControlEvents:UIControlEventTouchUpInside];
    [_parButton setTitle:@"PAR" forState:UIControlStateNormal];
    [_parButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self addSubview:_parButton];
#endif
    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.itemSize = CGSizeMake(40, 40);
//    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
//    layout.minimumInteritemSpacing = 1;
//    layout.minimumLineSpacing = 1;
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    
//    _userlist = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
//    _userlist.backgroundColor = [UIColor clearColor];
//    [_userlist registerClass:[LiveUserViewCell class] forCellWithReuseIdentifier:@"LiveUserViewCell"];
//    _userlist.delegate = self;
//    _userlist.dataSource = self;
//    _userlist.backgroundColor = [kLightGrayColor colorWithAlphaComponent:0.3];
//    [self addSubview:_userlist];
}

#if kBetaVersion
- (void)onClickPar:(UIButton *)btn
{
    _parButton.selected = !_parButton.selected;
    if ([_delegate respondsToSelector:@selector(onTopView:clickPAR:)])
    {
        [_delegate onTopView:self clickPAR:btn];
    }
}
#endif


- (void)relayoutFrameOfSubViews
{
        
    CGRect rect = self.bounds;
    [_timeView sizeWith:CGSizeMake(rect.size.width/2, 50)];
    [_timeView alignParentTopWithMargin:15];
    [_timeView alignParentLeftWithMargin:15];
    [_timeView relayoutFrameOfSubViews];
    
    [_close sizeWith:CGSizeMake(30, 30)];
    [_close alignParentTopWithMargin:15];
    [_close alignParentRightWithMargin:15];
    
//    rect.origin.y += 15 + 50;
//    rect.size.height -= 15 + 50;
//    rect = CGRectInset(rect, 0, kDefaultMargin);
//    _userlist.frame = rect;
    
    
#if kBetaVersion
    [_roomTip sameWith:_close];
    [_roomTip layoutToRightOf:_timeView margin:kDefaultMargin];
    [_roomTip scaleToLeftOf:_close margin:kDefaultMargin];
    [_roomTip scaleToBelowOf:_timeView margin:_timeView.bounds.size.height/2];
    
    [_parButton sameWith:_roomTip];
    [_parButton layoutBelow:_roomTip];
#endif
}

- (void)configOwnViewsWith:(id<TCShowLiveRoomAble>)room
{
    
#if kBetaVersion
    _roomTip.text = [NSString stringWithFormat:@"AV:%d IM:%@", [room liveAVRoomId], [room liveIMChatRoomId]];
#endif
}
@end
