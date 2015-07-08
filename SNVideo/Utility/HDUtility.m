//
//  HDUtility.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-6.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "HDUtility.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CommonCrypto/CommonDigest.h"
#import "Reachability.h"
#import "KeychainItemWrapper.h"

@implementation HDUtility

+(NSDictionary *)getConectedWIFI{

    NSDictionary *dic = [[NSDictionary alloc] init];
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    
    id info = nil;
    
    for (NSString *ifnam in ifs) {
        
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        NSLog(@"%@ => %@", ifnam, info);  //单个数据info[@"SSID"]; info[@"BSSID"];
        
        if (info && [info count]) {
            dic = (NSDictionary *)info;
            return dic;
        }
    }
    
    return nil;
}

+ (void)mbSay:(NSString *)sMsg{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kWindow animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = sMsg;
	hud.margin = 10.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1.0f];
}

+ (MBProgressHUD *)sayAfterSuccess:(NSString *)s{
    MBProgressHUD *HUD  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow ];
    HUD.customView      = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
    HUD.mode            = MBProgressHUDModeCustomView;
    HUD.labelText       = s;
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0f];
    return HUD;
}
+ (MBProgressHUD *)sayAfterFail:(NSString *)s{
    MBProgressHUD *HUD  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow ];
    HUD.customView      = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail.png"]];
    HUD.mode            = MBProgressHUDModeCustomView;
    HUD.labelText       = s;
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0f];
    return HUD;
}
+ (void)say:(NSString *)sMsg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"prompt") message:sMsg delegate:self cancelButtonTitle:LS(@"confirm") otherButtonTitles:nil, nil];
    [alert show];
}

+ (UIAlertView *)say:(NSString *)sMsg Delegate:(id)delegate_{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"prompt") message:sMsg delegate:delegate_ cancelButtonTitle:LS(@"confirm") otherButtonTitles:nil, nil];
    [alert show];
    return alert;
}
+ (UIAlertView *)say2:(NSString *)sMsg Delegate:(id)delegate_{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"prompt") message:sMsg delegate:delegate_ cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    return alert;
}
+ (void)circleTheView:(UIView *)view{
    if (view.frame.size.height != view.frame.size.width) {
        Dlog(@"view不是正方形！");
        return;
    }
    view.layer.cornerRadius     = CGRectGetHeight(view.frame)/2;
    view.layer.masksToBounds    = YES;
    view.layer.borderWidth      = 1.0f;
    view.layer.borderColor      = [UIColor whiteColor].CGColor;
}
+ (void)circleWithNoBorder:(UIView *)view{
    if (view.frame.size.height != view.frame.size.width) {
        Dlog(@"view不是正方形！");
        return;
    }
    view.layer.cornerRadius     = CGRectGetHeight(view.frame)/2;
    view.layer.masksToBounds    = YES;
}

+ (void)rotateView:(UIView *)view angle:(float)angle{

    CALayer *layer = view.layer;
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.5f;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.values = [NSArray arrayWithObjects:   	// i.e., Rotation values for the 3 keyframes, in RADIANS
                        [NSNumber numberWithFloat:0.0 * M_PI],
                        [NSNumber numberWithFloat:angle],
                        nil];
    animation.keyTimes = [NSArray arrayWithObjects:     // Relative timing values for the 3 keyframes
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:.3],
                          nil];
    animation.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],	// from keyframe 1 to keyframe 2
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];	// from keyframe 2 to keyframe 3
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:nil];
}

//是否网络可用
+ (BOOL)isEnableNetwork{

    return ([[Reachability reachabilityWithHostName:@"www.baidu.com"] currentReachabilityStatus] != NotReachable);
}
//是否WIFI
+ (BOOL)isEnableWIFI{
    return([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}
// 是否3G
+ (BOOL)isEnable3G{
    return([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable && ![HDUtility isEnableWIFI]);
}

//Unix时间戳
+ (NSString *)UnixTime{

    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%.0f",time];
    return strTime;
}

//MD5加密
+(NSString *)md5:(NSString *)inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}
+ (BOOL)isValidateName:(NSString *)name{
    if (name.length >= MIN_LENTH_NAME && name.length <= MAX_LENTH_NAME) {
        return YES;
    }
    return NO;
}

/*邮箱验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateEmail:(NSString *)email{
    
    NSString *emailRegex    = @"^\\s*\\w+(?:\\.{0,1}[\\w-]+)*@[a-zA-Z0-9]+(?:[-.][a-zA-Z0-9]+)*\\.[a-zA-Z]+\\s*$";
    NSPredicate *emailTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/*手机号码验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateMobile:(NSString *)mobile{
    if ([mobile hasPrefix:@"1"] && [mobile length] == 11) {
        return YES;
    }
    return NO;
}

/*车牌号验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateCarNo:(NSString *)carNo{
    NSString *carRegex      = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

+ (BOOL)isValidatePassword:(NSString *)sPwd{
    if (sPwd.length < MIN_LENTH_PASSWORD || sPwd.length > MAX_LENTH_PASSWORD) {
        return NO;
    }
    return YES;
}

+ (BOOL)isValidateAccount:(NSString *)s{
    //^[a-zA-Z0-9]+$
//    emoji表情的Unicode编码范围为：
//    [0xE001,0xE05A]
//    [0xE101,0xE15A]
//    [0xE201,0xE253]
//    [0xE301,0xE34D]
//    [0xE401,0xE44C]
//    [0xE501,0xE537]
    NSString *carRegex      = @"^[a-zA-Z0-9\u4e00-\u9fa5\ue001-\ue537]+$";
    NSPredicate *carTest    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:s];
    
}
/** 关于date **/
+ (NSString *)readNowTimeWithFormate:(NSString *)yyyyMMddhhmmss{
    
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter	setDateFormat:yyyyMMddhhmmss];//yyyyMMddhhmmss
	NSString *sTime=[formatter stringFromDate: [NSDate date]];
    
	return sTime;
}

+ (NSString *)converDate2String:(NSDate *)date withFormat:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter	setDateFormat:format];//yyyyMMddhhmmss
	NSString *sTime=[formatter stringFromDate: date];
    
	return sTime;
    
}

+ (NSString *)formatterDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter	setDateFormat:@"YYYY-MM-DD"];
	NSString *sTime=[formatter stringFromDate:date];
    
	return sTime;
    
}

+ (NSDate *)convertDateFromString:(NSString*)sDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"YYYY-MM-DD"];
    NSDate *date=[formatter dateFromString:sDate];
    
    return date;
}

/** 数据本地存取 **/
+ (BOOL)saveTocken:(NSString *)sToken{
    if (!sToken) {
        Dlog(@"传入参数有误！");
        return false;
    }
    
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    [defalt setObject:sToken forKey:@K_LOGIN_USER_TOCKEN];
    return YES;
}
+ (NSString *)readTocken{

    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSString *sToken = [defalt objectForKey:@K_LOGIN_USER_TOCKEN];
    
    return sToken;
}
+ (BOOL)saveWifiS:(NSMutableArray *)ar{
    if (ar.count <= 0) {
        return YES;
    }
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    [defalt setObject:[NSMutableArray new] forKey:KEY_WIFI];
    [defalt synchronize];
    for (int i = 0; i < ar.count; i++) {
        [HDUtility saveWifiInfo:ar[i]];
    }
    return YES;
}
+ (BOOL)saveWifiInfo:(SNWIFIInfo *)wifi{
    if (!wifi) {
        Dlog(@"传入参数有误！");
        return false;
    }
    NSDictionary *dic_wifi  = [wifi dictionaryValue];
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar     = [[NSMutableArray alloc] initWithArray:[defalt objectForKey:KEY_WIFI]];
    if (mar == nil) {
        mar = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < mar.count; i++) {
        NSDictionary *d = mar[i];
        if ([d[@K_WIFI_SSID] isEqualToString:dic_wifi[@K_WIFI_SSID]]) {
            [mar removeObjectAtIndex:i];
            break;
        }
    }
    [mar addObject:dic_wifi];
    [defalt setObject:mar forKey:KEY_WIFI];
    [defalt synchronize];
    return true;
}

+ (BOOL)saveUserInfo:(SNUserInfo *)userInfo{

    if (!userInfo) {
        Dlog(@"传入参数有误！");
        return false;
    }
    NSDictionary *dic_user  = [userInfo dictionaryValue];
    if (!dic_user) {
        Dlog(@"数据转换出错！");
        return false;
    }
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar     = [[NSMutableArray alloc] initWithArray:[defalt objectForKey:@LOGIN_USER]];
    if (mar == nil) {
        mar = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < mar.count; i++) {
        NSDictionary *d = mar[i];
        if ([d[@K_LOGIN_USER_PHONE] isEqualToString:dic_user[@K_LOGIN_USER_PHONE]]) {
            [mar removeObjectAtIndex:i];
            break;
        }
    }
    [mar insertObject:dic_user atIndex:0];
    [defalt setObject:mar forKey:@LOGIN_USER];
    [defalt synchronize];
    [HDUtility saveWifiS:userInfo.mar_wifi];//保存wifi
    return true;
}

+ (BOOL)saveSeverInfo:(SNServerInfo *)sInfo
{
    if (!sInfo) {
        Dlog(@"传入参数有误！");
        return false;
    }
    NSDictionary *dic_user  = [sInfo dictionaryValue];
    if (!dic_user) {
        Dlog(@"数据转换出错！");
        return false;
    }
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    [defalt setObject:dic_user forKey:@SEVER_INFO];
    [defalt synchronize];
    return true;
}

+ (BOOL)savePhotoInfo:(SNPhotoInfo *)pInfo
{
    if (!pInfo) {
        Dlog(@"传入参数有误！");
        return false;
    }
    NSDictionary *dic_user  = [pInfo dictionaryValue];
    if (!dic_user) {
        Dlog(@"数据转换出错！");
        return false;
    }
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    NSString *sKey = [NSString stringWithFormat:@"%@_%@", @USER_PHOTO, user.sUserId];
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar     = [[NSMutableArray alloc] initWithArray:[defalt objectForKey:sKey]];
    BOOL newFig = YES;
    for (int i = 0; i < mar.count; i++) {
        NSDictionary *d = mar[i];
        if ([d[@K_PHOTO_NAME] isEqualToString:dic_user[@K_PHOTO_NAME]]) {
            [mar removeObjectAtIndex:i];
            [mar insertObject:dic_user atIndex:i];
            newFig = NO;
            break;
        }
    }
    
    if (newFig) {
        [mar insertObject:dic_user atIndex:0];
    }
    
    [defalt setObject:mar forKey:sKey];
    [defalt synchronize];
    return true;
}

+ (BOOL)removePhotoInfo:(SNPhotoInfo *)pInfo
{
    if (!pInfo) {
        Dlog(@"传入参数有误！");
        return false;
    }
    NSDictionary *dic_user  = [pInfo dictionaryValue];
    if (!dic_user) {
        Dlog(@"数据转换出错！");
        return false;
    }
    
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    NSString *sKey = [NSString stringWithFormat:@"%@_%@", @USER_PHOTO, user.sUserId];
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar     = [[NSMutableArray alloc] initWithArray:[defalt objectForKey:sKey]];
    if (mar == nil) {
        Dlog(@"没有可删除数据！");
        return false;
    }
    for(int i = 0; i < mar.count; i++)
    {
        NSDictionary *d = mar[i];
        if ([d[@K_PHOTO_NAME] isEqualToString:dic_user[@K_PHOTO_NAME]]) {
            [mar removeObjectAtIndex:i];
            break;
        }
    }
    [defalt setObject:mar forKey:sKey];
    [defalt synchronize];
    
    return true;
}

+ (SNUserInfo *)readLocalUserInfo{

    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar     = [[NSMutableArray alloc] initWithArray:[defalt objectForKey:@LOGIN_USER]];
    if (mar.count <= 0) {
        Dlog(@"无登录用户信息");
        return nil;
    }
    SNUserInfo *userInfo                = [[SNUserInfo alloc] init];
    userInfo                            = [SNUserInfo userInfoWithDictionary:mar[0]];
    [SNGlobalInfo instance].userInfo    = userInfo;
    if (!userInfo) {
        Dlog(@"数据转换出错！");
        return nil;
    }
    userInfo.mar_wifi                   = [[NSMutableArray alloc] init];
    NSMutableArray *mar_wifi            = [HDUtility readLocalWifiInfo];
    for (int i = 0; i < mar_wifi.count; i++) {
        SNWIFIInfo *info = [SNWIFIInfo wifiInfoWithDictionary:mar_wifi[i]];
        [userInfo.mar_wifi addObject:info];
    }
    return userInfo;
}

+ (NSMutableArray *)readLocalWifiInfo{
    
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar     = [[NSMutableArray alloc] initWithArray:[defalt objectForKey:KEY_WIFI]];
    if (!mar) {
        mar = [[NSMutableArray alloc] init];
    }
    return mar;
}

+ (NSArray *)readPhotoInfo{
    
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    NSString *sKey = [NSString stringWithFormat:@"%@_%@", @USER_PHOTO, user.sUserId];
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar     = [[NSMutableArray alloc] initWithArray:[defalt objectForKey:sKey]];
    Dlog(@"USER_PHOTO = %@", @USER_PHOTO);
    if (!mar) {
        mar = [[NSMutableArray alloc] init];
    }
    //按时间排序
    NSArray *ar_t       = [mar sortedArrayUsingComparator:^NSComparisonResult(UIImageView *obj1, UIImageView *obj2) {
        NSString *time1 = [[obj1 valueForKey:@K_PHOTO_TIME] stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSString *time2 = [[obj2 valueForKey:@K_PHOTO_TIME] stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        if ([time1 intValue] > [time2 intValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([time1 intValue] < [time2 intValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return ar_t;
}

+ (NSDictionary *)readSeverInfo{
    NSUserDefaults *defalt  = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic       = [[NSDictionary alloc] initWithDictionary:[defalt objectForKey:@SEVER_INFO]];
    
    return dic;
}

/** 动画 **/
+ (void)view:(UIView *)view appearAt:(CGPoint)location withDalay:(CGFloat)delay duration:(CGFloat)duration{
    view.center                         = location;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration             = duration;
    scaleAnimation.values               = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.15, 1.15, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    scaleAnimation.calculationMode      = kCAAnimationLinear;
    scaleAnimation.keyTimes             = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:delay],[NSNumber numberWithFloat:1.0f]];
    view.layer.anchorPoint              = CGPointMake(0.5f, 0.5f);
    [view.layer addAnimation:scaleAnimation forKey:@"buttonAppear"];

}

+ (void)showView:(UIView *)view centerAtPoint:(CGPoint)pos duration:(CGFloat)waitDuration{
    view.center = pos;
    CABasicAnimation *forwardAnimation  = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    forwardAnimation.duration           = waitDuration;
    forwardAnimation.timingFunction     = [CAMediaTimingFunction functionWithControlPoints:0.5f :1.7f :0.6f :0.85f];
    forwardAnimation.fromValue          = [NSNumber numberWithFloat:0.0f];
    forwardAnimation.toValue            = [NSNumber numberWithFloat:1.0f];
    CAAnimationGroup *animationGroup    = [CAAnimationGroup animation];
    animationGroup.animations           = [NSArray arrayWithObjects:forwardAnimation, nil];
    animationGroup.delegate             = self;
    animationGroup.duration             = forwardAnimation.duration;
    animationGroup.removedOnCompletion  = NO;
    animationGroup.fillMode             = kCAFillModeForwards;
    
    [UIView animateWithDuration:animationGroup.duration
                          delay:0.0
                        options:0
                     animations:^{
                         [view.layer addAnimation:animationGroup
                                           forKey:@"kLPAnimationKeyPopup"];
                     }
                     completion:^(BOOL finished) {
                     }];
}
+ (void)hideView:(UIView *)view duration:(CGFloat)waitDuration{
    
    CABasicAnimation *reverseAnimation      = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    reverseAnimation.duration               = 0.3;
    reverseAnimation.beginTime              = 0;
    reverseAnimation.timingFunction         = [CAMediaTimingFunction functionWithControlPoints:0.4f :0.15f :0.5f :-0.7f];
    reverseAnimation.fromValue              = [NSNumber numberWithFloat:1.0f];
    reverseAnimation.toValue                = [NSNumber numberWithFloat:0.0f];
    reverseAnimation.removedOnCompletion    = YES;
    [view.layer addAnimation:reverseAnimation forKey:@"1111"];
}

//截屏
+ (UIImage *)screenshotFromView:(UIView *)theView{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

//获得某个范围内的屏幕图像
+ (UIImage *)screenshotFromView: (UIView *)theView atFrame:(CGRect)r{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [theView.layer renderInContext:context];
    UIImage *theImage       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}

/*下载图片*/
+ (NSString *)imageWithUrl:(NSString *)sUrl savedFolderName:(NSString *)sFolder savedFileName:(NSString *)sFile{
    if (sUrl.length <= 0) {
        return nil;
    }
    NSString *sImagename    = [sUrl lastPathComponent];
    NSString *sPath         = [HDUtility pathOfSavedImageName:sFile? sFile: sImagename folderName:sFolder];
    NSFileManager *fileMng  = [NSFileManager defaultManager];
    if ([fileMng fileExistsAtPath:sPath]) {
        Dlog(@"该文件已存在");
        return sPath;
    }
    UIImage *image          = [HDUtility imageWithUrl:sUrl];
    BOOL isSuc              = [HDUtility saveToDocument:image withFilePath:sPath];
    if (!isSuc) {
        return nil;
    }
    return sPath;
}

//从网络获取图片
+ (UIImage *)imageWithUrl:(NSString *)sUrl{
    if (sUrl.length <= 0) {
        return nil;
    }
    NSURL *url      = [NSURL URLWithString:sUrl];
    UIImage *image  = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    if (!image) {
        Dlog(@"图片下载失败，URL：%@", sUrl);
    }
    return image;
}

//将选取的图片保存到沙盒目录文件夹下
+ (BOOL)saveToDocument:(UIImage *)image withFilePath:(NSString *)filePath
{
    if ((image == nil) || (filePath == nil) || [filePath isEqualToString:@""]) {
        Dlog(@"传入参数不能为空！");
        return NO;
    }
    
    @try {
        NSData *imageData = nil;
        NSString *extention = [filePath pathExtension];
        if ([extention isEqualToString:@"png"]) {
            imageData = UIImagePNGRepresentation(image);
        }else{
            imageData = UIImageJPEGRepresentation(image, 0);
        }
        if (imageData == nil || [imageData length] <= 0) {
            Dlog(@"imageData为空，保存失败");
            return NO;
        }
        [imageData writeToFile:filePath atomically:YES];
        return  YES;
    }
    @catch (NSException *exception) {
        NSLog(@"保存图片失败");
    }
    
    return NO;
    
}

//获取将要保存的图片路径
+ (NSString *)pathOfSavedImageName:(NSString *)imageName folderName:(NSString *)sFolder
{
    NSArray *path               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath      = [path objectAtIndex:0];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSString *imageDocPath      = [documentPath stringByAppendingPathComponent:FORMAT(@"%@/%@", [SNGlobalInfo instance].userInfo.sUserId, sFolder)];
    [fileManager createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //返回保存图片的路径（图片保存在ImageFile文件夹下）
    NSString * imagePath = [imageDocPath stringByAppendingPathComponent:imageName];
    return imagePath;
}

+ (BOOL)removeFileWithPath:(NSString *)path
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isRet = [fileMgr fileExistsAtPath:path];
    if (isRet) {
        NSError *err;
        BOOL removFig = [fileMgr removeItemAtPath:path error:&err];
        return removFig;
    }
    return isRet;
}
+ (NSString*)uuid {
    UIDevice *device = [UIDevice currentDevice];
    return device.identifierForVendor.UUIDString;
}

+ (void)SessionTimeOut{
    
    SNUserInfo *userInfo    = [SNGlobalInfo instance].userInfo;
    userInfo.sSessionId     = nil;
    [HDUtility saveUserInfo:userInfo];
    [[SNGlobalInfo instance].appDelegate stopHaretRequest];
    for (UIView *v in kWindow.subviews) {
        [v removeFromSuperview];
    }
    [kWindow setRootViewController:[[SNLoginViewCtr alloc] init]];
}

@end
