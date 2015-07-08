//
//  SNDeleteDeviceViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-28.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNDeleteDeviceViewCtr.h"
#import "SNHttpUtility.h"
#import "SNCameraInfo.h"

@interface SNDeleteDeviceViewCtr (){
    //删除面板
    IBOutlet UIView         *v_back;
    IBOutlet UIButton       *btn_resend;
    IBOutlet UITextField    *tf_messageCode;
    IBOutlet UILabel        *lb_textCode;
    NSTimer                 *timer;
    SNCameraInfo            *cameraInfo;
    NSMutableDictionary     *mdic_code;
}

@end

static int              iTime = 0;

@implementation SNDeleteDeviceViewCtr

- (id)initWithInfo:(SNCameraInfo *)info
{
    if (!info) {
        Dlog(@"传入参数错误");
        return nil;
    }
    self = [super init];
    if (self) {
        cameraInfo = info;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *color  = [UIColor grayColor];
    [tf_messageCode setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_messageCode setValue:[UIFont   fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
    Dlog(@"iTime = %d", iTime);
    if (iTime > 0) {
        lb_textCode.text    = FORMAT(@"%d", iTime);
        btn_resend.enabled  = NO;
        timer               = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    }else{
        lb_textCode.text    = @"发送验证码";
        btn_resend.enabled  = YES;
    }
    v_back.frame = CGRectMake(33, 120, CGRectGetWidth(v_back.frame), CGRectGetHeight(v_back.frame));
    [self.view addSubview:v_back];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - SEL
- (void)countDown:(NSTimer *)sender{
    if ([lb_textCode.text isEqualToString:@"0"]) {
        btn_resend.enabled  = YES;
        lb_textCode.text    = @"发送短信验证码";
        [timer invalidate];
        return;
    }
    btn_resend.enabled = NO;
    lb_textCode.text = FORMAT(@"%d", iTime);
    iTime--;
}

- (IBAction)doResendMessage:(id)sender{
    
    [[SNHttpUtility sharedClient] applicationDeleteDevice_1:[SNGlobalInfo instance].userInfo devicID:cameraInfo.sDeviceId CompletionBlock:^(BOOL isSuccess, NSString *tranID, NSString *msgCode, NSString *sMessage) {
        if (isSuccess) {
            [HDUtility say:FORMAT(@"短信验证码已发送到%@,请注意查收", [SNGlobalInfo instance].userInfo.sPhone)];
            if (!mdic_code) {
                mdic_code = [[NSMutableDictionary alloc] init];
            }
            [mdic_code setValue:tranID forKeyPath:msgCode];
            [tf_messageCode becomeFirstResponder];
            iTime = 60;
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        }
    }];
}
- (IBAction)doCancel:(id)sender{
    if ([timer isValid]) {
        [timer invalidate];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_DELETE_DEVICE_CANCEL object:@"0"];
}
- (IBAction)doDeleteConfirm:(id)sender{
    
    if (tf_messageCode.text.length <= 0) {
        [HDUtility say:@"请输入验证码"];
        return;
    }
    if (!mdic_code[tf_messageCode.text]) {
        [HDUtility say:@"输入验证码错误！"];
        return;
    }
    [[SNHttpUtility sharedClient] deleteDevice_1:[SNGlobalInfo instance].userInfo devicID:cameraInfo.sDeviceId messageCode:tf_messageCode.text tranID:mdic_code[tf_messageCode.text] CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            SNUserInfo *user = [SNGlobalInfo instance].userInfo;
            for (int i = 0; i < user.mar_camera.count; i++) {
                if ([cameraInfo.sDeviceId isEqualToString:((SNCameraInfo *)user.mar_camera[i]).sDeviceId]) {
                    [user.mar_camera removeObjectAtIndex:i];
                    break;
                }
            }
            [HDUtility saveUserInfo:user];
            [HDUtility sayAfterSuccess:@"删除成功"];
            iTime = 0;
            if ([timer isValid]) {
                [timer invalidate];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_DELETE_DEVICE_CANCEL object:@"1"];
        }
    }];
}

#pragma touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_messageCode resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self doDeleteConfirm:nil];
    return YES;
}
@end




