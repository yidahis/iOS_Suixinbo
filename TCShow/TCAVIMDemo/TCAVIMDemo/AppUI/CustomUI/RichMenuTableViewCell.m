//
//  RichMenuTableViewCell.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "RichMenuTableViewCell.h"

@implementation RichMenuTableViewCell


+ (NSInteger)heightOf:(RichCellMenuItem *)item inWidth:(CGFloat)width
{
    switch (item.type)
    {
        case ERichCell_Icon:
        {
            return 64;
        }
            break;
        case  ERichCell_Text:                 // 普通的显示
        {
            return kDefaultCellHeight;
        }
            break;
        case ERichCell_RichText:            // 有富文内容
        {
            CGSize size = CGSizeMake(width - (item.tipMargin + item.tipWidth + kDefaultMargin + kDefaultMargin), HUGE_VALF);
            size = [item.value textSizeIn:size font:item.valueFont];
            if (size.height < kDefaultCellHeight)
            {
                size.height = kDefaultCellHeight;
            }
            return size.height;
        }
            break;
        case ERichCell_TextNext:             // 普通的显示，有下一步
        {
            return kDefaultCellHeight;
        }
            break;
        case ERichCell_RichTextNext:         // 有富文内容，有下一步
        {
            CGSize size = CGSizeMake(width - (item.tipMargin + item.tipWidth + kDefaultMargin  - 64/*》到边界的距*/), HUGE_VALF);
            size = [item.value textSizeIn:size font:item.valueFont];
            if (size.height < kDefaultCellHeight)
            {
                size.height = kDefaultCellHeight;
            }
            return size.height;
        }
            break;
        case ERichCell_Switch:               // 需要编辑:
        {
            return kDefaultCellHeight;
        }
            
            break;
        case ERichCell_Member:               // 需要编辑:
        {
            return kDefaultCellHeight;
        }
            
            break;
        case ERichCell_MemberPanel:               // 需要编辑:
        {
            return 70;
        }
            
            break;
            
        default:
        {
            return kDefaultCellHeight;
        }
            break;
    }
    return kDefaultCellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _tip = [[UILabel alloc] init];
        _tip.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_tip];
        
        _value = [[UILabel alloc] init];
        _value.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_value];
        
        if ([reuseIdentifier isEqualToString:[RichCellMenuItem reuseIndentifierOf:ERichCell_Switch]])
        {
            _onSwitch = [[UISwitch alloc] init];
            [_onSwitch addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            self.accessoryView = _onSwitch;
        }
        else if ([reuseIdentifier isEqualToString:[RichCellMenuItem reuseIndentifierOf:ERichCell_Icon]])
        {
            _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
            _icon.layer.cornerRadius = 24;
            self.accessoryView = _icon;
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)onSwitchChanged:(UISwitch *)sw
{
    sw.on = !sw.on;
    if (_item.action)
    {
        _item.action(_item, self);
    }
}

- (void)configWith:(RichCellMenuItem *)item
{
    _item = item;
    
    _tip.text = item.tip;
    _tip.textColor = item.tipColor;
    _tip.font = item.tipFont;
    
    _value.text = item.value;
    _value.textColor = item.valueColor;
    _value.font = item.valueFont;
    
    BOOL isRichText = item.type == ERichCell_RichText || item.type == ERichCell_RichTextNext;
    BOOL isMem = item.type == ERichCell_Member;
    _value.textAlignment = isMem ? NSTextAlignmentRight : item.valueAlignment;
    _value.numberOfLines = isRichText ? 0 : 1;
    _value.lineBreakMode = isRichText ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail;
    
    switch (item.type)
    {
        case ERichCell_Icon:
        {
            self.accessoryType = UITableViewCellAccessoryNone;
            [_icon sd_setImageWithURL:[NSURL URLWithString:item.value] placeholderImage:kDefaultUserIcon];
            _value.text = nil;
        }
            break;
        case ERichCell_Text:                 // 普通的显示
        {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case ERichCell_RichText:            // 有富文内容
        {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case ERichCell_TextNext:             // 普通的显示，有下一步
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case ERichCell_RichTextNext:         // 有富文内容，有下一步
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case ERichCell_Member:
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case ERichCell_Switch:
        {
            _onSwitch.on = item.switchValue;
        }
            break;
            
        default:
            break;
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
    [_tip sizeWith:CGSizeMake(_item.tipWidth, rect.size.height)];
    [_tip alignParentLeftWithMargin:_item.tipMargin];
    
    [_value sameWith:_tip];
    [_value layoutToRightOf:_tip margin:kDefaultMargin];
    [_value scaleToParentRightWithMargin:kDefaultMargin];
}

@end
