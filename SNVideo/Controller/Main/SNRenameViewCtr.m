//
//  SNRenameViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-19.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNRenameViewCtr.h"
#import "SNCameraInfo.h"
#import "SNHttpUtility.h"

@interface SNRenameViewCtr (){

    IBOutlet UITextField    *tf_deviceName;
    
}

@property (strong)SNCameraInfo *cameraInfo;
@end

@implementation SNRenameViewCtr

- (id)initWithCamera:(SNCameraInfo *)info
{
    self = [super init];
    if (self) {
        if (!info) {
            Dlog(@"传入参数错误！");
            return nil;
        }
        self.cameraInfo = info;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *color = [UIColor grayColor];
    [tf_deviceName setValue:color   forKeyPath:@"_placeholderLabel.textColor"];
    [tf_deviceName setValue:[UIFont fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - SEL

- (IBAction)shortcutEnter:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 0:{
            
            tf_deviceName.text = @"客厅";
            break;
        }
        case 1:{
            tf_deviceName.text = @"书房";
            break;
        }
        case 2:{
            tf_deviceName.text = @"大门";
            break;
        }
        case 3:{
            tf_deviceName.text = @"走廊";
            break;
        }
        case 4:{
            tf_deviceName.text = @"车库";
            break;
        }
        case 5:{
            tf_deviceName.text = @"卧室";
            break;
        }
            
        default:
            break;
    }
    
}

- (IBAction)doComplete:(id)sender{
    if (tf_deviceName.text.length <= 0) {
        return;
    }
    self.cameraInfo.sDeviceName     = tf_deviceName.text;
    Dlog(@"self.cameraInfo = %@", self.cameraInfo);
    if (![HDUtility isValidateName:self.cameraInfo.sDeviceName]) {
        [HDUtility say:@"请输入2-8位数字字母或汉字"];
        return;
    }
    [[SNHttpUtility sharedClient] deviceInfoUpdate_1:[SNGlobalInfo instance].userInfo devicInfo:self.cameraInfo CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            NSMutableArray *mar_device = [SNGlobalInfo instance].userInfo.mar_camera;
            for (int i = 0; i < mar_device.count; i++) {
                SNCameraInfo *camera = mar_device[i];
                if ([camera.sDeviceId isEqualToString:self.cameraInfo.sDeviceId]) {
                    camera.sDeviceName = tf_deviceName.text;
                    SNUserInfo *user = [SNGlobalInfo instance].userInfo;
                    [HDUtility saveUserInfo:user];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MAIN_VIEW_REFRESH object:nil];
                    break;
                }
            }
        }else{
            [HDUtility sayAfterFail:@"提交失败"];
        }
        [self doCancel:nil];
    }];
}

- (IBAction)doCancel:(id)sender{
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_ADD_DEVICE_CANCEL object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MAIN_VIEW_REFRESH object:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self doComplete:nil];
    return YES;
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [tf_deviceName resignFirstResponder];
}
@end
