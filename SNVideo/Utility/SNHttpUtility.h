//
//  SNHttpUtility.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-22.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNInstance.h"
#import "AFJsonRequestOperation.h"
#import "AFHTTPClient.h"
#import "SNUserInfo.h"
#import "MBProgressHUD.h"
#import "SNCameraInfo.h"
#import "SNPicketInfo.h"
#import "SNServer.h"
#import "SNMessageInfo.h"
#import "SNEventInfo.h"
#import "SNEventReport.h"

@interface SNHttpUtility : AFHTTPClient{

    MBProgressHUD *HUD;
}

+ (SNHttpUtility *)sharedClient;
//服务器列表
+ (SNHttpUtility *)severClient;
//请求图片
+ (SNHttpUtility *)requestImageWithURL:(NSString *)url;

/** 获取进行通信的服务器地址列表 **/
- (void)getServerAddsTableWithUser_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, SNServerInfo *serverInfo,  NSString *sMessage))completionBlock;

/** 获取短信验证码 **/
- (void)getMessageCode_1:(SNUserInfo *)user phone:(NSString *)phone tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, NSString *msgCode, NSString *sMessage))completionBlock;

/** 软件版本更新检查 **/
- (void)checkVersion_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, SNPicketInfo *picket,  NSString *sMessage))completionBlock;

/** 申请用户注册 **/
- (void)applicationUserRegistration_1:(SNUserInfo *)user phone:(NSString *)phone CompletionBlock:(void (^)(BOOL isSuccess, NSString *tranID, NSString *msgCode,  NSString *sMessage))completionBlock;

/** 用户注册 **/
- (void)userRegistration_1:(SNUserInfo *)user account:(NSString *)acnt password:(NSString *)pwd messageCode:(NSString *)msgCode tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, NSString *userID, SNRegisterType regType,  NSString *sMessage))completionBlock;

/** 用户登录 **/
- (void)userLoginWithAccount_1:(NSString *)acnt password:(NSString *)pwd tocke:(NSString *)sTocken CompletionBlock:(void (^)(BOOL isSuccess, SNUserInfo *userInfo,  NSString *sMessage))completionBlock;

/** 修改用户信息 **/
- (void)userInfoUpdate_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 修改用户头像 **/
- (void)userImageHeadUpdate_1:(SNUserInfo *)user image:(UIImage *)imgData imageName:(NSString *)iName CompletionBlock:(void (^)(BOOL isSuccess, NSString *sUrl, NSString *sMessage))completionBlock;

/** 修改密码 **/
- (void)passwordUpdate_1:(SNUserInfo *)user oldPassword:(NSString *)oPwd newPassword:(NSString *)nPwd CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 申请找回密码 **/
- (void)applicationFindPassword_1:(SNUserInfo *)user phone:(NSString *)phone CompletionBlock:(void (^)(BOOL isSuccess, NSString *sTranID, NSString *msgCode, NSString *sMessage))completionBlock;

/** 找回方式重置密码 **/
- (void)passwordUpadteOfFind_1:(SNUserInfo *)user tranID:(NSString *)tID password:(NSString *)pwd messageCode:msgCode CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 用户注销 **/
- (void)userLogout_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 心跳包协议（获取状态变更） **/
- (void)heartBeat_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 申请设备注册 **/
- (void)applicationDeviceRegist_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *tranID, NSString *sMessage))completionBlock;

/** 获取最新添加的设备 **/
- (void)getDeviceForNewAdd_1:(SNUserInfo *)user tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, SNCameraInfo *cInfo, NSString *sMessage))completionBlock;

/** 修改设备信息 **/
- (void)deviceInfoUpdate_1:(SNUserInfo *)user devicInfo:(SNCameraInfo *)dInfo CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 申请删除设备 **/
- (void)applicationDeleteDevice_1:(SNUserInfo *)user devicID:(NSString *)dID CompletionBlock:(void (^)(BOOL isSuccess, NSString *tranID, NSString *msgCode, NSString *sMessage))completionBlock;

/** 手机端删除设备 **/
- (void)deleteDevice_1:(SNUserInfo *)user devicID:(NSString *)dID messageCode:(NSString *)msgCode tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 查询设备列表 **/
- (void)referDevice_1:(SNUserInfo *)user deviceType:(SNDeviceType)dType CompletionBlock:(void (^)(BOOL isSuccess, NSArray *ar_cameraInfo, NSString *sMessage))completionBlock;

/** 查询好友列表 **/
- (void)referFriend_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayFriend, NSString *sMessage))completionBlock;

/** 添加好友 **/
- (void)addFriend_1:(SNUserInfo *)user account:(NSString *)act CompletionBlock:(void (^)(BOOL isSuccess, SNFriendInfo *fInfo, NSString *sMessage))completionBlock;

/** 删除好友 **/
- (void)deleteFriend_1:(SNUserInfo *)user account:(NSString *)act CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 获取相片列表 **/
- (void)getPhotoList_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSArray *ar_list, NSString *sMessage))completionBlock;

/** 上传相片 **/
- (void)importPhoto_1:(SNUserInfo *)user pInfo:(SNPhotoInfo *)pInfo image:(UIImage *)img CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 删除相片 **/
- (void)deletePhoto_1:(SNUserInfo *)user photoID:(NSString *)pID CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock;

/** 查询消息列表 **/
- (void)referMessage_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayMessage, NSString *sMessage))completionBlock;

/** 开始下载图片 **/
- (void)requestStart_1WithCompletionBlock:(void (^)(BOOL isSuccess, UIImage *img, NSString *sMessage))completionBlock;

/** 查询事件列表 **/
- (void)getEvents:(SNUserInfo *)user deviceID:(NSString *)dID eventTypeID:(NSString *)eType start:(int)start limit:(int)limit startTime:(NSDate *)startTime endTime:(NSDate *)endTime CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayEvents, NSString *sMessage))completionBlock;

/** 查看事件视频 **/
- (void)getEventVideoURL:(SNUserInfo *)user eventID:(NSString *)eID CompletionBlock:(void (^)(BOOL isSuccess, NSString *videoURL, NSString *sMessage))completionBlock;

/** 查看事件报告 **/
- (void)getEventReport:(SNUserInfo *)user deviceID:(NSString *)dID date:(NSDate *)date CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayReports, NSString *sMessage))completionBlock;

/** 查询所有事件设置列表 **/
- (void)getEventSettingListCompletionBlock:(void (^)(BOOL isSuccess, NSArray *arList, NSString *sMessage))completionBlock;
@end
