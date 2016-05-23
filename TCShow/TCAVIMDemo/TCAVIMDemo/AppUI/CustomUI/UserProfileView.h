//
//  UserProfileView.h
//  TCShow
//
//  Created by AlexiChen on 16/5/12.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileView : UIView
{
@protected
    
    UIView              *_backView;
@protected
    UIView              *_contentView;
    
    UIImageView         *_icon;
    UILabel             *_name;
    UIButton            *_report;
    UILabel             *_signature;
    UILabel             *_desc;
    
    UIButton            *_focus;
    
@protected
    TIMUserProfile      *_showUser;
}

- (void)showUser:(id<IMUserAble>)user;



@end
