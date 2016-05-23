//
//  TCShowLiveMessageView.m
//  TCShow
//
//  Created by AlexiChen on 16/4/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveMessageView.h"

@interface TCShowLiveMsgTableViewCell : UITableViewCell
{
    UIView                  *_msgBack;
    UILabel                 *_msgLabel;
    
    __weak TCShowLiveMsg    *_msgItem;
}

- (void)config:(TCShowLiveMsg *)item;

@end

//====================================


@implementation TCShowLiveMsgTableViewCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kClearColor;
        
        _msgBack = [[UIView alloc] init];
        _msgBack.backgroundColor = kWhiteColor;
        [self.contentView addSubview:_msgBack];
        
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.backgroundColor = kClearColor;
        _msgLabel.numberOfLines = 0;
        _msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _msgLabel.userInteractionEnabled = YES;
        [_msgBack addSubview:_msgLabel];
        
        _msgBack.layer.cornerRadius = 12;
        _msgBack.layer.masksToBounds = YES;
    }
    return self;
}


- (void)prepareForReuse
{
    _msgLabel.attributedText = nil;
}


- (void)config:(TCShowLiveMsg *)item
{
    _msgItem = item;
    _msgBack.backgroundColor = [kBlackColor colorWithAlphaComponent:0.5];
    _msgLabel.attributedText = [item avimMsgRichText];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutFrameOfSubViews];
}

- (void)relayoutFrameOfSubViews
{
    CGRect frame = self.contentView.frame;
    frame.size.width *= 0.7;
    CGSize size = _msgItem.avimMsgShowSize;
    
    CGRect rect = frame;
    rect.size.height = frame.size.height - 6;
    rect.size.width = size.width + 2 * kDefaultMargin;
    rect.origin.x += kDefaultMargin;
    _msgBack.frame = rect;
    [_msgBack layoutParentVerticalCenter];
    
    
    rect = _msgBack.bounds;
    _msgLabel.frame = CGRectInset(rect, kDefaultMargin, 0);
}

@end


//===========================================

@interface TCShowLiveMessageView ()
{
    BOOL _isScrolling;
}

@end

@implementation TCShowLiveMessageView


#define kMaxMsgCount 20

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clipsToBounds = YES;
        
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.backgroundColor = kClearColor;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
        [self addSubview:_tableView];
        
        _liveMessages = [[NSMutableArray alloc] init];
    }
    return self;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_tableView.contentSize.height > 210)
    {
        _tableView.frame = CGRectMake(0, self.bounds.size.height - 210, self.bounds.size.width, 210);
        _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.bounds.size.height);;
    }
    else
    {
        if (_tableView.frame.size.height == 0)
        {
            _tableView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0);
        }
        else
        {
            [_tableView alignParentBottom];
        }
    }
}

// 主要是上线消息
- (void)insertOnlineFrom:(id<IMUserAble>)user
{
    [self insertText:@"进来了" from:user isMsg:NO];
}
- (void)insertText:(NSString *)message from:(id<IMUserAble>)user
{
    _msgCount++;
    [self insertText:message from:user isMsg:YES];
}


#define kTableViewMaxHeigh 250

- (void)updateTableViewFrame:(CGFloat)heigt offsert:(CGFloat)scrolloff
{
    CGRect rect = _tableView.frame;
    rect.origin.y -= heigt;
    
    // 显示从(0,0.2, 0.7,1)的位置
    if (rect.size.height + heigt >= kTableViewMaxHeigh)
    {
        _tableView.frame = CGRectMake(0, self.bounds.size.height - kTableViewMaxHeigh, self.bounds.size.width, kTableViewMaxHeigh);
        
        CGPoint off = _tableView.contentOffset;
        off.y += scrolloff;
        _tableView.contentOffset = off;
    }
    else
    {
        rect.size.height += heigt;
        _tableView.frame = rect;
    }
}

- (void)insertMsg:(id<AVIMMsgAble>)item
{
    _msgCount++;
    @synchronized(_liveMessages)
    {
        CGFloat scrolloff = 0;
        [_tableView beginUpdates];
        
        if (_liveMessages.count >= kMaxMsgCount)
        {
            TCShowLiveMsg *msg = [_liveMessages objectAtIndex:0];
            scrolloff -= [TCShowLiveMsg defaultShowHeightOf:msg inSize:CGSizeMake(self.bounds.size.width, HUGE_VALF)];
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [_tableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationTop];
            [_liveMessages removeObjectAtIndex:0];
        }
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:_liveMessages.count inSection:0];
        [_tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationBottom];
        [_liveMessages addObject:item];
        
        [_tableView endUpdates];
        
        CGFloat heigt = [TCShowLiveMsg defaultShowHeightOf:item inSize:CGSizeMake(self.bounds.size.width, HUGE_VALF)];
        scrolloff += heigt;
        
        [self updateTableViewFrame:heigt offsert:scrolloff];
    }

    
}
- (void)insertText:(NSString *)message from:(id<IMUserAble>)user isMsg:(BOOL)isMsg
{
    if (!message.length)
    {
        // 空消息不发送
        return;
    }
    
    TCShowLiveMsg *item = [[TCShowLiveMsg alloc] initWith:user message:message];
    item.isMsg = isMsg;
    
    @synchronized(_liveMessages)
    {
        CGFloat scrolloff = 0;
        [_tableView beginUpdates];
        
        if (_liveMessages.count >= kMaxMsgCount)
        {
            TCShowLiveMsg *msg = [_liveMessages objectAtIndex:0];
            scrolloff -= [TCShowLiveMsg defaultShowHeightOf:msg inSize:CGSizeMake(self.bounds.size.width, HUGE_VALF)];
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [_tableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationTop];
            [_liveMessages removeObjectAtIndex:0];
        }
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:_liveMessages.count inSection:0];
        [_tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationBottom];
        [_liveMessages addObject:item];
        
        [_tableView endUpdates];
        
        CGFloat heigt = [TCShowLiveMsg defaultShowHeightOf:item inSize:CGSizeMake(self.bounds.size.width, HUGE_VALF)];
        scrolloff += heigt;
        
        [self updateTableViewFrame:heigt offsert:scrolloff];
    }
    
}

// 延迟显示
- (void)insertCachedMsg:(AVIMCache *)msgCache
{
    NSInteger msgCacheCount = [msgCache count];
    if (msgCacheCount == 0) {
        return;
    }
    
    _msgCount += msgCacheCount;
    
    CGFloat heigt = 0;
    
    NSMutableArray *items = [NSMutableArray array];
    
    
    while (msgCache.count > 0)
    {
        TCShowLiveMsg *item = [msgCache deCache];
        if (item)
        {        
            [items addObject:item];
            heigt += [TCShowLiveMsg defaultShowHeightOf:item inSize:CGSizeMake(self.bounds.size.width, HUGE_VALF)];
        }
    }
    
    
    @synchronized(_liveMessages)
    {
        CGFloat scrolloff = 0;
        if (_liveMessages.count + items.count > kMaxMsgCount)
        {
           
            NSMutableArray *idxs = [NSMutableArray array];
            NSInteger count = _liveMessages.count + items.count - kMaxMsgCount;
            NSInteger i = 0;
            while (count > 0 && _liveMessages.count)
            {
            
                TCShowLiveMsg *msg = [_liveMessages objectAtIndex:0];
                scrolloff -= [TCShowLiveMsg defaultShowHeightOf:msg inSize:CGSizeMake(self.bounds.size.width, HUGE_VALF)];
                
                [_liveMessages removeObjectAtIndex:0];
                [idxs addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                i++;
                count--;
            }
            
            if (idxs.count)
            {
                [_tableView beginUpdates];
                [_tableView deleteRowsAtIndexPaths:idxs withRowAnimation:UITableViewRowAnimationTop];
                [_tableView endUpdates];
            }
        }
        
        [_tableView beginUpdates];
        
        NSInteger count = _liveMessages.count;
        NSMutableArray *idxs = [NSMutableArray array];
        for (NSInteger i = 0; i < items.count; i++)
        {
            [_liveMessages addObject:items[i]];
            NSIndexPath *index = [NSIndexPath indexPathForRow:i+count inSection:0];
            [idxs addObject:index];
        }
        [_tableView insertRowsAtIndexPaths:idxs withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];
        
        
        scrolloff += heigt;
        
        [self updateTableViewFrame:heigt offsert:scrolloff];
    }
    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _liveMessages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCShowLiveMsg *item = [_liveMessages objectAtIndex:indexPath.row];
    return [TCShowLiveMsg defaultShowHeightOf:item inSize:CGSizeMake(self.bounds.size.width, HUGE_VALF)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCShowLiveMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCShowLiveMsgTableViewCell"];
    if (!cell)
    {
        cell = [[TCShowLiveMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TCShowLiveMsgTableViewCell"];
    }
    
    TCShowLiveMsg *item = [_liveMessages objectAtIndex:indexPath.row];
    [cell config:item];
    return cell;
}

@end

