//
//  ReportHostView.h
//  TCShow
//
//  Created by AlexiChen on 16/5/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportHostView : UIView
{
@protected
    UIView  *_backView;
    UIView  *_contentView;
    
@protected
    UILabel     *_title;
    UIButton    *_ad;
    UIButton    *_fake;
    UIButton    *_harm;
    UIButton    *_illegal;
    UIButton    *_obscene;
    
    UIButton    *_cancel;
    
}

- (void)showUser:(id<IMUserAble>)user;
@end
