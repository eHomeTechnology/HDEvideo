//
//  SNMainViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-18.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNMainViewCtr.h"
#import "HDUtility.h"
#import "SNWIFIInfo.h"
#import "SNAddDeviceViewCtr.h"
#import "SNMyInfoViewCtr.h"
#import "SNDeviceViewCtr.h"
#import "PlayViedo.h"
#import "SNGuideViewCtr.h"
#import "SNPageControl.h"
#import "UDTUtility.h"

static BOOL hasShowed3GPrompt = NO;

@interface SNMainViewCtr ()<UIScrollViewDelegate>{
    SNAddDeviceViewCtr      *addDeviceViewCtr;
    SNDeviceViewCtr         *dvc_playing;               //当前播放的对应的SNDeviceViewCtr对象
    PlayViedo               *videoCtr;
    IBOutlet UIScrollView   *v_scroll;
    IBOutlet UIView         *v_play;
    IBOutlet UIView         *v_rightNavBar;
    IBOutlet UIButton       *btn_userHead;
    IBOutlet UILabel        *lb_userName;
    IBOutlet SNPageControl  *pageCtr;
    IBOutlet UILabel        *lb_noCamera;
    IBOutlet UILabel        *lb_playingDeviceName;
    IBOutlet UIView         *v_record;
    IBOutlet UIImageView    *imv_isBelongOther;
    IBOutlet UIView         *v_sideBar;
    IBOutlet UIButton       *btn_add;
    IBOutlet UIImageView    *imv_playFlag;
    HDBlurView              *blurView;
    SNUserInfo              *userInfo;
    SNGuideViewCtr          *guideViewCtr;
    MBProgressHUD           *HUD_play;
    int                     iTryPlayCount;              //尝试播放次数
    int                     iCount;                     //点击播放界面背景，显示菜单的时候计时用
    UIImageView             *imv_animate;
    NSTimer                 *timer;
}

@property (strong) Reachability *hostReachability;

@end

@implementation SNMainViewCtr

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name:@KEY_NOTI_EXIT_FULL_SCREEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryPlay:) name:@KEY_NOTI_MAIN_PLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ffmpegNotificationAction:) name:@NSNOTICE_FFMPEG_PLAYSTATUS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDeviceView) name:@KEY_NOTI_MAIN_HEART_REFRESH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDeviceView) name:@KEY_NOTI_MAIN_VIEW_REFRESH object:nil
     ];
    NSLog(@"iOS = %f", IOS_VERSION);
    pageCtr.frame = CGRectMake(CGRectGetMinX(pageCtr.frame), CGRectGetMinY(pageCtr.frame)-(IS_4INCH_SCREEN? 0: 85), CGRectGetWidth(pageCtr.frame), CGRectGetHeight(pageCtr.frame));
    pageCtr.imageRect = CGRectMake(0, 0, 10, 2);
    lb_playingDeviceName.text               = @"未选中摄像头";
    self.view.backgroundColor               = [UIColor colorWithPatternImage:[UIImage imageNamed:@"color_gray.jpg"]];
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    }else{
        UIButton *btn_back  = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame      = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"nav_bar.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:v_rightNavBar];
    btn_userHead.layer.cornerRadius         = btn_userHead.frame.size.height/2;
    btn_userHead.layer.borderWidth          = 1.0f;
    btn_userHead.layer.borderColor          = [UIColor whiteColor].CGColor;
    btn_userHead.layer.masksToBounds        = YES;
    userInfo                                = [SNGlobalInfo instance].userInfo;
    if (userInfo.mar_camera.count > 0) {
        lb_noCamera.text = @"请点击下方您想要查看的摄像头";
    }
    
    if (!IS_4INCH_SCREEN) {
        btn_add.center = CGPointMake(btn_add.center.x, btn_add.center.y - 88);
    }
    [NSThread detachNewThreadSelector:@selector(downLoadImage) toTarget:self withObject:nil];
    v_sideBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    NSString *sHeadPath = [SNGlobalInfo instance].userInfo.sHeadPath;
    if (sHeadPath.length > 0) {
        [btn_userHead setImage:[UIImage imageWithContentsOfFile:sHeadPath] forState:UIControlStateNormal];
    }
    lb_userName.text = [SNGlobalInfo instance].userInfo.sUserName;
    [self refreshDeviceView];
    Dlog(@"userInfo = %@", [SNGlobalInfo instance].userInfo);
}
- (void)viewDidDisappear:(BOOL)animated{
    [self removePlayingView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - self method

- (void)showMenu:(id)sender{
    [self.navigationController.sideMenuViewController presentLeftMenuViewController];
}
- (void)refreshUserHead{
    userInfo = [SNGlobalInfo instance].userInfo;
    if (userInfo.sHeadPath.length > 0) {
        [btn_userHead setImage:[UIImage imageWithContentsOfFile:userInfo.sHeadPath] forState:UIControlStateNormal];
    }
}
- (void)refreshDeviceImage:(id)sender{
    userInfo = [SNGlobalInfo instance].userInfo;
    for (int i = 0; i < userInfo.mar_camera.count; i++) {
        SNCameraInfo *cInfo = userInfo.mar_camera[i];
        if (cInfo.sPhotoPath.length == 0) {
            continue;
        }
        UIImage *img = [UIImage imageWithContentsOfFile:cInfo.sPhotoPath];
        for (int j = 0; j < self.childViewControllers.count; j++) {
            SNDeviceViewCtr *ctr = (SNDeviceViewCtr *)self.childViewControllers[j];
            if ([ctr.cameraInfo.sDeviceId isEqualToString:cInfo.sDeviceId]) {
                [ctr.imv_screen setImage:img];
            }
        }
        
    }
    if (imv_animate) {
        [imv_animate setImage:dvc_playing.imv_screen.image];
    }
}
- (void)refreshDeviceView{
    Dlog(@"userInfo = %@", [SNGlobalInfo instance].userInfo);
    /*先清除上次new的对象*/
    for (UIView *v in v_scroll.subviews) {
        [v removeFromSuperview];
    }
    for (UIViewController *ctr in self.childViewControllers) {
        [ctr removeFromParentViewController];
    }
    /*重绘*/
    int iDefault                = IS_4INCH_SCREEN? 4: 2;
    userInfo                    = [SNGlobalInfo instance].userInfo;
    int iCountOfView            = userInfo.mar_camera.count > iDefault? (int)userInfo.mar_camera.count: iDefault;
    v_scroll.contentSize        = CGSizeMake(v_scroll.frame.size.width*(iCountOfView/(iDefault+1) + 1), v_scroll.frame.size.height);
    pageCtr.numberOfPages       = iCountOfView/(iDefault+1) + 1;
    pageCtr.currentPage         = 0;
    pageCtr.hidesForSinglePage  = NO;
    for (int i = 0; i < iCountOfView; i++) {
        SNDeviceViewCtr *ctr    = [[SNDeviceViewCtr alloc] init];
        ctr.view.frame          = CGRectMake(15+(i/iDefault)*v_scroll.frame.size.width + (i%2)*160, 100*((i%iDefault)/2)+(IS_4INCH_SCREEN? 0: 10), ctr.view.frame.size.width, ctr.view.frame.size.height);
        [self addChildViewController:ctr];
        [v_scroll addSubview:ctr.view];
    }
    for (int i = 0; i < userInfo.mar_camera.count; i++) {
        SNCameraInfo *info      = userInfo.mar_camera[i];
        if ([info.sDeviceId isEqualToString:dvc_playing.cameraInfo.sDeviceId] && info.lineStatus == SNCameraLineStatusOff) {
            [self removePlayingView];
        }
        if (i >= self.childViewControllers.count) {
            Dlog(@"错误：i大于子controller的数量");
            return;
        }
        SNDeviceViewCtr *ctr    = (SNDeviceViewCtr *)self.childViewControllers[i];
        if (info) {
            ctr.cameraInfo = info;
            [ctr refreshView];
        }
    }
}

#pragma - SEL
- (IBAction)doAddDevice:(id)sender{
    if (!blurView) {
        blurView        = [[HDBlurView alloc] initWithFrame:kWindow.frame];
    }
    [self.navigationController.view addSubview:blurView];
    addDeviceViewCtr    = [[SNAddDeviceViewCtr alloc] init];
    [HDUtility showView:addDeviceViewCtr.view centerAtPoint:kWindow.center duration:0.3];
    [kWindow addSubview:addDeviceViewCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAddDeviceCancel:) name:@KEY_NOTI_ADD_DEVICE_CANCEL object:nil];
}
- (void)doAddDeviceCancel:(NSString *)s{
    Dlog(@"s = %@", s);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_ADD_DEVICE_CANCEL object:nil];
    [addDeviceViewCtr.view removeFromSuperview];
    [blurView removeFromSuperview];
    addDeviceViewCtr    = nil;
    blurView            = nil;
}

- (IBAction)doShowProfile:(id)sender{
    if ([SNGlobalInfo instance].userInfo.registerType == SNRegisterTypeImei) {
        blurView            = [[HDBlurView alloc] initWithFrame:kWindow.frame];
        guideViewCtr        = [[SNGuideViewCtr alloc] init];
        [HDUtility showView:guideViewCtr.view centerAtPoint:kWindow.center duration:ANIMATION_DURATION];
        [kWindow addSubview:blurView];
        [kWindow addSubview:guideViewCtr.view];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doGuideViewCancel) name:@KEY_NOTI_GUIDE_VIEW object:nil];
        return;
    }
    SNMyInfoViewCtr *myInfoViewCtr = [[SNMyInfoViewCtr alloc] init];
    [self.navigationController pushViewController:myInfoViewCtr animated:YES];
}

- (IBAction)doRecord:(id)sender{
    if (videoCtr != nil) {
        
    }
}

- (IBAction)doScreenshot:(id)sender{
    if (videoCtr != nil) {
        [videoCtr screenshotButtonAction:nil];
    }
}

- (IBAction)doFullScreen:(id)sender{
    if (videoCtr != nil) {
        [videoCtr turnToLeft];
        videoCtr.view.frame = [UIApplication sharedApplication].keyWindow.frame;
        [[UIApplication sharedApplication].keyWindow addSubview:videoCtr.view];
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)removePlayingView{
    lb_playingDeviceName.text   = @"未选中摄像头";
    imv_playFlag.hidden         = YES;
    for (UIView *v in v_play.subviews) {
        [v removeFromSuperview];
    }
    [imv_animate removeFromSuperview];
    imv_animate                 = nil;
    dvc_playing.v_statusBack.backgroundColor = COLOR_MENU_DARK;
    dvc_playing                 = nil;
    [videoCtr stopStreaming];
    [HUD_play hide:YES];
}

- (void)tryPlay:(NSNotification *)noti{
    NSDictionary *dic           = noti.userInfo;
    SNDeviceViewCtr *ctr        = dic[@"device"];
    /*如果在播放中，返回，无操作*/
    BOOL isTouchCameraPlaying   = [dvc_playing.cameraInfo.sDeviceId isEqualToString:ctr.cameraInfo.sDeviceId] && imv_playFlag.hidden == NO;
    if (isTouchCameraPlaying) {
        return;
    }
    imv_animate                 = [[UIImageView alloc] initWithFrame:CGRectZero];
    imv_animate.hidden          = NO;
    imv_animate.image           = ctr.imv_screen.image;
    imv_playFlag.hidden         = NO;
    imv_animate.frame           = CGRectMake(CGRectGetMinX(v_scroll.frame)+(int)CGRectGetMinX(ctr.view.frame)%320, CGRectGetMinY(v_scroll.frame)+CGRectGetMinY(ctr.view.frame), CGRectGetWidth(ctr.imv_screen.frame), CGRectGetHeight(ctr.imv_screen.frame));
    [self.view addSubview:imv_animate];
    [UIView animateWithDuration:0.3 animations:^{
        imv_animate.frame = CGRectMake(19, 44, 282, 159);
    } completion:^(BOOL finished) {
        HUD_play = [[MBProgressHUD alloc] initWithWindow:kWindow];
        HUD_play.labelText = @"网络请求中...";
        [kWindow addSubview:HUD_play];
        [HUD_play show:YES];
        if ([HDUtility isEnable3G] && !hasShowed3GPrompt) {
            [HDUtility say:@"您当前正使用3G网络！"];
            hasShowed3GPrompt = YES;
        }
        lb_playingDeviceName.text   = ctr.cameraInfo.sDeviceName;
        imv_isBelongOther.hidden    = !ctr.cameraInfo.isBelongOther;
        if (dvc_playing) {
            dvc_playing.v_statusBack.backgroundColor = COLOR_MENU_DARK;
            dvc_playing = nil;
        }
        dvc_playing = ctr;
        dvc_playing.v_statusBack.backgroundColor = COLOR_MENU_LIGHT;
        Dlog(@"ctr.sDeviceName = %@", ctr.cameraInfo.sDeviceName);
        if (ctr.cameraInfo) {
            v_play.hidden = NO;
            iTryPlayCount = 0;
            [NSThread detachNewThreadSelector:@selector(UDTConnect:) toTarget:self withObject:ctr];
        }
    }];
}

- (void)UDTConnect:(SNDeviceViewCtr *)ctr{
    SNServerInfo *sInfo     = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
    /*协议02，请求打开摄像头*/
    NSDictionary *dc_02     = [UDTUtility tellServer2TurnOnCamera:ctr.cameraInfo.sDeviceId
                                                         serverIp:sInfo.sUdtIp
                                                       serverPort:sInfo.sUdtPort];
    if (![dc_02[@"result"] isEqualToString:@"1"]) {
        [self performSelectorOnMainThread:@selector(sayFail) withObject:nil waitUntilDone:NO];
        if ([dc_02[@"result"] isEqualToString:@"0"] && [dc_02[@"message"] isEqualToString:@"该设备已离线"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MAIN_HEART object:nil];
        }
        return;
    }
    /*协议11，告诉摄像头我的内网ip和端口，以获取摄像头的ip和地址*/
    NSDictionary *dc_11    = [UDTUtility tellServerMyLocalAddress:dc_02 serverIp:sInfo.sUdtIp];
    if (![dc_11[@"result"] isEqualToString:@"1"]) {
        [self performSelectorOnMainThread:@selector(sayFail) withObject:nil waitUntilDone:NO];
        return;
    }
    /*尝试局域网打洞*/
    string sBurrowResult = burrowLocal(dc_11[@"cameraLocalIp"], [dc_11[@"cameraLocalPort"] intValue]);
    NSDictionary *dc_12 = nil;
    NSDictionary *dc_server = @{@"serverIp":sInfo.sUdtIp, @"serverPort":dc_02[@"port"], @"serial":dc_02[@"serial"]};
    if (sBurrowResult == "suc") {
        /*协议12，*/
        dc_12 = [UDTUtility tellServerBurrowComplete:dc_server isSuccess:YES];
    }else{
        /*协议12，*/
        dc_12 = [UDTUtility tellServerBurrowComplete:dc_server isSuccess:NO];
    }
    if ([dc_12[@"result"] isEqualToString:@"1"]) {
        NSDictionary *dc_14 = [UDTUtility tellServerBurrowSuccess:dc_server parameter:@{@"cameraIP":dc_11[@"cameraLocalIp"] , @"cameraPort":dc_11[@"cameraLocalPort"]}];
        Dlog(@"dc_14 = %@", dc_14);
        if (dc_14.count < 3) {
            Dlog(@"服务器返回数据有误");
            return;
        }
        ctr.sPlayURL = dc_14[@"rtsp"];
        [self performSelectorOnMainThread:@selector(play:) withObject:ctr waitUntilDone:NO];
    }else if ([dc_12[@"result"] isEqualToString:@"2"]){
        SNServerInfo *sInfo     = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
        NSString *sUrl          = FORMAT(@"%@%@.sdp", sInfo.sRtsp_real, ctr.cameraInfo.sDeviceId);
        ctr.sPlayURL            = sUrl;
        [self performSelectorOnMainThread:@selector(play:) withObject:ctr waitUntilDone:NO];
    }else if([dc_12[@"result"] isEqualToString:@"0"]){
        [self performSelectorOnMainThread:@selector(sayFail) withObject:nil waitUntilDone:NO];
    }
    [NSThread exit];
}

- (void)sayFail{
    [self removePlayingView];
    [HDUtility say:@"网络请求失败"];
}

- (void)play:(SNDeviceViewCtr *)ctr{
    Dlog(@"iTryPlayCount = %d", iTryPlayCount);
    HUD_play.labelText = @"准备播放...";
    if (iTryPlayCount > 4) {
        [self sayFail];
        return;
    }
    iTryPlayCount++;
    videoCtr                = [[PlayViedo alloc] initWithURL:ctr.sPlayURL deviceInfo:ctr.cameraInfo type:SNPlayTypeLiveTelecast];
    videoCtr.view.frame     = CGRectMake(0, 0, v_play.frame.size.width, v_play.frame.size.height);
    BOOL isSuc              = [videoCtr playStreaming];
    NSLog(@"isSuc = %d", isSuc);
    if (!isSuc) {
        [self play:ctr];
    }else{
        imv_animate.hidden  = YES;
        [HUD_play hide:YES];
    }
    [v_play addSubview:videoCtr.view];
}

- (BOOL)downLoadImage{
    Dlog(@"userInfo = %@", [SNGlobalInfo instance].userInfo);
    userInfo = [SNGlobalInfo instance].userInfo;
    if (userInfo.sHeadUrl.length > 0) {//如果有网络图片
//        NSString *sImagename    = [userInfo.sHeadUrl lastPathComponent];
//        NSString *sPath         = [HDUtility imageSavedPath:FORMAT(@"%@_%@", userInfo.sUserId, sImagename)];
//        UIImage *image          = [HDUtility imageWithUrl:userInfo.sHeadUrl];
//        BOOL isSuc              = [HDUtility saveToDocument:image withFilePath:sPath];
//        if (!isSuc) {
//            Dlog(@"保存图片失败");
//        }
        NSString *sPath         = [HDUtility imageWithUrl:userInfo.sHeadUrl savedFolderName:@FOLDER_USER savedFileName:nil];
        userInfo.sHeadPath      = sPath;
    }
    
    for (int i = 0; i < userInfo.mar_camera.count; i++) {
        SNCameraInfo *caInfo        = userInfo.mar_camera[i];
        if (caInfo.sPhotoUrl.length > 0) {//如果有网络图片
//            NSString *sPath         = [HDUtility imageSavedPath:FORMAT(@"%@.jpg", caInfo.sDeviceId)];
//            UIImage *image          = [HDUtility imageWithUrl:caInfo.sPhotoUrl];
//            BOOL isSuc = [HDUtility saveToDocument:image withFilePath:sPath];
//            if (!isSuc) {
//                Dlog(@"保存图片失败");
//            }
            NSString *sPath         = [HDUtility imageWithUrl:caInfo.sPhotoUrl savedFolderName:@FOLDER_DEVICE savedFileName:FORMAT(@"%@_preview.jpg", caInfo.sDeviceId)];
            caInfo.sPhotoPath       = sPath;
        }
    }
    for (int i = 0; i < userInfo.mar_friend.count; i++) {
        SNFriendInfo *fdInfo        = userInfo.mar_friend[i];
        if (fdInfo.sImageUrl.length > 0) {//如果有网络图片
//            NSString *sImagename    = [fdInfo.sImageUrl lastPathComponent];
//            NSString *sPath         = [HDUtility imageSavedPath:sImagename];
//            NSFileManager *manager  = [NSFileManager defaultManager];
//            if (![manager fileExistsAtPath:sPath]) {//图片本地路径若不存在，保存
//                UIImage *image      = [HDUtility imageWithUrl:fdInfo.sImageUrl];
//                BOOL isSuc = [HDUtility saveToDocument:image withFilePath:sPath];
//                if (!isSuc) {
//                    Dlog(@"保存图片失败");
//                }
//            }
            NSString *sPath         = [HDUtility imageWithUrl:fdInfo.sImageUrl savedFolderName:@FOLDER_FRIEND savedFileName:nil];
            fdInfo.sImagePath       = sPath;
        }
    }
    [HDUtility saveUserInfo:userInfo];
    [self performSelectorOnMainThread:@selector(refreshDeviceImage:) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(refreshUserHead) withObject:nil waitUntilDone:NO];
    Dlog(@"userInfo = %@", [SNGlobalInfo instance].userInfo);
    return YES;
}

- (void)counting{
    if (iCount == 5) {
        [timer invalidate];
        timer = nil;
        iCount = 0;
        v_sideBar.hidden = YES;
    }
    iCount++;
}
#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch          = [touches anyObject];
    UIView  *v              = [touch view];
    Dlog(@"v = %@", v);
    if ([v isEqual:self.view]) {
        Dlog(@"1111");
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [pageCtr setCurrentPage:scrollView.contentOffset.x/320];
}

#pragma mark - noti
- (void)ffmpegNotificationAction:(NSNotification *)sender{
    FFmpegNotice *noti = [sender object];
    if (noti.playStatus == ffmpeg_touchBackground) {
        if (timer) {
            [timer invalidate];
            timer = nil;
            iCount = 0;
        }
        v_sideBar.hidden = NO;
        iCount = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(counting) userInfo:nil repeats:YES];
    }
    if (noti.playStatus == ffmpeg_playFail) {
        
    }
}
-(void)exitFullScreen:(id)noti
{
    if (videoCtr != nil) {
        videoCtr.view.frame = CGRectMake(0, 0, v_play.frame.size.width, v_play.frame.size.height);
        [v_play addSubview:videoCtr.view];
        self.navigationController.navigationBarHidden = NO;
    }
}
- (void)doGuideViewCancel{
    
    [blurView           removeFromSuperview];
    [guideViewCtr.view  removeFromSuperview];
    blurView        = nil;
    guideViewCtr    = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_GUIDE_VIEW object:nil];
}

@end
