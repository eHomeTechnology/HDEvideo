//
//  AppDelegate.m
//  SNVideo
//
//  Created by apple on 14-7-29.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "AppDelegate.h"
#import "SNWelcomViewCtr.h"
#import "Reachability.h"
#import "HDUtility.h"
#import "HDInstance.h"
#import "SNMsgCenterViewCtr.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //这里处理应用程序如果没有启动,但是是通过通知消息打开的,此时可以获取到消息.
    if (launchOptions != nil) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        Dlog(@"userInfo = %@", userInfo);
    }
    
    [[UIApplication sharedApplication ] setApplicationIconBadgeNumber:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *remoteHostName    = @"www.baidu.com";
    self.hostReachability       = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //注册推送
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    NSString *sUUID = [HDUtility uuid];
    Dlog(@"sUUID = %@", sUUID);
    [NSThread detachNewThreadSelector:@selector(UMSetup) toTarget:self withObject:nil];
    SNWelcomViewCtr *ctr = [[SNWelcomViewCtr alloc] init];
    [self.window setRootViewController:ctr];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [SNGlobalInfo instance].appDelegate = self;
    return YES;
}
- (void)UMSetup{
    /*打开调试log的开关*/
    [UMSocialData openLog:YES];
    /*如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向*/
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    /*设置友盟社会化组件appkey*/
    [UMSocialData setAppKey:@UmengAppkey];
    /*设置微信AppId，设置分享url，默认使用友盟的网址*/
    [UMSocialWechatHandler setWXAppId:@"wxd930ea5d5a258f4f" appSecret:@"db426a9829e4b49a0dcac7b4162da6b6" url:@"http://www.ifeng.com"];
    /*打开新浪微博的SSO开关*/
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    /*设置分享到QQ空间的应用Id，和分享url 链接*/
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.163.com"];
    /*设置支持没有客户端情况下使用SSO授权*/
    [UMSocialQQHandler setSupportWebView:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)reachabilityChanged:(NSNotification *)note
{
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    if (curReach.currentReachabilityStatus == NotReachable) {
        [HDUtility mbSay:@"网络已断开，请重连！"];
    }else if(curReach.currentReachabilityStatus == ReachableViaWiFi){
        [HDUtility mbSay:@"已连接到WIFI网络"];
    }else if(curReach.currentReachabilityStatus == ReachableViaWWAN){
        [HDUtility mbSay:@"已连接到移动网络"];
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication ] setApplicationIconBadgeNumber:0];
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    if (user) {
        [SNGlobalInfo instance].userInfo = user;
    }
    /*检查版本更新*/
    return;
    NSDictionary *dic_server = [HDUtility readSeverInfo];
    if (dic_server.count == 0) {
        return;
    }
    [[SNHttpUtility sharedClient] checkVersion_1:[SNGlobalInfo instance].userInfo CompletionBlock:^(BOOL isSuccess, SNPicketInfo *picket, NSString *sMessage) {
        if (isSuccess) {
            switch (picket.iUpdate) {
                case SNWithOutUpdate:{
                    
                    break;
                }
                case SNNeedUpdate:{
                    alert_need  = [[UIAlertView alloc] initWithTitle:LS(@"prompt") message:@"检测到新的版本，去更新吗？" delegate:self cancelButtonTitle:@"更新" otherButtonTitles:@"取消", nil];
                    alert_need.delegate      = self;
                    [alert_need show];
                    break;
                }
                case SNMustUpdate:{
                    [HDUtility say:@"您的软件版本太低，请更新后继续使用" Delegate:self];
                    break;
                }
                default:
                    break;
            }
            
        }
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
    [SNGlobalInfo instance].userInfo = nil;
}


#pragma mark - uiapplication delegate

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *pushToken = [[[deviceToken description]
                            stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    Dlog(@"pushToken = %@", pushToken);
    [HDUtility saveTocken:pushToken];
    
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userInfo__ = %@",userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MAIN_HEART object:nil];
    
//    UINavigationController *nav = (UINavigationController *)[SNGlobalInfo instance].controller;
//    if (nav) {
//        SNMsgCenterViewCtr *ctr = [SNMsgCenterViewCtr new];
//        [nav pushViewController:ctr animated:YES];
//    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *appstoreUrlString = @"https://itunes.apple.com/cn/app/k-mi-quan-guoktv-dian-ge-yu-ding/id896914152?mt=8";
    NSURL *url                  = [NSURL URLWithString:appstoreUrlString];
    if ([alertView isEqual:alert_need]) {
        
        switch (buttonIndex) {
            case 0:{
                if ([[UIApplication sharedApplication] canOpenURL:url]){
                    [[UIApplication sharedApplication] openURL:url];
                }else{
                    NSLog(@"can not open"); 
                }
                return;
            }
            case 1:{
                
                return;
            }
            default:
                return;
        }
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }else{
        NSLog(@"can not open");
    }
    
}

#pragma mark - heart request
-(void)startHaretRequest
{
    timer_heart = [NSTimer scheduledTimerWithTimeInterval:20.0
                                                   target:self selector:@selector(heartRequest:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heartRequest:) name:@KEY_NOTI_MAIN_HEART object:nil];
}

-(void)stopHaretRequest
{
    [timer_heart invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_MAIN_HEART object:nil];
}

-(void)heartRequest:(NSTimer *)timer
{
    Reachability *rech = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if (rech.currentReachabilityStatus == NotReachable) {
        return;
    }
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    if (user) {
        [[SNHttpUtility sharedClient] heartBeat_1:user CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
            if (isSuccess) {
                [SNGlobalInfo instance].userInfo = [HDUtility readLocalUserInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MAIN_HEART_REFRESH object:nil];
            }
        }];
    }
    
}

@end
