//
//  AVIMMILayerViewController.h
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "BaseViewController.h"

// 解释直播界面中的界面层次关系

@interface AVIMMILayerViewController : BaseViewController
{
    UIView  *_livePreview;      // AVSDK渲染, 全屏
    UIView  *_liveUIView;       // 用户交互界面，全屏，透明，此处用天讲解使用UIView, 实际操作时，使用UIViewController, 使用addChildViewController添加到self.view上
    UIView  *_liveMIView;       // 有小窗口时，用于操作小窗口，透明，可放在_liveUIView上，或self.view上
}

@end
