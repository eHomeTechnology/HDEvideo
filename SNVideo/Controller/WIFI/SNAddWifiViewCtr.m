//
//  SNAddWifiViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-4.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNAddWifiViewCtr.h"

@interface SNAddWifiViewCtr ()<UITextFieldDelegate, UIAlertViewDelegate>{

    IBOutlet UITextField    *tf_wifiName;
    IBOutlet UITextField    *tf_wifiPwd;
    IBOutlet UISwitch       *sw_pwd;
    IBOutlet UIView         *v_sub;
    IBOutlet UIImageView    *imv_line;
    IBOutlet UILabel        *lb_noPassword;
}

@end

@implementation SNAddWifiViewCtr

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
    sw_pwd.on = NO;
    v_sub.frame = CGRectMake(33, 120, CGRectGetWidth(v_sub.frame), CGRectGetHeight(v_sub.frame));
    [self.view addSubview:v_sub];
    UIColor *color = [UIColor grayColor];
    [tf_wifiPwd  setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_wifiPwd  setValue:[UIFont   fontWithName:@"Arial" size:15] forKeyPath:@"_placeholderLabel.font"];
    [tf_wifiName setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_wifiName setValue:[UIFont   fontWithName:@"Arial" size:15] forKeyPath:@"_placeholderLabel.font"];
    
    if (IOS_VERSION < 7.0) {
        lb_noPassword.center = CGPointMake(lb_noPassword.center.x + 30, lb_noPassword.center.y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SEL
- (IBAction)doConfirm:(id)sender{

    if ([tf_wifiName.text length] <= 0) {
        [HDUtility say:@"WIFI名称不能为空！"];
        return;
    }
    if (tf_wifiName.text.length > MAX_LENTH_WIFI) {
        [HDUtility say:FORMAT(@"WIFI名称长度最大为%d位", MAX_LENTH_WIFI)];
        return;
    }
    if (tf_wifiPwd.text.length <= 0 && sw_pwd.on == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未输入密码，确定该WIFI无密码？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    [self saveWifi:tf_wifiName.text pwd:tf_wifiPwd.text];
    [self doCancel:nil];
}

- (void)saveWifi:(NSString *)sWifi pwd:(NSString *)sPwd{
    if (sWifi.length <= 0) {
        Dlog(@"wifi名称不能为空！");
        return;
    }
    SNWIFIInfo *info    = [[SNWIFIInfo alloc] init];
    info.sSSID          = sWifi;
    info.sPassword      = sPwd;
    [[SNGlobalInfo instance].userInfo.mar_wifi addObject:info];
    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
}

- (IBAction)doCancel:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_WIFI_ADD object:nil];
}

- (IBAction)switchValueChanged:(UISwitch *)sender{
    [tf_wifiPwd resignFirstResponder];
    [tf_wifiName resignFirstResponder];
    tf_wifiPwd.text = nil;
    if (sender.on) {
        tf_wifiPwd.enabled      = NO;
        tf_wifiPwd.alpha        = 0.3f;
        imv_line.alpha          = 0.3f;
        tf_wifiPwd.placeholder  = @"无";
    }else{
        tf_wifiPwd.enabled      = YES;
        tf_wifiPwd.alpha        = 1.0f;
        imv_line.alpha          = 1.0f;
        tf_wifiPwd.placeholder  = @"请输入wifi密码";
    }
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    if ([tf_wifiName isEqual:textField]) {
        [tf_wifiPwd becomeFirstResponder];
    }
    if ([tf_wifiPwd isEqual:textField]) {
        [self doConfirm:nil];
    }
    return YES;
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_wifiPwd     resignFirstResponder];
    [tf_wifiName    resignFirstResponder];
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        sw_pwd.on = YES;
        [self saveWifi:tf_wifiName.text pwd:tf_wifiPwd.text];
        [self doCancel:nil];
    }
}

@end
