//
//  TCShowSettingBeautyView.h
//  live
//
//  Created by AlexiChen on 16/2/25.
//  Copyright © 2016年 kenneth. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^TCShowSettingBeautyChanged)(CGFloat beauty);

@interface TCShowSettingBeautyView : UIView
{
@protected
    UIView   *_clearBg;
    UIView   *_sliderBack;
    UISlider *_slider;
}

@property (nonatomic, readonly) UISlider *slider;


@property (nonatomic, copy) TCShowSettingBeautyChanged changeCompletion;

- (void)setBeauty:(CGFloat)beauty;

@end
