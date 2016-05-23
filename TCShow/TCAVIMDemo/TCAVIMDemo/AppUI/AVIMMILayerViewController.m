//
//  AVIMMILayerViewController.m
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/5/19.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AVIMMILayerViewController.h"

@implementation AVIMMILayerViewController

- (void)addOwnViews
{
    _livePreview = [[UIView alloc] initWithFrame:self.view.bounds];
    _livePreview.backgroundColor = kBlackColor;
    [self.view addSubview:_livePreview];
    
    _liveUIView = [[UIView alloc] initWithFrame:self.view.bounds];
    _liveUIView.backgroundColor = kClearColor;
    [self.view addSubview:_liveUIView];
    
    _liveMIView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 80, 120)];
    _liveMIView.backgroundColor = kBlueColor;
    [_liveUIView addSubview:_liveMIView];
}


@end
