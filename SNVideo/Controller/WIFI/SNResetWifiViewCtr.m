//
//  SNResetWifiViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-4.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNResetWifiViewCtr.h"
#import "SNWIFIInfo.h"

@interface SNResetWifiViewCtr ()<UITextFieldDelegate>{
    
    IBOutlet UITextField    *tf_ssid;
    IBOutlet UITextField    *tf_pwd;
    IBOutlet UIView         *v_sub;
    IBOutlet UISwitch       *sw_pwd;
    IBOutlet UIImageView    *imv_line;
    SNWIFIInfo              *wifiInfo;
    NSMutableArray          *mar_wifi;
}

@end

@implementation SNResetWifiViewCtr

- (id)initWithWifiInfo:(SNWIFIInfo *)wifi{

    if (self = [super init]) {
        if (!wifi) {
            Dlog(@"出错：传入wifiInfo参数不能为空！");
            return nil;
        }
        wifiInfo = wifi;
        mar_wifi = [SNGlobalInfo instance].userInfo.mar_wifi;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame     = CGRectMake(0, 600, 320, self.view.frame.size.height);
    tf_ssid.text        = wifiInfo.sSSID;
    sw_pwd.on           = !wifiInfo.sPassword.length;
    tf_pwd.placeholder  = sw_pwd.on? @"无密码": @"";
    imv_line.alpha      = sw_pwd.on? 0.3f: 1.0f;
    tf_pwd.alpha        = sw_pwd.on? 0.3f: 1.0f;
    tf_pwd.text         = wifiInfo.sPassword;
    UIColor *color      = [UIColor grayColor];
    v_sub.frame         = CGRectMake(33, 120, CGRectGetWidth(v_sub.frame), CGRectGetHeight(v_sub.frame));
    [tf_pwd  setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_pwd  setValue:[UIFont   fontWithName:@"Arial" size:15] forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:v_sub];
    
    if (IOS_VERSION < 7.0) {
        tf_pwd.frame = CGRectMake(tf_pwd.frame.origin.x, tf_pwd.frame.origin.y, tf_pwd.frame.size.width - 20, tf_pwd.frame.size.height);
        sw_pwd.center = CGPointMake(sw_pwd.center.x - 20, sw_pwd.center.y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - SEL
- (IBAction)doConfirm:(id)sender{
    if (tf_ssid.text.length <= 0) {
        [HDUtility say:@"SSID不能为空，请输入wifi的SSID名称"];
        return;
    }
    if (tf_pwd.text.length <= 0 && sw_pwd.on == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未输入密码，确定该WIFI没有密码？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    [self save];
}

- (void)save{
    wifiInfo.sPassword = tf_pwd.text;
    mar_wifi           = [SNGlobalInfo instance].userInfo.mar_wifi;
    for (int i = 0; i < mar_wifi.count; i++) {
        SNWIFIInfo *info = mar_wifi[i];
        if ([info.sSSID isEqualToString:wifiInfo.sSSID]) {
            [mar_wifi removeObjectAtIndex:i];
            [mar_wifi insertObject:wifiInfo atIndex:i];
            BOOL isSuc = [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
            if (isSuc) {
                [HDUtility sayAfterSuccess:@"保存成功"];
                [self doCancel:nil];
            }else{
                [HDUtility sayAfterFail:@"保存失败"];
            }
            
            break;
        }
    }
}

- (IBAction)doCancel:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_WIFI_RESET object:nil];
}

- (IBAction)switchValueChanged:(UISwitch *)sender{
    [tf_pwd resignFirstResponder];
    tf_pwd.text = nil;
    if (sender.on) {
        tf_pwd.enabled      = NO;
        tf_pwd.alpha        = 0.3f;
        imv_line.alpha      = 0.3f;
        tf_pwd.placeholder  = @"无密码";
    }else{
        tf_pwd.enabled      = YES;
        tf_pwd.alpha        = 1.0f;
        imv_line.alpha      = 1.0f;
        tf_pwd.placeholder  = @"请输入密码";
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:tf_ssid]) {
        [tf_ssid resignFirstResponder];
        [tf_pwd becomeFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
    [self doConfirm:nil];
    return YES;
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        sw_pwd.on = YES;
        [self save];
    }
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_pwd     resignFirstResponder];
}

@end
