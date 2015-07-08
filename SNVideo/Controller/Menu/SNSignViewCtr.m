//
//  SNSignViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-18.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNSignViewCtr.h"
#import "SNLoginViewCtr.h"
#import "SNRegisterViewCtr.h"
#import "SNMainViewCtr.h"
#import "SNWelcomViewCtr.h"

@interface SNSignViewCtr ()

@end

@implementation SNSignViewCtr

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"注册或登录";
}

#pragma mark SEL

-(IBAction)doUseImmediately:(id)sender{
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

-(IBAction)doLogin:(id)sender{
    SNLoginViewCtr *loginViewCtr = [[SNLoginViewCtr alloc] init];
    [self presentViewController:loginViewCtr animated:YES completion:nil];
}

-(IBAction)doRegister:(id)sender{

    SNRegisterViewCtr *registerViewCtr = [[SNRegisterViewCtr alloc] init];
    [self presentViewController:registerViewCtr animated:YES completion:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
