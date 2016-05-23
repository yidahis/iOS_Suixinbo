//
//  PublishLiveViewController.h
//  TCShow
//
//  Created by AlexiChen on 15/11/23.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "ScrollViewController.h"

#import "ImageTitleButton.h"

#import "UIPlaceHolderTextView.h"

/*
 发布直播界面
 */
@interface PublishLiveViewController : BaseViewController<UITextViewDelegate>
{
@protected
    UIScrollView            *_scrollView;
    
@protected
    UIImageView             *_publishContent;   // 封面图片
    ImageTitleButton        *_lableCover;       // 封面图片浮层文字（点击添加封面）
    
@protected
    UILimitTextView         *_publishTitle;     // 发布标题编辑控件
    
@protected
    UIView                  *_locationPanel;    // 地理位置显示面板
    ImageTitleButton        *_location;         // 地理位置
    UISwitch                *_locationSwitch;   // 地理位置显示开关
    
@protected
    ImageTitleButton        *_publishBtn;               // 发布按钮
    ImageTitleButton        *_publishInteractBtn;       // 发布互动直播按钮
    BOOL                     _isPublishInteractLive;
    
@protected
    UIImage                 *_currentImage;     // 记录当前选中的图片（如果是从相机拍照获得的图片，可以保存到本地，如果是从相册获取的图片，不再保存到本地）
    
    
@protected
    BOOL                    _hasChangedImage;
    
    
}

// protected Method
- (void)onKeyboardWillShow:(NSNotification *)aNotification;

- (void)onKeyboardWillHide:(NSNotification*)aNotification;

@end
