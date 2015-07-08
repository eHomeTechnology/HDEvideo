//
//  SNLoginViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-18.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNLoginViewCtr.h"
#import "SNForgetPWDViewCtr.h"
#import "SNMainViewCtr.h"
#import "SNInstance.h"
#import "SNUserInfo.h"
#import "SNHttpUtility.h"
#import "SNWelcomViewCtr.h"
#import "SNRegisterViewCtr.h"
#import "HDBlurView.h"

@interface SNLoginViewCtr (){

    IBOutlet UIButton       *btn_head;
    IBOutlet UITextField    *tf_account;
    IBOutlet UITextField    *tf_pwd;
    IBOutlet UIButton       *btn_userRN;
    IBOutlet UIButton       *btn_goRegister;
    HDBlurView              *blurView;
    SNForgetPWDViewCtr      *forgetPwdViewCtr;
    UIActionSheet           *as_headPhoto;
    NSMutableArray          *mar_loginUser;

}

@end

@implementation SNLoginViewCtr

- (id)init
{
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用户登录";
    UIColor *color = [UIColor grayColor];
    [tf_account setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_account setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    [tf_pwd     setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_pwd     setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    mar_loginUser = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@LOGIN_USER]];
    NSLog(@"mar_loginUser = %@", mar_loginUser);
    if (mar_loginUser.count > 0) {
        NSDictionary *dic   = mar_loginUser[0];
        SNUserInfo *user    = [SNUserInfo userInfoWithDictionary:dic];
        if (user.sPhone.length > 0 && ![user.sPhone isEqualToString:@"null"]) {
            tf_account.text     = user.sPhone;
            tf_pwd.text         = user.sPassword;
            UIImage *imag = [UIImage imageWithContentsOfFile:user.sHeadPath];
            if (imag) {
                [btn_head setImage:imag forState:UIControlStateNormal];
                btn_head.layer.cornerRadius     = btn_head.frame.size.width/2;
                btn_head.layer.masksToBounds    = YES;
            }
        }
    }
    [HDUtility circleTheView:btn_head];
}

- (void)didReceiveMemoryWarning
{
    btn_head        = nil;
    tf_pwd          = nil;
    tf_account      = nil;
    mar_loginUser   = nil;
    [super didReceiveMemoryWarning];
}

#pragma mark - SEL

- (IBAction)doForgetPwd:(id)sender{
    
    UIView *keyWindow   = [UIApplication sharedApplication].keyWindow;
    blurView            = [[HDBlurView alloc] initWithFrame:keyWindow.frame];
    forgetPwdViewCtr    = [[SNForgetPWDViewCtr alloc] initWithPhone:tf_account.text];
    [keyWindow addSubview:blurView];
    [HDUtility showView:forgetPwdViewCtr.view centerAtPoint:keyWindow.center duration:0.3];
    [keyWindow addSubview:forgetPwdViewCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doForgetPwdCancel) name:@KEY_NOTI_FORGET_PWD object:nil];
}

- (void)doForgetPwdCancel{

    [blurView removeFromSuperview];
    blurView = nil;
    [forgetPwdViewCtr.view removeFromSuperview];
    forgetPwdViewCtr = nil;
}

- (IBAction)doLogin:(id)sender{
    [tf_account resignFirstResponder];
    [tf_pwd resignFirstResponder];
    Dlog(@"----%@, %@", tf_account.text, tf_pwd.text);
    if (![HDUtility isValidateMobile:tf_account.text]) {
        [HDUtility mbSay:@"手机号格式错误"];
        return;
    }
    if (![HDUtility isValidatePassword:tf_pwd.text]) {
        [HDUtility mbSay:FORMAT(@"密码格式错误，请输入%d－%d位数字或字母", MIN_LENTH_PASSWORD, MAX_LENTH_PASSWORD)];
    }
    [[SNHttpUtility sharedClient] userLoginWithAccount_1:tf_account.text password:tf_pwd.text tocke:[HDUtility readTocken] CompletionBlock:^(BOOL isSuccess, SNUserInfo *userInfo, NSString *sMessage) {
        if (isSuccess) {
            Dlog(@"用户Info = %@", [SNGlobalInfo instance].userInfo);
            RESideMenu *sideMenu = [SNWelcomViewCtr newMenuController];
            [self presentViewController:sideMenu animated:YES completion:nil];
            [[SNGlobalInfo instance].appDelegate startHaretRequest];
        }
    }];
}

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

- (IBAction)doRegister:(id)sender{
    SNRegisterViewCtr *ctr = [[SNRegisterViewCtr alloc] init];
    [self presentViewController:ctr animated:YES completion:nil];
}
#pragma mark - touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch  = [touches anyObject];
    UIView *v       = [touch view];
    if ([v isEqual:self.view]) {
        [tf_account resignFirstResponder];
        [tf_pwd resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == tf_account) {
        for (int i = 0; i < mar_loginUser.count; i++) {
            NSDictionary *dic       = mar_loginUser[i];
            if ([textField.text isEqualToString:dic[@K_LOGIN_USER_PHONE]]) {
                SNUserInfo *user    = [SNUserInfo userInfoWithDictionary:dic];
                tf_pwd.text         = user.sPassword;
                UIImage *imag       = [UIImage imageWithContentsOfFile:user.sHeadPath];
                if (imag) {
                    [btn_head setImage:imag forState:UIControlStateNormal];
                }else{
                    [btn_head setImage:[UIImage imageNamed:@"head_default.jpg"] forState:UIControlStateNormal];
                }
                return;
            }
        }
        [btn_head setImage:[UIImage imageNamed:@"head_default.jpg"] forState:UIControlStateNormal];
    }

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (tf_account == textField) {
        [tf_pwd becomeFirstResponder];
    }
    if (tf_pwd == textField) {
        [self doLogin:nil];
    }
    return YES;
}

@end
