//
//  TCShowMultiLiveView.h
//  TCShow
//
//  Created by AlexiChen on 16/4/21.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TCShowLiveView.h"




@interface TCShowMultiLiveTopView : TCShowLiveTopView
{
@protected
    // 互动连线
    ImageTitleButton *_interactButton;
    
}

@end


@interface TCShowMultiLiveView : TCShowLiveView
{
@protected
    TCShowMultiView       *_multiView;
}

@property (nonatomic, readonly) TCShowMultiView *multiView;


@end
