//
//  HDUtility.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-6.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SNUserInfo.h"
#import "SNWIFIInfo.h"
#import "SNPhotoInfo.h"
#import "SNGlobalInfo.h"
#import "MBProgressHUD.h"
#import "SNServer.h"
#import "SNLoginViewCtr.h"

@interface HDUtility : NSObject

+ (NSDictionary *)getConectedWIFI;
+ (void)mbSay:(NSString *)sMsg;
+ (MBProgressHUD *)sayAfterSuccess:(NSString *)s;
+ (MBProgressHUD *)sayAfterFail:(NSString *)s;
+ (void)say:(NSString *)sMsg;
+ (UIAlertView *)say:(NSString *)sMsg Delegate:(id)delegate_;
+ (UIAlertView *)say2:(NSString *)sMsg Delegate:(id)delegate_;
+ (BOOL)isEnableNetwork;
+ (BOOL)isEnableWIFI;
+ (BOOL)isEnable3G;
+ (NSString *)UnixTime;
+ (NSString *)md5: (NSString *) inPutText;
+ (void)circleTheView:(UIView *)view;
+ (void)circleWithNoBorder:(UIView *)view;
+ (void)rotateView:(UIView *)view angle:(float)angle;

/** NSString验证合法性 **/
+ (BOOL)isValidateName:(NSString *)name;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isValidateMobile:(NSString *)mobile;
+ (BOOL)isValidateCarNo:(NSString *)carNo;
+ (BOOL)isValidatePassword:(NSString *)sPwd;
+ (BOOL)isValidateAccount:(NSString *)s;      //合法的不含特殊字符的字符串，通常用户账户，用户名等的验证
/** 时间date处理 **/
+ (NSString *)readNowTimeWithFormate:(NSString *)yyyyMMddhhmmss;
+ (NSString *)converDate2String:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *)formatterDate:(NSDate *)date;
+ (NSDate *)convertDateFromString:(NSString *)sDate;

/** 数据本地存取 **/
+ (BOOL)saveTocken:(NSString *)sToken;
+ (BOOL)saveWifiInfo:(SNWIFIInfo *)wifi;
+ (BOOL)saveUserInfo:(SNUserInfo *)userInfo;
+ (BOOL)savePhotoInfo:(SNPhotoInfo *)pInfo;
+ (BOOL)saveSeverInfo:(SNServerInfo *)sInfo;
+ (BOOL)removePhotoInfo:(SNPhotoInfo *)pInfo;
+ (SNUserInfo *)readLocalUserInfo;
+ (NSString *)readTocken;
+ (NSMutableArray *)readLocalWifiInfo;
+ (NSArray *)readPhotoInfo;
+ (NSDictionary *)readSeverInfo;

/** 动画 **/
+ (void)showView:(UIView *)view centerAtPoint:(CGPoint)pos duration:(CGFloat)waitDuration;
+ (void)hideView:(UIView *)view duration:(CGFloat)waitDuration;
+ (void)view:(UIView *)view appearAt:(CGPoint)location withDalay:(CGFloat)delay duration:(CGFloat)duration;

/** 截屏 **/
+ (UIImage *)screenshotFromView:(UIView *)theView;
+ (UIImage *)screenshotFromView: (UIView *) theView atFrame:(CGRect)r;

/** 头像图片处理相关 **/
+ (NSString *)imageWithUrl:(NSString *)sUrl savedFolderName:(NSString *)sFolder savedFileName:(NSString *)sFile;
+ (UIImage *)imageWithUrl:(NSString *)sUrl;
+ (BOOL)saveToDocument:(UIImage *) image withFilePath:(NSString *)filePath;
+ (NSString *)pathOfSavedImageName:(NSString *)imageName folderName:(NSString *)sFolder;

+ (BOOL)removeFileWithPath:(NSString *)path;

/** UUID **/
+ (NSString*)uuid;

/** 会话过期回到登录界面 **/
+ (void)SessionTimeOut;
@end





