//
//  SNAccFriendViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-25.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNAccFriendViewCtr.h"
#import "SNHttpUtility.h"

@interface SNAccFriendViewCtr ()<UITextFieldDelegate>{

    IBOutlet UITextField    *tf_friend;
    MBProgressHUD           *hud_addFriend;
    
}

@end

@implementation SNAccFriendViewCtr

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
    //v_sub.frame = CGRectMake(25, 135, CGRectGetWidth(v_sub.frame), CGRectGetHeight(v_sub.frame));
    [_v_sub setCenter:self.view.center];
    _v_sub.frame = CGRectMake(CGRectGetMinX(_v_sub.frame), CGRectGetMinY(_v_sub.frame)+(IS_4INCH_SCREEN? 20: -20), CGRectGetWidth(_v_sub.frame), CGRectGetHeight(_v_sub.frame));
    [self.view addSubview:_v_sub];
    UIColor *color      = [UIColor grayColor];
    [tf_friend  setValue:color     forKeyPath:@"_placeholderLabel.textColor"];
    [tf_friend  setValue:[UIFont   fontWithName:@"Arial" size:15] forKeyPath:@"_placeholderLabel.font"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SEL
- (IBAction)doConfirm:(id)sender{
    [tf_friend resignFirstResponder];
    if (tf_friend.text.length <= 0) {
        [HDUtility say:@"请输入好友账号或昵称"];
        return;
    }
    hud_addFriend           = [[MBProgressHUD alloc] initWithView:self.view];
    hud_addFriend.labelText = @"正在添加...";
    [hud_addFriend show:YES];
    [self.view addSubview:hud_addFriend];
    [[SNHttpUtility sharedClient] addFriend_1:[SNGlobalInfo instance].userInfo account:tf_friend.text CompletionBlock:^(BOOL isSuccess, SNFriendInfo *fInfo, NSString *sMessage) {
        [hud_addFriend hide:YES];
        if (isSuccess) {
            NSMutableArray *mar = [SNGlobalInfo instance].userInfo.mar_friend;
            [mar addObject:fInfo];
            BOOL isSuc = [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
            if (!isSuc) {
                Dlog(@"保存失败");
            }else{
                [HDUtility sayAfterSuccess:@"添加好友成功"];
            }
            
            //更新摄像头列表
            [[SNHttpUtility sharedClient] referDevice_1:[SNGlobalInfo instance].userInfo deviceType:SNDeviceTypeCamera CompletionBlock:^(BOOL isSuccess, NSArray *ar_cameraInfo, NSString *sMessage) {
                if (isSuccess) {
                    [[SNGlobalInfo instance].userInfo.mar_camera removeAllObjects];
                    [SNGlobalInfo instance].userInfo.mar_camera = [[NSMutableArray alloc] initWithArray:ar_cameraInfo];
                    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
                }else{
                    [HDUtility say:sMessage];
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FRIEND_ADD object:nil];
        }else{
            [HDUtility say:sMessage];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self doConfirm:nil];
    return YES;
}

#pragma mark - touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [tf_friend resignFirstResponder];
}
@end
