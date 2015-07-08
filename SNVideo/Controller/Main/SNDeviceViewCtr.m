//
//  SNDeviceViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-26.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNDeviceViewCtr.h"
#import "SNSetDeviceViewCtr.h"
#import "SNPhotoSeeVideo.h"

@interface SNDeviceViewCtr (){
    
    IBOutlet UIView *v_offLine;
}

@end

@implementation SNDeviceViewCtr

@synthesize cameraInfo;

- (SNDeviceViewCtr *)initWithCamera:(SNCameraInfo *)info{

    if (self = [super init]) {
        
        self.cameraInfo = info;
    }

    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:longPress];
    self.btn_replay.layer.cornerRadius  = self.btn_replay.frame.size.width/2;
    self.btn_setting.layer.cornerRadius = self.btn_setting.frame.size.width/2;
    [self.btn_replay.layer  setMasksToBounds:YES];
    [self.btn_setting.layer setMasksToBounds:YES];
    self.v_statusBack.backgroundColor = COLOR_MENU_DARK;
    self.lb_name.text = @"";
    self.lb_name.frame = CGRectMake(60, 76, CGRectGetWidth(_lb_name.frame), CGRectGetHeight(_lb_name.frame));
    [self.view addSubview:self.lb_name];
}

- (void)refreshView{
    if (self.cameraInfo) {
        self.imv_screen.hidden      = NO;
        self.lb_name.hidden         = NO;
        self.lb_noCamera.hidden     = (self.cameraInfo != nil);
        UIImage *img                = [UIImage imageWithContentsOfFile:self.cameraInfo.sPhotoPath];
        self.imv_screen.image       = img? img: [UIImage imageNamed:@"screenshot.jpg"];
        NSString *sName             = self.cameraInfo.sDeviceName;
        UIFont *font                = [UIFont fontWithName:@"Arial" size:13];
        CGSize sz                   = [sName sizeWithFont:font];
        self.lb_name.font           = font;
        self.lb_name.text           = sName;
        v_offLine.hidden            = self.cameraInfo.lineStatus;
        [_lb_name setFrame:CGRectMake(65-sz.width/2, 76, sz.width, CGRectGetHeight(_lb_name.frame))];
        if (self.cameraInfo.isBelongOther) {
            self.imv_isBelongOther.hidden = NO;
            self.lb_name.frame = CGRectMake(self.view.frame.size.width-sz.width-5, self.lb_name.frame.origin.y, sz.width, 20);
            self.v_settingMenuBack.backgroundColor = self.v_replayMenuBack.backgroundColor;
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)longPress:(id)sender{
    
    if (self.cameraInfo) {
        self.v_back.hidden = NO;
        if (self.cameraInfo.isBelongOther) {
            self.btn_replay.frame = CGRectMake(self.view.frame.size.width/2-self.btn_replay.frame.size.width/2, self.btn_replay.frame.origin.y, self.btn_replay.frame.size.width, self.btn_replay.frame.size.height);
            self.btn_setting.hidden = YES;
        }
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(doHideButtons) userInfo:nil repeats:NO];
    }
    
}

- (void)doHideButtons{
    
    self.v_back.hidden = YES;
}
#pragma mark - SEL

- (IBAction)doReplay:(id)sender{
    if (self.cameraInfo) {
        SNPhotoSeeVideo *seeV = [[SNPhotoSeeVideo alloc] initWithDeviceInfo:self.cameraInfo];
        [self.navigationController pushViewController:seeV animated:YES];
    }
}

- (IBAction)doSetting:(id)sender{
    SNSetDeviceViewCtr *ctr = [[SNSetDeviceViewCtr alloc] initWithCamera:self.cameraInfo];
    [self.parentViewController.navigationController pushViewController:ctr animated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch          = [touches anyObject];
    UIView  *v              = [touch view];
    if ([v isEqual:self.view] && self.cameraInfo) {
        Dlog(@"1212121");
        [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MAIN_PLAY object:nil userInfo:@{@"device": self}];
    }
    
}
@end
