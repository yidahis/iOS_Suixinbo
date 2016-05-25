//
//  PublishLiveViewController.m
//  TCShow
//
//  Created by AlexiChen on 15/11/23.
//  Copyright © 2015年 AlexiChen. All rights reserved.
//

#import "PublishLiveViewController.h"

@implementation PublishLiveViewController

// 本地保存的通信息

//#define kShowLocationOnPublish                  @"kShowLocationOnPublish"

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.title = @"发布直播";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBlank:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    [self registerKeyBoardNotification];
    
    TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
    _locationSwitch.on = host.showLocation;
    [self onTurnLoc:_locationSwitch];
    
    [self loadLiveCover];
}

- (void)loadLiveCover
{
    TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
    NSString *liveCover = [host liveCover];
    if (liveCover)
    {
        [_publishContent sd_setImageWithURL:[NSURL URLWithString:liveCover] placeholderImage:nil];
        _lableCover.hidden = YES;
    }
}


- (void)onClose:(UIButton *)btn
{
    [_publishTitle resignFirstResponder];
    
    [[AppDelegate sharedAppDelegate] dismissViewController:self animated:YES completion:nil];
}

#pragma mark - 上传图片
- (void)uploadImage
{
    if (!_publishContent.image)
    {
        [_publishContent shake];
        return;
    }
    
    if (_publishTitle.text.length == 0)
    {
        [_publishTitle shake];
        return;
    }
    _publishBtn.enabled = NO;
    _publishInteractBtn.enabled = NO;
    __weak PublishLiveViewController *ws = self;
    __weak UIButton *wp = _publishBtn;
    __weak UIButton *wpi = _publishInteractBtn;
    DebugLog(@"-----主播>>>>>开始上传图片");
    [[UploadImageHelper shareInstance] upload:_publishContent.image completion:^(NSString *imageSaveUrl) {
        DebugLog(@"-----主播>>>>>上传图片成功，进入直播界面");
        //保存到相册
        TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
        host.liveCover = imageSaveUrl;
        [ws startLive];
        wp.enabled = YES;
        wpi.enabled = YES;
    } failed:^(NSString *failTip) {
        DebugLog(@"-----主播>>>>>上传图片失败");
        wp.enabled = YES;
        wpi.enabled = YES;
        [[HUDHelper sharedInstance] tipMessage:failTip];
        
        [ws startLive];
    }];
}

#pragma mark - 发布

- (void)onPublishInteract
{
    _isPublishInteractLive = YES;
    [self onPublish];
}

- (void)onPublish
{
    if (![IMAPlatform sharedInstance].isConnected)
    {
        [HUDHelper alert:@"当前无网络"];
        return;
    }
    
    
#if DEBUG
    
    //    IMAHost *host = [IMAPlatform sharedInstance].host;
    //
    //    TCShowLiveListItem *item = [[TCShowLiveListItem alloc] init];
    //    item.host = host;
    //    item.title = @"测试直播";
    //    item.cover = [item.host imUserIconUrl];
    //    item.avRoomId = 10000;
    //    item.chatRoomId = @"400000";
    //    TCShowLiveViewController *vc = [[TCShowLiveViewController alloc] initWith:item user:host];
    //    [[AppDelegate sharedAppDelegate] pushViewController:vc];
    //    return;
    if (_publishContent.image && _publishTitle.text.length)
    {
        [self uploadImage];
    }
    else
    {
        TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
        if (host.avRoomId == 0)
        {
            __weak PublishLiveViewController *ws = self;
            LiveAVRoomIDRequest *req = [[LiveAVRoomIDRequest alloc] initWithHandler:^(BaseRequest *request) {
                LiveAVRoomIDResponseData *data = (LiveAVRoomIDResponseData *)request.response.data;
                host.avRoomId = data.avRoomId;
                
                [ws startLive];
            } failHandler:^(BaseRequest *request) {
                DebugLog(@"请求RoomID出错");
            }];
            req.uid = [host imUserId];
            [[WebServiceEngine sharedEngine] asyncRequest:req wait:NO];
        }
        else
        {
            [self startLive];
        }
        
    }
#else
    // 需要授权
    [self uploadImage];
#endif
}

- (void)startLive
{
    TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
    NSString *liveCover = [host liveCover];
    
    TCShowLiveListItem *liveRoom = [[TCShowLiveListItem alloc] init];
    if (_publishTitle.text.length)
    {
        liveRoom.title = _publishTitle.text;
    }
    else
    {
#if DEBUG
        liveRoom.title = [NSString stringWithFormat:@"%@ Live", [host imUserName]];
#endif
    }
    liveRoom.cover = liveCover;
    
    TCShowUser *user = [[TCShowUser alloc] init];
    user.avatar = [host imUserIconUrl];
    user.uid = [host imUserId];
    user.username = [host imUserName];
    
    liveRoom.host = user;
    liveRoom.avRoomId = [host avRoomId];
    
    LocationItem *lbs = host.lbsInfo;
    if (lbs && _locationSwitch.on)
    {
        liveRoom.lbs = lbs;
    }
    
    if (_isPublishInteractLive)
    {
        TCShowMultiLiveViewController *vc = [[TCShowMultiLiveViewController alloc] initWith:liveRoom user:host];
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }
    else
    {
        TCShowLiveViewController *vc = [[TCShowLiveViewController alloc] initWith:liveRoom user:host];
        [[AppDelegate sharedAppDelegate] pushViewController:vc];
    }
    
    
    
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    return [_publishTitle shouldChangeTextInRange:range replacementText:text];
//}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    _scrollView.contentOffset = CGPointMake(0, 0);
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_publishTitle updateLimitText];
}

#pragma mark - reg & unreg notification

- (void)registerKeyBoardNotification
{
    if ([IOSDeviceConfig sharedConfig].isIPhone4)
    {
        //添加键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)onKeyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (kbSize.height > _publishTitle.frame.origin.y)
    {
        kbSize.height = _publishTitle.frame.origin.y - _publishTitle.frame.size.height;
    }
    _scrollView.contentOffset = CGPointMake(0, kbSize.height);
    _scrollView.scrollEnabled = NO;
}

- (void)onKeyboardWillHide:(NSNotification*)aNotification
{
    _scrollView.contentOffset = CGPointMake(0, 0);
    _scrollView.scrollEnabled = YES;
}

- (void)addPublishContent
{
    _publishContent = [[UIImageView alloc] init];
    _publishContent.backgroundColor = kLightGrayColor;
    
    _lableCover = [[ImageTitleButton alloc] initWithStyle:EImageTopTitleBottom];
    [_lableCover setImage:[UIImage imageNamed:@"publishcover"] forState:UIControlStateNormal];
    [_lableCover setImage:[UIImage imageNamed:@"publishcover_hover"] forState:UIControlStateHighlighted];
    [_lableCover setTitle:@"给你的直播设置一个满意的封面" forState:UIControlStateNormal];
    _lableCover.titleLabel.font = kAppMiddleTextFont;
    _lableCover.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_lableCover setTitleColor:[kWhiteColor colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [_lableCover addTarget:self action:@selector(onLoadPublishLiveCover) forControlEvents:UIControlEventTouchUpInside];
    [_publishContent addSubview:_lableCover];
    [_scrollView addSubview:_publishContent];
    
    _publishContent.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPublishContent:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_publishContent addGestureRecognizer:tap];
}

- (void)onClickBlank:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [_publishTitle resignFirstResponder];
    }
}

- (void)onClickPublishContent:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [self onLoadPublishLiveCover];
    }
}

- (void)onLoadPublishLiveCover
{
    if ([_publishTitle isFirstResponder])
    {
        [_publishTitle resignFirstResponder];
        return;
    }
    [self callImagePickerActionSheet];
}

- (void)addOwnViews
{
    _scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_scrollView];
    
    [self addPublishContent];
    
    _publishTitle = [[UILimitTextView alloc] init];
    _publishTitle.textColor = kBlackColor;
    _publishTitle.placeHolder = @"请输入直播标题";
#if DEBUG
    _publishTitle.text =[NSString stringWithFormat:@"%@ Live", [[IMAPlatform sharedInstance].host imUserName]];
#endif
    [_publishTitle setFont:kAppMiddleTextFont];
    _publishTitle.delegate = self;
    _publishTitle.placeHolderColor = kLightGrayColor;
    _publishTitle.mainTextColor = kBlackColor;
    _publishTitle.layer.borderWidth = 1.0;
    _publishTitle.layer.borderColor = [kBlackColor colorWithAlphaComponent:0.1].CGColor;
    _publishTitle.limitLength = 32;
    [_scrollView addSubview:_publishTitle];
    
    _locationPanel = [[UIView alloc] init];
    _locationPanel.backgroundColor = kWhiteColor;
    _locationPanel.layer.borderWidth = 1.0;
    _locationPanel.layer.borderColor = [kBlackColor colorWithAlphaComponent:0.1].CGColor;
    [_scrollView addSubview:_locationPanel];
    
    _location = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightLeft];
    [_location setImage:[UIImage imageNamed:@"position_gray"] forState:UIControlStateNormal];
    [_location setImage:[UIImage imageNamed:@"position_red"] forState:UIControlStateSelected];
    [_location setTitle:@"不显示位置" forState:UIControlStateNormal];
    [_location setTitleColor:kLightGrayColor forState:UIControlStateNormal];
    _location.titleLabel.font = kAppMiddleTextFont;
    [_locationPanel addSubview:_location];
    
    _locationSwitch = [[UISwitch alloc] init];
    [_locationSwitch addTarget:self action:@selector(onTurnLoc:) forControlEvents:UIControlEventValueChanged];
    [_locationPanel addSubview:_locationSwitch];
    
    _publishBtn = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    [_publishBtn addTarget:self action:@selector(onPublish) forControlEvents:UIControlEventTouchUpInside];
    _publishBtn.backgroundColor = RGBOF(0XDC4B53);
    [_publishBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [_publishBtn.titleLabel setFont:kAppMiddleTextFont];
    [_publishBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    _publishBtn.layer.cornerRadius = 6;
    _publishBtn.layer.masksToBounds = YES;
    [self.view addSubview:_publishBtn];
    
    _publishInteractBtn = [[ImageTitleButton alloc] initWithStyle:EImageLeftTitleRightCenter];
    [_publishInteractBtn addTarget:self action:@selector(onPublishInteract) forControlEvents:UIControlEventTouchUpInside];
    _publishInteractBtn.backgroundColor = RGBOF(0XDC4B53);
    [_publishInteractBtn setTitle:@"开始互动直播" forState:UIControlStateNormal];
    [_publishInteractBtn.titleLabel setFont:kAppMiddleTextFont];
    [_publishInteractBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
#if kAppStoreVersion
#else
#if DEBUG
    _publishInteractBtn.layer.cornerRadius = 6;
    _publishInteractBtn.layer.masksToBounds = YES;
#else
#endif
#endif
    [self.view addSubview:_publishInteractBtn];
    
}


- (void)onTurnLoc:(UISwitch *)sw
{
    TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
    host.showLocation = sw.on;
    if (sw.on)
    {
        NSString *address = host.lbsInfo.address;
        if (address == nil)
        {
            [host startLbs];
            [_location setTitle:@"正在定位" forState:UIControlStateNormal];
            [_location setTitleColor:kBlackColor forState:UIControlStateNormal];
            _location.selected = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetAddressSucc) name:kTCShow_LocationSuccNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetAddressFail) name:kTCShow_LocationFailNotification object:nil];
        }
        else
        {
            [_location setTitle:address forState:UIControlStateNormal];
            [_location setTitleColor:kBlackColor forState:UIControlStateNormal];
            _location.selected = YES;
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCShow_LocationSuccNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCShow_LocationFailNotification object:nil];
        
        [_location setTitle:@"不显示位置" forState:UIControlStateNormal];
        [_location setTitleColor:kLightGrayColor forState:UIControlStateNormal];
        _location.selected = NO;
    }
}

- (void)onGetAddressSucc
{
    if (_locationSwitch.on)
    {
        TCShowHost *host = (TCShowHost *)[IMAPlatform sharedInstance].host;
        NSString *address = host.lbsInfo.address;
        if (address)
        {
            [_location setTitle:address forState:UIControlStateNormal];
            [_location setTitleColor:kBlackColor forState:UIControlStateNormal];
            _location.selected = YES;
        }
        
    }
    else
    {
        [_location setTitle:@"不显示位置" forState:UIControlStateNormal];
        [_location setTitleColor:kLightGrayColor forState:UIControlStateNormal];
        _location.selected = NO;
    }
}

- (void)onGetAddressFail
{
    if (_locationSwitch.on)
    {
        NSString *address = @"获取位置失败";
        
        [_location setTitle:address forState:UIControlStateNormal];
        [_location setTitleColor:kBlackColor forState:UIControlStateNormal];
        _location.selected = YES;
    }
    else
    {
        [_location setTitle:@"不显示位置" forState:UIControlStateNormal];
        [_location setTitleColor:kGrayColor forState:UIControlStateNormal];
        _location.selected = NO;
    }
}

- (CGSize)publishSize
{
    return CGSizeMake(_scrollView.bounds.size.width, (NSInteger)(_scrollView.bounds.size.width * 0.618));
}

- (void)layoutOnIPhone
{
    [_scrollView sizeWith:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - 60)];
    
#if kAppStoreVersion
    [_publishInteractBtn sizeWith:CGSizeMake(self.view.bounds.size.width, 60)];
    [_publishInteractBtn alignParentBottom];
#else
#if DEBUG
    [_publishBtn sizeWith:CGSizeMake((self.view.bounds.size.width - 3 * kDefaultMargin)/2, 44)];
    [_publishBtn alignParentBottomWithMargin:kDefaultMargin];
    [_publishBtn alignParentLeftWithMargin:kDefaultMargin];
    
    [_publishInteractBtn sameWith:_publishBtn];
    [_publishInteractBtn layoutToRightOf:_publishBtn margin:kDefaultMargin];
#else
    [_publishInteractBtn sizeWith:CGSizeMake(self.view.bounds.size.width, 60)];
    [_publishInteractBtn alignParentBottom];
#endif
    
#endif
    
    
    CGSize pubSize = [self publishSize];
    [_publishContent sizeWith:pubSize];
    if (_lableCover)
    {
        NSInteger off = (pubSize.height - 120)/2;
        _lableCover.margin = UIEdgeInsetsMake(off, 0, off, 0);
        [_lableCover sizeWith:[self publishSize]];
        [_lableCover alignParentCenter];
    }
    
    
    [_publishTitle sizeWith:CGSizeMake(_scrollView.bounds.size.width, 100)];
    [_publishTitle layoutBelow:_publishContent margin:0];
    
    [_locationPanel sizeWith:CGSizeMake(_scrollView.bounds.size.width, 50)];
    [_locationPanel layoutBelow:_publishTitle margin:-1];                 //-1是为了让边缘重合
    
    [_locationSwitch sizeWith:CGSizeMake(100, 24)];
    [_locationSwitch alignParentRight];
    [_locationSwitch alignParentRightWithMargin:kDefaultMargin];
    [_locationSwitch layoutParentVerticalCenter];
    
    [_location sizeWith:CGSizeMake(80, 24)];
    [_location alignParentLeftWithMargin:kDefaultMargin];
    [_location scaleToLeftOf:_locationSwitch margin:kDefaultMargin];
    [_location layoutParentVerticalCenter];
    
    CGRect rect = _location.frame;
    if (rect.origin.y + rect.size.height + kDefaultMargin > _scrollView.bounds.size.height)
    {
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, rect.origin.y + rect.size.height + kDefaultMargin);
        [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentSize.height - _scrollView.bounds.size.height)];//将发布按钮显示出来
    }
    else
    {
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 0);
    }
}


#pragma mark - 打开相机或相册
- (void)openImageActionSheet
{
    __weak typeof(self) ws = self;
    UIActionSheet *testSheet = [[UIActionSheet alloc] init];//[UIActionSheet bk_actionSheetWithTitle:@"请选择照片源"];
    [testSheet bk_addButtonWithTitle:@"拍照" handler:^{
        [ws openCamera];
    }];
    [testSheet bk_addButtonWithTitle:@"相册" handler:^{
        [ws openPhotoLibrary];
    }];
    [testSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [testSheet showInView:self.view];
}

- (void)openCamera
{
    // 暂时弃用自定义相机
    // 打开系统相机拍照
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:@"您没有相机使用权限,请到设置->隐私中开启权限" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        [alert show];
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *cameraIPC = [[UIImagePickerController alloc] init];
        cameraIPC.delegate = self;
        cameraIPC.allowsEditing = YES;
        cameraIPC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:cameraIPC animated:YES completion:nil];
        return;
    }
}

- (void)openPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    UIImage *cutImage = [self cutImage:image];
    _publishContent.image = cutImage;
    [_lableCover removeFromSuperview];
    _lableCover = nil;
    
    //如果是相机拍照，则保存到相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        _currentImage = cutImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 图片剪裁
- (UIImage *)cutImage:(UIImage *)image
{
    CGSize pubSize = [self publishSize];
    if (image)
    {
        CGSize imgSize = image.size;
        CGFloat pubRation = pubSize.height / pubSize.width;
        CGFloat imgRatio = imgSize.height / imgSize.width;
        if (fabs(imgRatio -  pubRation) < 0.01)
        {
            // 直接上传
            return image;
        }
        else
        {
            if (imgRatio > 1)
            {
                // 长图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.width, (NSInteger)(imgSize.width * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake(0, (image.size.height - upSize.height)/2, upSize.width, upSize.height)];
                return upimg;
            }
            else
            {
                // 宽图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.height, (NSInteger)(imgSize.height * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake((image.size.width - upSize.width)/2, 0, upSize.width, upSize.height)];
                return upimg;
            }
        }
    }
    
    return image;
}

- (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [image drawInRect:drawRect];
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}


@end
