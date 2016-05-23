//
//  TCShowLiveInputView.h
//  TCShow
//
//  Created by AlexiChen on 15/11/16.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShowLiveInputView : UIView<UITextFieldDelegate>
{
@protected
    UITextField     *_textField;
    
    MenuButton      *_confirmButton;
    
@protected
    BOOL            _isInputViewActive;
}

@property (nonatomic, assign) NSInteger limitLength;    // 限制长度，> 0 时有效
@property (nonatomic, copy) NSString *text;

- (void)addSendAction:(MenuAction)sendAction;

- (BOOL)isInputViewActive;

- (void)setPlacehoholder:(NSString *)placeholder;

@end
