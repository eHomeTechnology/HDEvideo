//
//  SNScanViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-25.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNScanViewCtr.h"
#import "SNHttpUtility.h"
#import <AVFoundation/AVFoundation.h>

@interface SNScanViewCtr ()<AVCaptureMetadataOutputObjectsDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>{

    IBOutlet UIView             *vScan;
    IBOutlet UIImageView        *imv_animation;
    NSTimer                     *timer;
    MBProgressHUD               *hud_addFriend;
    ZBarReaderView              *vReader;
}

@end

@implementation SNScanViewCtr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    vReader = nil;
    vScan   = nil;
    imv_animation = nil;
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    vReader                     = [[ZBarReaderView alloc] init];
    vReader.frame               = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    vReader.layer.borderWidth   = 1.5f;
    vReader.layer.borderColor   = [UIColor whiteColor].CGColor;
    vReader.readerDelegate      = self;
    vReader.torchMode           = 0;
    vReader.scanCrop            = vScan.frame;
    vReader.trackingColor       = [UIColor clearColor];
    [vScan addSubview:vReader];
    [vScan sendSubviewToBack:vReader];
    [vReader start];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startScanAnimate) userInfo:nil repeats:NO];
}

- (void)viewDidDisappear:(BOOL)animated{
    [vReader stop];
    [vReader removeFromSuperview];
    [timer invalidate];
    timer = nil;
    vReader = nil;
}

- (void)startScanAnimate{
    [UIView animateWithDuration:2.0f animations:^{
        imv_animation.frame = CGRectMake(72, 187, CGRectGetWidth(imv_animation.frame), CGRectGetHeight(imv_animation.frame));
    } completion:^(BOOL finished) {
        imv_animation.frame = CGRectMake(72, 55, CGRectGetWidth(imv_animation.frame), CGRectGetHeight(imv_animation.frame));
        if ([vReader.session isRunning]) {
            [self startScanAnimate];
        }
    }];
}

- (void)readerView: (ZBarReaderView*)readerView
     didReadSymbols: (ZBarSymbolSet*)symbols
          fromImage: (UIImage*)image{
    NSString *sValue = nil;
    for(ZBarSymbol *sym in symbols) {
        Dlog(@"-------------===sym = %@", sym.data);
        sValue = sym.data;
        break;
    }
    [readerView removeFromSuperview];
    UIImageView *imv = [[UIImageView alloc] initWithFrame:vScan.frame];
    [imv setImage:image];
    [vScan addSubview:imv];
    if (![HDUtility isValidateMobile:sValue]) {
        [HDUtility say:[NSString stringWithFormat:@"未找到指定好友"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FRIEND_ADD object:nil];
        return;
    }
    hud_addFriend           = [[MBProgressHUD alloc] initWithView:kWindow];
    hud_addFriend.labelText = @"正在添加...";
    [hud_addFriend show:YES];
    [[SNHttpUtility sharedClient] addFriend_1:[SNGlobalInfo instance].userInfo account:sValue CompletionBlock:^(BOOL isSuccess, SNFriendInfo *fInfo, NSString *sMessage) {
        [hud_addFriend hide:YES];
        if (isSuccess) {
            [[SNGlobalInfo instance].userInfo.mar_friend addObject:fInfo];
            [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
            //更新摄像头列表
            [[SNHttpUtility sharedClient] referDevice_1:[SNGlobalInfo instance].userInfo deviceType:SNDeviceTypeCamera CompletionBlock:^(BOOL isSuccess, NSArray *ar_cameraInfo, NSString *sMessage) {
                if (isSuccess) {
                    [[SNGlobalInfo instance].userInfo.mar_camera removeAllObjects];
                    [SNGlobalInfo instance].userInfo.mar_camera = [[NSMutableArray alloc] initWithArray:ar_cameraInfo];
                    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
                }else{
                    [HDUtility say:sMessage];
                }
            }];
            [HDUtility sayAfterSuccess:@"添加好友成功"];
            
        }else{
            [HDUtility say:sMessage];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FRIEND_ADD object:nil];
    }];

}
@end
