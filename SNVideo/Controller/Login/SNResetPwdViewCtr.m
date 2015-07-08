//
//  SNResetPwdViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-23.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNResetPwdViewCtr.h"
#import "SNHttpUtility.h"

@interface SNResetPwdViewCtr (){

    IBOutlet UITextField    *tf_newPwd;
    IBOutlet UITextField    *tf_code;
    IBOutlet UILabel        *lb_time;
    IBOutlet UIButton       *btn_resend;
    NSTimer                 *timer;
    int                     iCount;
    NSString                *sPhone;
    NSMutableDictionary     *mdic_code;
}

@end

@implementation SNResetPwdViewCtr

- (id)initWithPhone:(NSString *)s code:(NSMutableDictionary *)md
{
    self = [super init];
    if (self) {
        if (s.length <= 0 || [md count] <= 0) {
            Dlog(@"传入参数错误！");
            return nil;
        }
        sPhone      = s;
        mdic_code   = md;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *color = [UIColor grayColor];
    [tf_newPwd  setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_newPwd  setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    [tf_code    setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_code    setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - SEL
- (IBAction)doConfirm:(id)sender{
    if (![HDUtility isValidatePassword:tf_newPwd.text]) {
        [HDUtility say:FORMAT(@"密码必须大于%d位，小于%d位", MIN_LENTH_PASSWORD, MAX_LENTH_PASSWORD)];
        return;
    }
    if (mdic_code[tf_code.text] == nil) {
        [HDUtility say:@"验证码错误！"];
        return;
    }
    [[SNHttpUtility sharedClient] passwordUpadteOfFind_1:nil tranID:mdic_code[tf_code.text] password:tf_newPwd.text messageCode:tf_code.text CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            [HDUtility say:@"修改密码成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FORGET_PWD object:nil];
        }
    }];
    
}

- (IBAction)doCancel:(id)sender{

    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FORGET_PWD object:nil];
}

- (IBAction)doResendTextCode:(id)sender{
    [[SNHttpUtility sharedClient] applicationFindPassword_1:nil phone:sPhone CompletionBlock:^(BOOL isSuccess, NSString *sTranID, NSString *msgCode, NSString *sMessage) {
        if (isSuccess) {
            [HDUtility say:FORMAT(@"验证码已发送到%@,请注意查收", sPhone)];
            [mdic_code setObject:sTranID forKey:msgCode];
            btn_resend.enabled  = NO;
            iCount              = 60;
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(count) userInfo:nil repeats:YES];
        }
    }];
    
}

- (void)count{
    iCount--;
    if (iCount < 0) {
        lb_time.text = @"重发验证码";
        btn_resend.enabled = YES;
        [timer invalidate];
        timer = nil;
        return;
    }
    lb_time.text = FORMAT(@"%d", iCount);
}
#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:tf_newPwd]) {
        [tf_code becomeFirstResponder];
    }
    if ([textField isEqual:tf_code]) {
        [self doConfirm:nil];
    }
    return YES;
}
#pragma mark - touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [tf_code resignFirstResponder];
    [tf_newPwd resignFirstResponder];
}
@end
