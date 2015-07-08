//
//  SNGlobalInfo.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-25.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNUserInfo.h"
#import "AppDelegate.h"

@interface SNGlobalInfo : NSObject{

}

@property (strong) SNUserInfo       *userInfo;
@property (strong) UIViewController *controller;
@property (strong) AppDelegate      *appDelegate;

+ (SNGlobalInfo *)instance;


@end
