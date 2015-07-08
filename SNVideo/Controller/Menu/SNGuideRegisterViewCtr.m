//
//  SNGuideRegisterViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-10-9.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNGuideRegisterViewCtr.h"
#import "SNHttpUtility.h"
#import "SNWelcomViewCtr.h"
#import "SNLoginViewCtr.h"

@interface SNGuideRegisterViewCtr ()<MBProgressHUDDelegate>{

    IBOutlet UITextField    *tf_phone;
    IBOutlet UITextField    *tf_pwd;
    IBOutlet UITextField    *tf_code;
    IBOutlet UILabel        *lb_getCode;
    IBOutlet UIButton       *btn_resend;
    NSTimer                 *timer;
    int                     iTime;
    NSMutableDictionary     *mdic_code;
}

@end

@implementation SNGuideRegisterViewCtr

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
    [tf_phone   setValue:[UIColor grayColor]                      forKeyPath:@"_placeholderLabel.textColor"];
    [tf_phone   setValue:[UIFont fontWithName:@"Arial" size:13]   forKeyPath:@"_placeholderLabel.font"];
    [tf_pwd     setValue:[UIColor grayColor]                      forKeyPath:@"_placeholderLabel.textColor"];
    [tf_pwd     setValue:[UIFont fontWithName:@"Arial" size:13]   forKeyPath:@"_placeholderLabel.font"];
    [tf_code    setValue:[UIColor grayColor]                      forKeyPath:@"_placeholderLabel.textColor"];
    [tf_code    setValue:[UIFont fontWithName:@"Arial" size:13]   forKeyPath:@"_placeholderLabel.font"];
    
    mdic_code = [NSMutableDictionary  new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SEL

- (IBAction)doGetCode:(id)sender{

    if (![HDUtility isValidateMobile:tf_phone.text]) {
        [HDUtility say:@"输入手机号码有误！"];
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

- (IBAction)doConfirm:(id)sender{
    [tf_phone   resignFirstResponder];
    [tf_code    resignFirstResponder];
    [tf_pwd     resignFirstResponder];
    if (![HDUtility isValidateMobile:tf_phone.text]) {
        [HDUtility say:@"请输入正确的手机号码！"];
        return;
    }
    if ([tf_pwd.text length] < 6) {
        [HDUtility say:@"密码长度应大于等于6位！"];
        return;
    }
    if ([mdic_code objectForKey:tf_code.text] == nil) {
        [HDUtility say:@"输入验证码错误！"];
        return;
    }
    [[SNHttpUtility sharedClient] userRegistration_1:nil account:tf_phone.text password:tf_pwd.text messageCode:tf_code.text tranID:mdic_code[tf_code.text] CompletionBlock:^(BOOL isSuccess, NSString *userID, SNRegisterType regType, NSString *sMessage) {
        if (isSuccess) {
            MBProgressHUD *hud  = [HDUtility sayAfterSuccess:@"注册成功"];
            hud.delegate        = self;
        }else{
            [HDUtility sayAfterFail:@"注册失败"];
            [self doCancel:nil];
        }
    }];
}

- (IBAction)doCancel:(id)sender{

    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_GUIDE_VIEW object:nil];
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

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_code    resignFirstResponder];
    [tf_phone   resignFirstResponder];
    [tf_pwd     resignFirstResponder];
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
        [[SNHttpUtility sharedClient] userLoginWithAccount_1:tf_phone.text password:tf_pwd.text tocke:[HDUtility readTocken] CompletionBlock:^(BOOL isSuccess, SNUserInfo *userInfo, NSString *sMessage) {
            if (isSuccess) {
                Dlog(@"------------------------------用户Info = %@", [SNGlobalInfo instance].userInfo);
                [HDUtility sayAfterSuccess:@"登录成功"];
                RESideMenu *sideMenu = [SNWelcomViewCtr newMenuController];
                [self presentViewController:sideMenu animated:YES completion:nil];
            }else{
                [HDUtility sayAfterFail:@"登录失败"];
                SNLoginViewCtr *loginViewCtr    = [[SNLoginViewCtr alloc] init];
                UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:loginViewCtr];
                [self presentViewController:nav animated:YES completion:nil];
            }
        }];
    }else{
        Dlog(@"获取用户信息失败:登陆失败");
        [self doCancel:nil];
    }
}
@end



