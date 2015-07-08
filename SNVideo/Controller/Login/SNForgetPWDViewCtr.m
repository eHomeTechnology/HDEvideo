//
//  SNForgetPWDViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-18.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNForgetPWDViewCtr.h"
#import "SNHttpUtility.h"
#import "SNResetPwdViewCtr.h"

@interface SNForgetPWDViewCtr ()<UITextFieldDelegate>{

    IBOutlet UITextField    *tf_phone;
    IBOutlet UIView         *v_forget;
    NSMutableDictionary     *mdic_code;
    NSString                *sPhone;
}

@end

@implementation SNForgetPWDViewCtr

- (id)initWithPhone:(NSString *)sPhone_{

    if (self = [super init]) {
        sPhone = sPhone_;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *color = [UIColor grayColor];
    [tf_phone setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_phone setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    [tf_phone becomeFirstResponder];
    tf_phone.text = sPhone;
    v_forget.frame = CGRectMake(33, 120, CGRectGetWidth(v_forget.frame), CGRectGetHeight(v_forget.frame));
    [self.view addSubview:v_forget];
    mdic_code = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    tf_phone = nil;
}

#pragma mark - SEL

-(IBAction)doCancelOut:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FORGET_PWD object:self userInfo:nil];
}

-(IBAction)doConfirm:(id)sender{
    if (![HDUtility isValidateMobile:tf_phone.text]) {
        [HDUtility say:@"请输入正确的手机号号码！"];
        return;
    }
    [[SNHttpUtility sharedClient] applicationFindPassword_1:nil phone:tf_phone.text CompletionBlock:^(BOOL isSuccess, NSString *sTranID, NSString *msgCode, NSString *sMessage) {
        if (isSuccess) {
            [mdic_code setObject:sTranID forKey:msgCode];
            SNResetPwdViewCtr *ctr = [[SNResetPwdViewCtr alloc] initWithPhone:tf_phone.text code:mdic_code];
            ctr.view.frame = CGRectMake(320., CGRectGetMinY(v_forget.frame), CGRectGetWidth(ctr.view.frame), CGRectGetHeight(ctr.view.frame));
            [self.view addSubview:ctr.view];
            [self addChildViewController:ctr];
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                v_forget.frame = CGRectMake(-320.0f, CGRectGetMinY(v_forget.frame), 0, CGRectGetHeight(v_forget.frame));
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    ctr.view.frame = CGRectMake(33., CGRectGetMinY(v_forget.frame), CGRectGetWidth(ctr.view.frame), CGRectGetHeight(ctr.view.frame));
                }];
            }];
            [HDUtility mbSay:FORMAT(@"找回密码验证码已发送到手机%@", tf_phone.text)];
        }
    }];
}

#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self doConfirm:nil];
    return YES;
}
#pragma mark - touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    [tf_phone resignFirstResponder];
}
@end
