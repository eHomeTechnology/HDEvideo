//
//  SNModifyPwdViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-18.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNModifyPwdViewCtr.h"
#import "SNHttpUtility.h"

@interface SNModifyPwdViewCtr ()
{
    IBOutlet UITextField *tf_old;
    IBOutlet UITextField *tf_new;
    IBOutlet UITextField *tf_repeat;
    
}
@end

@implementation SNModifyPwdViewCtr

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
    
    UIColor *color = [UIColor grayColor];
    [tf_new     setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_old     setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_repeat  setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_old becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button Action
- (IBAction)okButtonAction:(id)sender
{
    if (![HDUtility isValidatePassword:tf_old.text]) {
        [HDUtility mbSay:@"旧密码格式错误，请输入6-12位数字或字母"];
        return;
    }
    if (![tf_repeat.text isEqualToString:tf_new.text]) {
        [HDUtility mbSay:@"新密码两次输入不一致"];
        return;
    }
    if (![HDUtility isValidatePassword:tf_new.text]) {
        [HDUtility mbSay:@"新密码格式错误，请输入6-12位数字或字母"];
    }
    [[SNHttpUtility sharedClient] passwordUpdate_1:[SNGlobalInfo instance].userInfo oldPassword:tf_old.text newPassword:tf_new.text CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            [SNGlobalInfo instance].userInfo.sPassword = tf_new.text;
            [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MODIFY_PWD object:nil];
}

- (IBAction)cancelButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MODIFY_PWD object:nil];
}


#pragma mark - touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_new     resignFirstResponder];
    [tf_old     resignFirstResponder];
    [tf_repeat  resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:tf_old]) {
        [tf_new becomeFirstResponder];
    }
    if ([textField isEqual:tf_new]) {
        [tf_repeat becomeFirstResponder];
    }
    if ([textField isEqual:tf_repeat]) {
        
        [self okButtonAction:nil];
    }
    return YES;
}
@end
