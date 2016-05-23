//
//  TCShowLiveResultView.h
//  TCShow
//
//  Created by AlexiChen on 16/5/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShowLiveResultView : UIView
{
    UILabel             *_title;
    UILabel             *_liveTime;
    UILabel             *_liveWatch;
    UILabel             *_livePraise;
    
    MenuButton            *_back;
    
}

- (instancetype)initWith:(TCShowLiveListItem *)roomItem completion:(MenuAction)completion;

@end
