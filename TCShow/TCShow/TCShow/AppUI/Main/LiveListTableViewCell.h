//
//  LiveListTableViewCell.h
//  TCShow
//
//  Created by AlexiChen on 16/4/13.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveListTableViewCell : UITableViewCell
{
@protected
    
    UIImageView     *_liveCover;
    UIButton        *_liveType;
    
    UIView          *_liveHostView;
    
    UIButton        *_liveHost;
    
    UILabel         *_liveTitle;
    UILabel         *_liveHostName;
    
    ImageTitleButton    *_liveAudience;
    ImageTitleButton    *_livePraise;
    
@protected
    __weak id<TCShowLiveRoomAble> _liveItem;
}

- (void)configWith:(id<TCShowLiveRoomAble>)item;


@end
