//
//  SNRegisterViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-18.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNRegisterViewCtr.h"
#import "SNHttpUtility.h"
#import "SNLoginViewCtr.h"
#import "SNWelcomViewCtr.h"
#import "MBProgressHUD.h"
#import "SNSignViewCtr.h"
#import "SNLoginViewCtr.h"

@interface SNRegisterViewCtr ()<UITextFieldDelegate, UIAlertViewDelegate, MBProgressHUDDelegate>{

    IBOutlet UITextField    *tf_phone;
    IBOutlet UITextField    *tf_Pwd;
    IBOutlet UITextField    *tf_code;
    IBOutlet UIButton       *btn_useRN;
    IBOutlet UIButton       *btn_haveAcc;
    IBOutlet UIButton       *btn_resend;
    IBOutlet UILabel        *lb_getCode;
    NSMutableDictionary     *mdic_code;
    int                     iTime;
    NSTimer                 *timer;
}

@end

@implementation SNRegisterViewCtr

- (id)init{

    if (self = [super init]) {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    mdic_code = [[NSMutableDictionary alloc] init];
    UIColor *color = [UIColor grayColor];
    [tf_phone setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_phone setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    [tf_Pwd   setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_Pwd   setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    [tf_code  setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_code  setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    
    if (!IS_4INCH_SCREEN) {
        btn_haveAcc.center = CGPointMake(btn_haveAcc.center.x, btn_haveAcc.center.y - 88);
        btn_useRN.center   = CGPointMake(btn_useRN.center.x, btn_useRN.center.y - 88);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    tf_phone        = nil;
    tf_Pwd          = nil;
    tf_code         = nil;
    mdic_code       = nil;
}

#pragma mark - SEL
- (IBAction)doUseRightNow:(id)sender{
    [[SNHttpUtility sharedClient] userRegistration_1:nil account:nil password:nil messageCode:nil tranID:nil CompletionBlock:^(BOOL isSuccess, NSString *userID, SNRegisterType regType, NSString *sMessage) {
        if (isSuccess) {
            [[SNHttpUtility sharedClient] userLoginWithAccount_1:nil password:nil tocke:[HDUtility readTocken] CompletionBlock:^(BOOL isSuccess, SNUserInfo *userInfo, NSString *sMessage) {
                if (isSuccess) {
                    RESideMenu *sideMenu = [SNWelcomViewCtr newMenuController];
                    [self presentViewController:sideMenu animated:YES completion:nil];
                    [[SNGlobalInfo instance].appDelegate startHaretRequest];
                }
            }];
        }
    }];
}
- (IBAction)doHaveAccount:(id)sender{

    SNLoginViewCtr *loginCtr = [[SNLoginViewCtr alloc] init];
    [self presentViewController:loginCtr animated:YES completion:nil];
}
- (IBAction)doGetMessageCode:(id)sender{
    
    if (![HDUtility isValidateMobile:tf_phone.text]) {
        [HDUtility say:@"手机号格式错误！"];
        return;
    }
    [[SNHttpUtility sharedClient] applicationUserRegistration_1:nil phone:tf_phone.text CompletionBlock:^(BOOL isSuccess, NSString *tranID, NSString *msgCode, NSString *sMessage) {
        Dlog(@"%@", sMessage);
        if (isSuccess) {
            [HDUtility say:FORMAT(@"短信验证码已发送至%@,请注意查收！", tf_phone.text)];
            [mdic_code setObject:FORMAT(@"%@", tranID) forKey:msgCode];
            iTime = 60;
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        }
    }];
}

- (void)countDown:(NSTimer *)sender{
    
    if ([lb_getCode.text isEqualToString:@"0"]) {
        btn_resend.enabled  = YES;
        lb_getCode.text     = @"获取验证码";
        [timer invalidate];
        return;
    }
    btn_resend.enabled      = NO;
    lb_getCode.text         = FORMAT(@"%d", iTime);
    iTime--;
}
- (IBAction)doRegister:(id)sender{
    [tf_phone   resignFirstResponder];
    [tf_code    resignFirstResponder];
    [tf_Pwd     resignFirstResponder];
    
    if (![HDUtility isValidateMobile:tf_phone.text]) {
        [HDUtility say:@"手机号格式错误！"];
        return;
    }
    if (![HDUtility isValidatePassword:tf_Pwd.text]) {
        [HDUtility mbSay:FORMAT(@"密码格式错误，请输入%d－%d位数字或字母", MIN_LENTH_PASSWORD, MAX_LENTH_PASSWORD)];
        return;
    }
    if ([mdic_code objectForKey:tf_code.text] == nil) {
        [HDUtility say:@"输入验证码错误！"];
        return;
    }
    [[SNHttpUtility sharedClient] userRegistration_1:nil account:tf_phone.text password:tf_Pwd.text messageCode:tf_code.text tranID:mdic_code[tf_code.text] CompletionBlock:^(BOOL isSuccess, NSString *userID, SNRegisterType regType, NSString *sMessage) {
        if (isSuccess) {
            MBProgressHUD *hud  = [HDUtility sayAfterSuccess:@"注册成功"];
            hud.delegate        = self;
        }else{
            [HDUtility sayAfterFail:@"注册失败"];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:tf_phone]) {
        [tf_Pwd becomeFirstResponder];
    }
    if ([textField isEqual:tf_Pwd]) {
        [tf_code becomeFirstResponder];
    }
    if ([tf_code isEqual:textField]) {
        [tf_code resignFirstResponder];
        [self doRegister:nil];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{

    if ([textField isEqual:tf_code]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -50, 320, self.view.frame.size.height);
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    if ([textField isEqual:tf_code]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        }];
    }
}
#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    UIView *v = [touch view];
    if ([v isEqual:self.view]) {
        [tf_code        resignFirstResponder];
        [tf_phone       resignFirstResponder];
        [tf_Pwd         resignFirstResponder];
    }
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud{
    
    SNUserInfo *user = [SNGlobalInfo instance].userInfo;
    if (![SNGlobalInfo instance].userInfo) {
        Dlog(@"严重错误：登录用户为空！");
        return;
    }
    if (user) {
        [SNGlobalInfo instance].userInfo = user;
        [[SNHttpUtility sharedClient] userLoginWithAccount_1:tf_phone.text password:tf_Pwd.text tocke:[HDUtility readTocken] CompletionBlock:^(BOOL isSuccess, SNUserInfo *userInfo, NSString *sMessage) {
            if (isSuccess) {
                Dlog(@"------------------------------用户Info = %@", [SNGlobalInfo instance].userInfo);
                [HDUtility sayAfterSuccess:@"登录成功"];
                RESideMenu *sideMenu = [SNWelcomViewCtr newMenuController];
                [self presentViewController:sideMenu animated:YES completion:nil];
                [[SNGlobalInfo instance].appDelegate startHaretRequest];
            }else{
                [HDUtility sayAfterFail:@"登录失败"];
                SNLoginViewCtr *loginViewCtr    = [[SNLoginViewCtr alloc] init];
                UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:loginViewCtr];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }];
    }else{
       Dlog(@"获取用户信息失败 ：登陆失败")
        SNSignViewCtr *signViewCtr = [[SNSignViewCtr alloc] init];
        [self presentViewController:signViewCtr animated:YES completion:nil];
    }
}
@end
