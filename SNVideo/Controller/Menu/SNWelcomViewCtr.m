//
//  SNWelcomViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-18.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNWelcomViewCtr.h"
#import "Reachability.h"
#import "SNMainViewCtr.h"
#import "SNSignViewCtr.h"
#import "SNNavigationController.h"
#import "SNLoginViewCtr.h"

#import "HDUtility.h"

@interface SNWelcomViewCtr (){

    
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation SNWelcomViewCtr

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.navigationController.navigationBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated{

    //获取服务器列表
    [[SNHttpUtility severClient] getServerAddsTableWithUser_1:nil CompletionBlock:^(BOOL isSuccess, SNServerInfo *serverInfo, NSString *sMessage) {
        if (isSuccess) {
            [self startUseing];
        }else{
            SNServerInfo *sInfo = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
            if (sInfo) {
                [self startUseing];
            }else{
                [HDUtility say:sMessage];
                return;
            }
        }
    }];
}
- (void)startUseing{

    //获取登录信息，如果之前登录过，读取登录信息并登录，如果没有跳转登录界面
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    if (![SNGlobalInfo instance].userInfo) {
        Dlog(@"严重错误：登录用户为空！");
        return;
    }
    if (user) {
        if (user.sSessionId.length > 0 && user.registerType != SNRegisterTypeImei) {
            [SNGlobalInfo instance].userInfo = user;
            SNHttpUtility *httpUtility = [SNHttpUtility sharedClient];
            if (!httpUtility) {
                [self presentViewController:[SNLoginViewCtr new] animated:YES completion:nil];
                return;
            }
            [httpUtility userLoginWithAccount_1:user.sPhone password:user.sPassword tocke:[HDUtility readTocken] CompletionBlock:^(BOOL isSuccess, SNUserInfo *userInfo, NSString *sMessage) {
                if (isSuccess) {
                    userInfo.sPassword                  = user.sPassword;
                    [SNGlobalInfo instance].userInfo    = userInfo;
                    if (![HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo]) {
                        Dlog(@"保存用户信息失败");
                    }
                    Dlog(@"用户Info = %@", [SNGlobalInfo instance].userInfo);
                    RESideMenu *sideMenu = [SNWelcomViewCtr newMenuController];
                    [self presentViewController:sideMenu animated:YES completion:nil];
                    [[SNGlobalInfo instance].appDelegate startHaretRequest];
                }else{
                    SNLoginViewCtr *loginViewCtr = [[SNLoginViewCtr alloc] init];
                    [self presentViewController:loginViewCtr animated:YES completion:nil];
                }
            }];
        }else{
            SNLoginViewCtr *loginViewCtr    = [[SNLoginViewCtr alloc] init];
            [self presentViewController:loginViewCtr animated:YES completion:nil];
        }
        
        
    }else{
        SNSignViewCtr *signViewCtr = [[SNSignViewCtr alloc] init];
        [self presentViewController:signViewCtr animated:YES completion:nil];
    }
    sleep(1);
}

+ (RESideMenu *)newMenuController{
    SNMainViewCtr *ctr = [[SNMainViewCtr alloc] init];
    SNNavigationController *nav             = [[SNNavigationController alloc] initWithRootViewController:ctr];
    [SNGlobalInfo instance].controller      = nav;
    SNMenuViewCtr *leftMenuctr              = [[SNMenuViewCtr alloc] init];
    RESideMenu *sideMenuCtr                 = [[RESideMenu alloc] initWithContentViewController:nav
                                                                         leftMenuViewController:leftMenuctr
                                                                        rightMenuViewController:nil];
    sideMenuCtr.backgroundImage             = [UIImage imageNamed:@"back.png"];
    sideMenuCtr.menuPreferredStatusBarStyle = 1;
    sideMenuCtr.contentViewShadowColor      = [UIColor blackColor];
    sideMenuCtr.contentViewShadowOffset     = CGSizeMake(0, 0);
    sideMenuCtr.contentViewShadowOpacity    = 0.6;
    sideMenuCtr.contentViewShadowRadius     = 12;
    sideMenuCtr.contentViewShadowEnabled    = YES;
    return sideMenuCtr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
