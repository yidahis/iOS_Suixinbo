//
//  RichMenuTableViewCell.h
//  TIMChat
//
//  Created by AlexiChen on 16/3/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RichMenuTableViewCell : UITableViewCell
{
@protected
    UILabel     *_tip;
    UILabel     *_value;
    
@protected
    UISwitch    *_onSwitch;
    
@protected
    UIImageView *_icon;
    
@protected
    __weak RichCellMenuItem *_item;
}

@property (nonatomic, weak) RichCellMenuItem *item;
@property (nonatomic, readonly) UISwitch *onSwitch;


+ (NSInteger)heightOf:(RichCellMenuItem *)item inWidth:(CGFloat)width;
- (void)configWith:(RichCellMenuItem *)item;


@end
