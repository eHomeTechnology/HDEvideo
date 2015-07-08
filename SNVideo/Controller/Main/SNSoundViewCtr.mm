//
//  SNSoundViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-19.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNSoundViewCtr.h"
#import <AVFoundation/AVFoundation.h>
#import "SNHttpUtility.h"
#import "dtv_core.h"
#import "SNRenameViewCtr.h"
#import "UDTUtility.h"
#import "SNCameraInfo.h"

@interface SNSoundViewCtr ()<AVAudioPlayerDelegate>{

    IBOutlet UIButton       *btn_voice;
    IBOutlet UIImageView    *imv_sound;
    IBOutlet UIButton       *btn_lastStep;
    IBOutlet UIButton       *btn_cancel;
    IBOutlet UILabel        *lb_failPrompt;
    IBOutlet UILabel        *lb_step;
    IBOutlet UIImageView    *imv_step;
    IBOutlet UILabel        *lb_title;
    IBOutlet UILabel        *lb_prompt_1;
    IBOutlet UILabel        *lb_prompt_2;
    IBOutlet UIView         *v_prompt;
    IBOutlet UILabel        *lb_ssid;
    SNWIFIInfo              *wifiInfo;
    SNCameraInfo            *cameraInfo;
    MBProgressHUD           *HUD;
    MBProgressHUD           *HUD_init;
    int                     iMaxRequestCount;
    NSString                *sTradeId;
    NSString                *sPathSound;
    BOOL                    isLastViewShare;
}


@property (strong) AVAudioPlayer *soundPlayer;

@end

@implementation SNSoundViewCtr

- (id)initWithWifiInfo:(SNWIFIInfo *)info
{
    self = [super init];
    if (self) {
        if (!info) {
            Dlog(@"传入参数错误！");
            return nil;
        }
        wifiInfo = info;
        isLastViewShare = NO;
    }
    return self;
}

- (id)initWithSharedWifiInfo:(SNWIFIInfo *)info camera:(SNCameraInfo *)cInfo{

    if (self = [super init]) {
        if (!info) {
            Dlog(@"传入参数错误！");
            return nil;
        }
        wifiInfo = info;
        isLastViewShare = YES;
        cameraInfo = cInfo;
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isLastViewShare) {
        btn_lastStep.hidden = YES;
        imv_step.hidden = YES;
        lb_step.hidden = YES;
        lb_title.frame = CGRectMake(0, lb_title.frame.origin.y, self.view.frame.size.width, 20);
        [lb_title setTextAlignment:NSTextAlignmentCenter];
        if (cameraInfo) {
            lb_title.text = [NSString stringWithFormat:@"分享WiFi到%@", cameraInfo.sDeviceName];
        }else{
            lb_title.text = @"分享WiFi到设备";
        }
        lb_prompt_1.text = @"靠近e-see摄像头";
        lb_prompt_2.text = @"点击进行分享";
        lb_ssid.hidden   = NO;
        lb_ssid.text     = [NSString stringWithFormat:@"Wi-Fi名称:%@", wifiInfo.sSSID];
    }
    UIImage *img1 = [UIImage imageNamed:@"声波范围1.png"];
    UIImage *img2 = [UIImage imageNamed:@"声波范围2.png"];
    UIImage *img3 = [UIImage imageNamed:@"声波范围3.png"];
    UIImage *img4 = [UIImage imageNamed:@"声波范围4.png"];
    [imv_sound setAnimationImages:@[img1, img2, img3, img4]];
    [imv_sound setAnimationDuration:0.5];
    [imv_sound setAnimationRepeatCount:MAXFLOAT];
    
}

- (void)viewDidAppear:(BOOL)animated{
    HUD_init = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD_init];
	HUD_init.labelText = @"准备数据，请稍后...";
	[HUD_init show:YES];
    if (isLastViewShare) {
        NSArray *ar_Result  = nil;
        if (cameraInfo) {
            ar_Result       = [UDTUtility tellService2TurnOnCameraSoundListening:cameraInfo.sDeviceId];
        }else{
            ar_Result       = [UDTUtility tellService2TurnOnCameraSoundListening:nil];
        }
        sPathSound          = [NSString stringWithFormat:@"%@/Documents/sound.wav", NSHomeDirectory()];
        SNUserInfo *user    = [SNGlobalInfo instance].userInfo;
        NSString *sData     = nil;
        if (cameraInfo) {
            sData           = [NSString stringWithFormat:@"02∮%@∮%@∮%@∮%@", wifiInfo.sSSID, wifiInfo.sPassword == nil? @"" : wifiInfo.sPassword, user.sUserId, cameraInfo.sDeviceId];
        }else{
            sData           = [NSString stringWithFormat:@"02∮%@∮%@∮%@∮%@", wifiInfo.sSSID, wifiInfo.sPassword == nil? @"" : wifiInfo.sPassword, user.sUserId, @"all"];
        }
        Dlog(@"sData = %@", sData);
        const char *cData   = [sData cStringUsingEncoding:NSUTF8StringEncoding];
        DtvCore::toAudio(cData, (int)strlen(cData), [sPathSound UTF8String]);
        [HUD_init hide:YES];
        Dlog(@"result===%@", ar_Result);
    }else{
        //申请交易ID
        [[SNHttpUtility sharedClient] applicationDeviceRegist_1:[SNGlobalInfo instance].userInfo CompletionBlock:^(BOOL isSuccess, NSString *tranID, NSString *sMessage) {
            if (isSuccess) {
                sTradeId            = tranID;
                //初始化声波
                sPathSound          = [NSString stringWithFormat:@"%@/Documents/sound.wav", NSHomeDirectory()];
                SNUserInfo *user    = [SNGlobalInfo instance].userInfo;
                NSString *sData     = [NSString stringWithFormat:@"01∮%@∮%@∮%@∮%@", wifiInfo.sSSID, wifiInfo.sPassword, user.sUserId, sTradeId];
                Dlog(@"sData = %@", sData);
                const char *cData   = [sData cStringUsingEncoding:NSUTF8StringEncoding];
                DtvCore::toAudio(cData, (int)strlen(cData), [sPathSound UTF8String]);
                [HUD_init hide:YES];
            }
        }];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    btn_cancel      = nil;
    btn_lastStep    = nil;
    btn_voice       = nil;
}

#pragma mark - SEL
- (IBAction)doSendVoiceData:(id)sender{
    
    [imv_sound startAnimating];
    _soundPlayer            = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:sPathSound] error:NULL];
    _soundPlayer.volume     = 1;
    _soundPlayer.delegate   = self;
    [ _soundPlayer prepareToPlay];
    [_soundPlayer play];
    
    v_prompt.hidden = NO;
    lb_failPrompt.hidden = YES;
}

- (IBAction)goBack:(id)sender{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.view.frame = CGRectMake(330, CGRectGetMinY(self.view.frame), 0, CGRectGetHeight(self.view.frame));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTIFICATION_ADD_DEVICE_BACK object:nil userInfo:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }];
    
    
}

- (IBAction)doCancel:(id)sender{
    if (isLastViewShare) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_WIFI_SHARE object:nil userInfo:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_ADD_DEVICE_CANCEL object:nil userInfo:nil];
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [imv_sound stopAnimating];
    if (isLastViewShare) {
        [HDUtility sayAfterSuccess:@"操作成功！"];
        [self doCancel:nil];
    }else{
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText           = @"正在匹配数据，请稍后...";
        HUD.dimBackground       = YES;
        iMaxRequestCount        = 0;
        v_prompt.hidden         = NO;
        lb_failPrompt.hidden    = YES;
        [HUD show:YES];
        [NSThread detachNewThreadSelector:@selector(requestForNewDeviceWithTradId:) toTarget:self withObject:nil];
    }
}

- (void)requestForNewDeviceWithTradId:(NSString *)sId{
    
    [[SNHttpUtility sharedClient] getDeviceForNewAdd_1:[SNGlobalInfo instance].userInfo tranID:sTradeId CompletionBlock:^(BOOL isSuccess, SNCameraInfo *cInfo, NSString *sMessage) {
        if (isSuccess) {
            if (!cInfo) {
                iMaxRequestCount++;
                if (iMaxRequestCount == 20) {//等待40秒
                    [HUD hide:YES];
                    v_prompt.hidden      = YES;
                    lb_failPrompt.hidden = NO;
                    [[NSThread currentThread] cancel];
                    return;
                }
                sleep(2.0f);
                [self requestForNewDeviceWithTradId:nil];
                return;
            }
            [HUD hide:YES];
            [[SNGlobalInfo instance].userInfo.mar_camera addObject:cInfo];
            if (![HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo]) {
                Dlog(@"保存用户信息失败");
            }
            SNRenameViewCtr *ctr    = [[SNRenameViewCtr alloc] initWithCamera:cInfo];
            ctr.view.frame          = CGRectMake(320, CGRectGetMinY(self.view.frame), 0, CGRectGetHeight(self.view.frame));
            [self.parentViewController addChildViewController:ctr];
            [self.parentViewController.view addSubview:ctr.view];
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                self.view.frame = CGRectMake(-320, CGRectGetMinY(self.view.frame), 0, CGRectGetHeight(self.view.frame));
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    ctr.view.frame = CGRectMake(33, CGRectGetMinY(self.view.frame), 254, CGRectGetHeight(ctr.view.frame));
                }];
            }];
        }else{
            [HDUtility say:sMessage];
            v_prompt.hidden      = YES;
            lb_failPrompt.hidden = NO;
            [HUD hide:YES];
        }
    }];
}

@end
