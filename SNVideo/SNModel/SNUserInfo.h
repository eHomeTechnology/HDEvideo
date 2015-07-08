//
//  SNUserInfo.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-21.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCameraInfo.h"
#import "SNFriendInfo.h"

typedef NS_ENUM(int, SNRegisterType) {
    SNRegisterTypeImei = 0, //注册类型为手机设备注册
    SNRegisterTypePhone,    //注册类型为手机号注册
};

#define K_LOGIN_USER_ID         "k_loginUserId"
#define K_LOGIN_USER_NAME       "k_loginUserName"
#define K_LOGIN_USER_PWD        "k_loginUserPwd"
#define K_LOGIN_USER_PHONE      "k_loginUserPhone"
#define K_LOGIN_USERTOCKEN      "k_tockeiPhone"
#define K_LOGIN_USER_SEX        "k_loginUserSex"
#define K_LOGIN_USER_BIRTHDAY   "k_loginUserBirthday"
#define K_LOGIN_USER_EMAIL      "k_loginUserEmail"
#define K_LOGIN_USER_HEADPATH   "k_loginUserPath"
#define K_LOGIN_USER_HEADURL    "k_loginUserHEADURL"
#define K_LOGIN_USER_SESSION    "k_loginUserSessionId"
#define K_LOGIN_USER_TOCKEN     "k_loginUserTocken"
#define K_LOGIN_USER_MESSAGE    "k_loginUserMessage"
#define K_LOGIN_USER_EVENT      "k_loginUserEvent"
#define K_LOGIN_USER_CAMERA     "k_loginUserCamera"
#define K_LOGIN_USER_WIFI       "k_loginUserWifi"
#define K_LOGIN_USER_FRIEND     "k_loginUserFriend"
#define K_LOGIN_USER_REGISTER   "k_loginUserRegister"
#define K_LOGIN_USER_EVENTTYPE  "k_loginUserEventType"

@interface SNUserInfo : NSObject

@property (strong) NSString         *sUserId;       //唯一标识
@property (strong) NSString         *sUserName;     //昵称
@property (strong) NSString         *sPassword;     //密码
@property (strong) NSString         *sPhone;        //手机号，即登录账号
@property (strong) NSString         *sSex;          //0:男，1:女
@property (strong) NSString         *sBirthday;     //YYYY-MM-DD
@property (strong) NSString         *sEmail;        //Email
@property (strong) NSString         *sHeadPath;     //头像本地路径
@property (strong) NSString         *sHeadUrl;      //头像网络地址
@property (strong) NSString         *sSessionId;    //会话id
@property (strong) NSString         *sUnreadEvent;  //未读事件标志位，0，没有；1，有
@property (strong) NSString         *sUnreadMessage;//未读消息标志位，0，没有；1，有
@property (strong) NSMutableArray   *mar_camera;    //摄像头队列
@property (strong) NSMutableArray   *mar_wifi;      //wifi队列
@property (strong) NSMutableArray   *mar_friend;    //好友队列
//1.1http协议新增
@property (assign) SNRegisterType   registerType;   //注册类型

//2.0http协议新增
/*
 mar_eventType如：
@[@{@"code":@"EP01",@"name":@"沉迷事件"},
  @{@"code":@"ES01",@"name":@"高分贝事件"},
  @{@"code":@"ES02",@"name":@"玻璃事件"},
]
 */
@property (strong) NSMutableArray   *mar_eventType; //事件类型

+ (SNUserInfo *)userInfoWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)dictionaryValue;
- (id)init;

@end
