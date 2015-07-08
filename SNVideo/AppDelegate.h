//
//  AppDelegate.h
//  SNVideo
//
//  Created by apple on 14-7-29.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocialControllerService.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>{

    UIAlertView *alert_need;
    NSTimer     *timer_heart;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong)  Reachability *hostReachability;

-(void)startHaretRequest;
-(void)stopHaretRequest;

@end
