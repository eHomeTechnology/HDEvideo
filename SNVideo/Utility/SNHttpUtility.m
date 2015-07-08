
//  SNHttpUtility.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-22.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNHttpUtility.h"
#import "HDUtility.h"
#import "SNBase64.h"
#import "Reachability.h"
#import "SNEventInfo.h"

@implementation SNHttpUtility

+ (SNHttpUtility *)sharedClient{
    Reachability *rech = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if (rech.currentReachabilityStatus == NotReachable) {
        [HDUtility say:@"当前网络不可用"];
        return nil;
    }
    static SNHttpUtility *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SNServerInfo *sInfo = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
        if (sInfo == nil) {
            [[self severClient] getServerAddsTableWithUser_1:nil CompletionBlock:^(BOOL isSuccess, SNServerInfo *serverInfo, NSString *sMessage) {
                if (isSuccess) {
                    SNServerInfo *sInfo_2 = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
                    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:sInfo_2.sHttp]];
                }else{
                    [HDUtility say:@"请求失败，请检查网络"];
                }
            }];
        }else{
            _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:sInfo.sHttp]];
        }
        
    });
    return _sharedClient;
}

+ (SNHttpUtility *)severClient{
    static SNHttpUtility *_severClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _severClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@HTTP_URL]];
    });
    return _severClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    HUD.labelText = @"网络加载中...";
    HUD.dimBackground = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    return self;
}

+ (SNHttpUtility *)requestImageWithURL:(NSString *)url
{
    static SNHttpUtility *_requestImg = nil;
    static dispatch_once_t onceToken;
    NSString *sURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    dispatch_once(&onceToken, ^{
        _requestImg = [[self alloc] initWithBaseURL:[NSURL URLWithString:sURL]];
    });
    return _requestImg;
}

#pragma mark --获取进行通信的服务器地址列表
- (void)getServerAddsTableWithUser_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, SNServerInfo *serverInfo,  NSString *sMessage))completionBlock
{
    NSString *sMd5 = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:@""], [HDUtility UnixTime]]];
    NSString *sHead = nil;
    if (user) {
        sHead = [NSString stringWithFormat:@"basic_query_serverlist:%@:%@:%@:%@:0", [HDUtility UnixTime], sMd5, user.sUserId, user.sSessionId];
    }else{
        sHead = [NSString stringWithFormat:@"basic_query_serverlist:%@:%@:::0", [HDUtility UnixTime], sMd5];
    }
    NSString *b64Head = [SNBase64 base64StringFromText:sHead];
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
            return;
        }
        NSString    *sRetMesg;
        SNServerInfo *sInfo = [[SNServerInfo alloc] init];
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *http_t        = [dic_data valueForKey:@"http"];
            NSString *rtsp_t        = [dic_data valueForKey:@"rtsp_real"];
            NSString *rtspBack_t    = [dic_data valueForKey:@"rtsp_back"];
            NSString *socket_t      = [dic_data valueForKey:@"socket"];
            NSString *p2p_t         = [dic_data valueForKey:@"p2p"];
            sInfo.sHttp             = FORMAT(@"%@", http_t == nil? @"" : http_t);
            sInfo.sRtsp_real        = FORMAT(@"%@", rtsp_t == nil? @"" : rtsp_t);
            sInfo.sRtsp_back        = FORMAT(@"%@", rtspBack_t == nil? @"" : rtspBack_t);
            sInfo.sSocket           = FORMAT(@"%@", socket_t == nil ? @"" : socket_t);
            sInfo.sP2p              = FORMAT(@"%@", p2p_t == nil ? @"" : p2p_t);
            NSArray *ar             = [sInfo.sSocket componentsSeparatedByString:@":"];
            if (ar.count < 2) {
                Dlog(@"UDT地址出错！");
            }
            if (ar.count >= 2) {
                sInfo.sUdtIp        = ar[0];
                sInfo.sUdtPort      = ar[1];
            }
            [HDUtility saveSeverInfo:sInfo];
        }
        
        completionBlock(YES, sInfo, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        completionBlock(NO, nil, [NSString stringWithFormat:@"请求数据失败，请检查网络！"]);
    }];
}

#pragma mark --获取短信验证码(单独的)
- (void)getMessageCode_1:(SNUserInfo *)user phone:(NSString *)phone tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, NSString *msgCode, NSString *sMessage))completionBlock
{
    if (!phone || !tID) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    if ([phone length] != 11 || [[phone substringToIndex:1] intValue] != 1) {
        [HDUtility say:@"请输入正确手机号码"];
        return;
    }
    
    NSString *sParameter = [NSString stringWithFormat:@"phone=%@&action=user_reset_password&tranid=%@", phone, tID];
    NSString *sMd5 = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], [HDUtility UnixTime]]];
    NSString *sHead = nil;
    if (user) {
        sHead = [NSString stringWithFormat:@"basic_get_verifycode:%@:%@:%@:%@:0", [HDUtility UnixTime], sMd5, user.sUserId, user.sSessionId];
    }else{
        sHead = [NSString stringWithFormat:@"basic_get_verifycode:%@:%@:::0", [HDUtility UnixTime], sMd5];
    }
    NSString *b64Head = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mdc_parameter setValue:FORMAT(@"%@", phone) forKey:@"version"];
    [mdc_parameter setValue:FORMAT(@"%@", tID) forKey:@"packagename"];
    [mdc_parameter setValue:@"user_reset_password" forKey:@"action"];
    HUD.labelText = @"获取验证码...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString    *sRetMesg   = nil;
        NSString    *verifyCode = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                completionBlock(NO, nil, @"没有数据");
                return;
            }
            
            NSString *verifyCode_t = [dic_data valueForKeyPath:@"verify_code"];
            verifyCode = FORMAT(@"%@", verifyCode_t == nil? @"" : verifyCode_t);
        }
        [HUD hide:YES];
        completionBlock(YES, verifyCode, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil);
    }];

}

#pragma mark --软件版本更新检查
- (void)checkVersion_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, SNPicketInfo *picket,  NSString *sMessage))completionBlock
{
   
    NSDictionary *dic_info  = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version   = [dic_info objectForKey:@"CFBundleShortVersionString"];
     NSString *app_Name     = [[dic_info objectForKey:@"CFBundleDisplayName"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *sParameter    = [NSString stringWithFormat:@"version=%@&packagename=%@&client_type=1", app_Version, app_Name];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], [HDUtility UnixTime]]];
    NSString *sHead         = nil;
    if (user) {
        sHead   = [NSString stringWithFormat:@"basic_check_softupdate:%@:%@:%@:%@:0", [HDUtility UnixTime], sMd5, user.sUserId, user.sSessionId];
    }else{
        sHead   = [NSString stringWithFormat:@"basic_check_softupdate:%@:%@:::0", [HDUtility UnixTime], sMd5];
    }
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:2];
    [mdc_parameter setValue:FORMAT(@"%@", app_Version)  forKey:@"version"];
    [mdc_parameter setValue:FORMAT(@"%@", app_Name)     forKey:@"packagename"];
    [mdc_parameter setValue:@"1"                        forKey:@"client_type"];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            Dlog(@"返回数据出错，请稍后再试!");
           // [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString    *sRetMesg;
        SNPicketInfo *picket = [[SNPicketInfo alloc] init];
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
//                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
//                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            NSString *pName_t       = [dic_data     valueForKey:@"name"];
            NSString *pVersion_t    = [dic_data     valueForKey:@"version"];
            NSString *pSize_t       = [dic_data     valueForKey:@"size"];
            NSString *pURL_t        = [dic_data     valueForKey:@"url"];
            picket.iUpdate          = [[dic_data    valueForKey:@"isupdate"] intValue];
            picket.sName            = FORMAT(@"%@", pName_t     == nil? @"": pName_t);
            picket.sVersion         = FORMAT(@"%@", pVersion_t  == nil? @"": pVersion_t);
            picket.sSize            = FORMAT(@"%@", pSize_t     == nil? @"": pSize_t);
            picket.sURL             = FORMAT(@"%@", pURL_t      == nil? @"": pURL_t);
        }
        completionBlock(YES, picket, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
//        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --申请用户注册
- (void)applicationUserRegistration_1:(SNUserInfo *)user phone:(NSString *)phone CompletionBlock:(void (^)(BOOL isSuccess, NSString *tranID, NSString *msgCode, NSString *sMessage))completionBlock
{
    if ([phone length] != 11 || [[phone substringToIndex:1] intValue] != 1) {
        [HDUtility say:@"请输入正确手机号码"];
        return;
    }
    
    NSString *time = [HDUtility UnixTime];
    NSString *sParameter = [NSString stringWithFormat:@"code=%@&action=user_applyadd_register&phone=%@", [HDUtility uuid], phone];
    NSString *sMd5 = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead = nil;
    if (user) {
        sHead = [NSString stringWithFormat:@"user_applyadd_register:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    }else{
        sHead = [NSString stringWithFormat:@"user_applyadd_register:%@:%@:::0", time, sMd5];
    }
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mdc_parameter setValue:FORMAT(@"%@", phone) forKey:@"phone"];
    [mdc_parameter setValue:FORMAT(@"%@", [HDUtility uuid]) forKey:@"code"];
    
    [mdc_parameter setValue:@"user_applyadd_register" forKey:@"action"];
    HUD.labelText = @"申请验证码...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString    *sRetMesg   = nil;
        NSString    *sTranID    = nil;
        NSString    *verifyID   = nil;
        
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, nil, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *tID_t = [dic_data valueForKey:@"tranid"];
            sTranID = FORMAT(@"%@", tID_t == nil? @"" : tID_t);
            NSString *verifyID_t = [dic_data valueForKeyPath:@"verify_code"];
            verifyID = FORMAT(@"%@", verifyID_t == nil? @"" : verifyID_t);
        }
        [HUD hide:YES];
        completionBlock(YES, sTranID, verifyID, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil, nil);
    }];
}

#pragma mark --用户注册
- (void)userRegistration_1:(SNUserInfo *)user account:(NSString *)acnt password:(NSString *)pwd messageCode:(NSString *)msgCode tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, NSString *userID, SNRegisterType regType,  NSString *sMessage))completionBlock
{
    NSString *time       = [HDUtility UnixTime];
    NSString *tocken     = nil;
    NSString *sUUID      = [HDUtility uuid];
    if (tID && msgCode) {
        NSString *code_tID   = [NSString stringWithFormat:@"%@%@", sUUID, tID];
        NSString *key_t      = [NSString stringWithFormat:@"esee_tran8^%@", tID];
        tocken               = [SNBase64 hmacSha1:key_t text:code_tID];
    }else{
        NSString *code_tID   = [NSString stringWithFormat:@"%@%@", sUUID, time];
        NSString *key_t      = [NSString stringWithFormat:@"esee_tran8^%@", time];
        tocken               = [SNBase64 hmacSha1:key_t text:code_tID];
    }
    
    NSString *md5Pwd     = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@", pwd]];
    NSString *sParameter = [NSString stringWithFormat:@"code=%@&account=%@&password=%@&verify_code=%@&client_type=1&tranid=%@&token=%@", sUUID, acnt, md5Pwd, msgCode, tID, tocken];
    NSString *sMd5       = [HDUtility md5:FORMAT(@"evideo_%@%@", [HDUtility md5:sParameter], [HDUtility UnixTime])];
    NSString *sHead      = nil;
    if (user) {
        sHead = FORMAT(@"user_add_register:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId);
    }else{
        sHead = FORMAT(@"user_add_register:%@:%@:::0", time, sMd5);
    }
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter  = [[NSMutableDictionary alloc] initWithCapacity:7];
    [mdc_parameter setValue:sUUID                   forKey:@"code"];
    [mdc_parameter setValue:FORMAT(@"%@", acnt == nil? @"" : acnt)     forKey:@"account"];
    [mdc_parameter setValue:FORMAT(@"%@", md5Pwd)   forKey:@"password"];
    [mdc_parameter setValue:FORMAT(@"%@", msgCode == nil? @"" : msgCode)  forKey:@"verify_code"];
    [mdc_parameter setValue:FORMAT(@"%@", @"1")     forKey:@"client_type"];
    [mdc_parameter setValue:FORMAT(@"%@", tID == nil? @"" : tID)      forKey:@"tranid"];
    [mdc_parameter setValue:FORMAT(@"%@", tocken)   forKey:@"token"];
    
    HUD.labelText = @"正在注册...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString         *sRetMesg  = nil;
        NSString         *sUserID   = nil;
        SNRegisterType   RegType    = -1;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, -1, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, -1, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *uID_t = [dic_data valueForKey:@"userid"];
            sUserID         = FORMAT(@"%@", uID_t == nil? @"": uID_t);
            BOOL isSame     = [[dic_data valueForKey:@"reg_type"] isEqualToString:@"imei"] == YES;
            RegType         = (isSame? SNRegisterTypeImei: SNRegisterTypePhone);
        }
        [HUD hide:YES];
        completionBlock(YES, sUserID, RegType, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, -1, nil);
    }];
}

#pragma mark --用户登录
- (void)userLoginWithAccount_1:(NSString *)acnt password:(NSString *)pwd tocke:(NSString *)sTocken CompletionBlock:(void (^)(BOOL isSuccess, SNUserInfo *userInfo,  NSString *sMessage))completionBlock
{
    if (!sTocken) {
        Dlog(@"tocke参数为空!");
    }
    if (acnt.length <= 0 || pwd.length <= 0) {
        Dlog(@"账号密码为空");
    }
    NSString *sTime         = [HDUtility UnixTime];
    NSString *sUUID         = [HDUtility uuid];
    NSString *md5Pwd        = nil;
    if (pwd && ![pwd isEqualToString:@""] && ![pwd isEqualToString:@"(null)"]) {
        md5Pwd              = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@", pwd]];
    }else{
        md5Pwd              = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", sUUID, sTime]];
    }
    NSString *sParameter    = nil;
    if (acnt && ![acnt isEqualToString:@""]) {
        sParameter    = FORMAT(@"code=%@&account=%@&password=%@&client_type=1&device_token=%@", sUUID, acnt, md5Pwd, sTocken == nil? @"" : sTocken);
    }else{
        sParameter    = FORMAT(@"code=%@&account=&password=%@&client_type=1&device_token=%@", sUUID, md5Pwd, sTocken == nil? @"" : sTocken);
    }
    NSString *sMd5          = [HDUtility md5:FORMAT(@"evideo_%@%@", [HDUtility md5:sParameter], sTime)];
    NSString *sHead         = [NSString stringWithFormat:@"user_add_login:%@:%@:::0", sTime, sMd5];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    NSString *s             = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:4];
    [mdc_parameter setValue:FORMAT(@"%@", [HDUtility uuid]) forKey:@"code"];
    [mdc_parameter setValue:FORMAT(@"%@", acnt == nil? @"" : acnt)     forKey:@"account"];
    [mdc_parameter setValue:FORMAT(@"%@", md5Pwd)   forKey:@"password"];
    [mdc_parameter setValue:FORMAT(@"%@", @"1")     forKey:@"client_type"];
    [mdc_parameter setValue:FORMAT(@"%@", sTocken == nil? @"" : sTocken)  forKey:@"device_token"];
    HUD.labelText = @"登录中...";
    [HUD show:YES];
    
    [self getPath2:@"" parameter:sParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString    *sRetMesg   = nil;
        SNUserInfo  *userInfo   = nil;
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            NSString *uid_t         = [dic_data valueForKey:@"userid"];
            NSString *seid_t        = [dic_data valueForKey:@"sessionid"];
            NSString *act_t         = [dic_data valueForKey:@"account"];
            NSString *nickName_t    = [dic_data valueForKey:@"nickname"];
            NSString *head_t        = [dic_data valueForKey:@"img_url"];
            NSString *sex_t         = [dic_data valueForKey:@"sex"];
            NSString *birthday_t    = [dic_data valueForKey:@"birthday"];
            NSString *email_t       = [dic_data valueForKey:@"email"];
            NSString *unreadMessage = [dic_data valueForKey:@"unread_message"];
            NSString *unreadEvent   = [dic_data valueForKey:@"unread_event"];
            userInfo                = [[SNUserInfo alloc] init];
            userInfo.sPassword      = pwd;
            userInfo.sUserId        = FORMAT(@"%@", uid_t           == nil? @"": uid_t);
            userInfo.sSessionId     = FORMAT(@"%@", seid_t          == nil? @"": seid_t);
            userInfo.sPhone         = FORMAT(@"%@", act_t           == nil? @"": act_t);
            userInfo.sUserName      = FORMAT(@"%@", nickName_t      == nil? @"": nickName_t);
            userInfo.sHeadUrl       = FORMAT(@"%@", head_t          == nil? @"": head_t);
            userInfo.sSex           = FORMAT(@"%@", sex_t           == nil? @"": sex_t);
            userInfo.sBirthday      = FORMAT(@"%@", birthday_t      == nil? @"": birthday_t);
            userInfo.sEmail         = FORMAT(@"%@", email_t         == nil? @"": email_t);
            userInfo.sUnreadMessage = FORMAT(@"%@", unreadMessage   == nil? @"": email_t);
            userInfo.sUnreadEvent   = FORMAT(@"%@", unreadEvent     == nil? @"": email_t);
            if ([userInfo.sUserId isEqualToString:[SNGlobalInfo instance].userInfo.sUserId]) {
                userInfo.sHeadPath  = [SNGlobalInfo instance].userInfo.sHeadPath;
            }
            BOOL isSame             = [[dic_data valueForKey:@"reg_type"] isEqualToString:@"phone"] == YES;
            userInfo.registerType   = (isSame? SNRegisterTypePhone : SNRegisterTypeImei);
            NSArray *ar_eventType   = [dic_data valueForKey:@"event_type"];
            userInfo.mar_eventType  = [[NSMutableArray alloc] initWithArray:ar_eventType];
            NSArray *ar_device_r            = [[NSArray alloc] initWithArray:[dic_data valueForKey:@"device_0"]];
            for (int i  = 0; i < ar_device_r.count; i++) {
                SNCameraInfo *caInfo        = [[SNCameraInfo alloc] init];
                NSDictionary *dic_device    = [ar_device_r objectAtIndex:i];
                NSString *dID_t             = [dic_device  valueForKey:@"id"];
                NSString *dNmae_t           = [dic_device  valueForKey:@"name"];
                NSString *dcode_t           = [dic_device  valueForKey:@"code"];
                NSString *dWifiID_t         = [dic_device  valueForKey:@"wifi"];
                NSString *dPhoto_t          = [dic_device  valueForKey:@"img_url"];
                NSString *dBName_t          = [dic_device  valueForKey:@"belong_username"];
                caInfo.isBelongOther        = [[dic_device valueForKey:@"belong_status"]    intValue] == 1? YES: NO;
                caInfo.lineStatus           = [[dic_device valueForKey:@"online_status"]    intValue];
                caInfo.sysStatus            = [[dic_device valueForKey:@"sys_status"]       intValue];
                caInfo.sdStatus             = [[dic_device valueForKey:@"sd_status"]        intValue];
                caInfo.shareStatus          = [[dic_device valueForKey:@"is_share"]         intValue];
                caInfo.staticStream         = [[dic_device valueForKey:@"static_stream"]    intValue];
                caInfo.sDeviceId            = FORMAT(@"%@", dID_t       == nil? @"": dID_t);
                caInfo.sDeviceName          = FORMAT(@"%@", dNmae_t     == nil? @"": dNmae_t);
                caInfo.sDeviceCode          = FORMAT(@"%@", dcode_t     == nil? @"": dcode_t);
                caInfo.wifiInfo.sSSID       = FORMAT(@"%@", dWifiID_t   == nil? @"": dWifiID_t);
                caInfo.sPhotoUrl            = FORMAT(@"%@", dPhoto_t    == nil? @"": dPhoto_t);
                caInfo.sBelongName          = FORMAT(@"%@", dBName_t    == nil? @"": dBName_t);
                if ([userInfo.sUserId isEqualToString:[SNGlobalInfo instance].userInfo.sUserId]) {
                    if (i < [SNGlobalInfo instance].userInfo.mar_camera.count) {
                        caInfo.sPhotoPath   = ((SNCameraInfo *)([SNGlobalInfo instance].userInfo.mar_camera[i])).sPhotoPath;
                    }
                }
                NSArray *ar_ = [dic_device valueForKey:@"event"];
                NSMutableArray *mar_event = [[NSMutableArray alloc] init];
                for (int i = 0; i < ar_.count; i++) {
                    NSDictionary *dc = ar_[i];
                    for (NSDictionary *dc_type in ar_eventType) {
                        NSString *sValue = [dc valueForKey:dc_type[@"code"]];
                        if (sValue != nil) {
                            NSMutableDictionary *mdc = [NSMutableDictionary new];
                            [mdc setValue:dc_type[@"code"] forKeyPath:@"code"];
                            [mdc setValue:sValue forKeyPath:@"value"];
                            [mar_event addObject:mdc];
                            break;
                        }
                    }
                }
                caInfo.mar_event = mar_event;
                [userInfo.mar_camera addObject:caInfo];
            }
            
            NSArray *ar_firend = [[NSArray alloc] initWithArray:[dic_data valueForKey:@"friend"]];
            for (int i = 0; i < ar_firend.count; i++) {
                NSDictionary *dic_firend    = [ar_firend    objectAtIndex:i];
                NSString *dFAct_t           = [dic_firend   valueForKey:@"account"];
                NSString *dFNickName_t      = [dic_firend   valueForKey:@"nickname"];
                NSString *dFSex_t           = [dic_firend   valueForKey:@"email"];
                NSString *dFImg_t           = [dic_firend   valueForKey:@"img_url"];
                SNFriendInfo *fdInfo        = [[SNFriendInfo alloc] init];
                fdInfo.sAccount             = FORMAT(@"%@", dFAct_t         == nil? @"": dFAct_t);
                fdInfo.sNickName            = FORMAT(@"%@", dFNickName_t    == nil? @"": dFNickName_t);
                fdInfo.sEmail               = FORMAT(@"%@", dFSex_t         == nil? @"": dFSex_t);
                fdInfo.sImageUrl            = FORMAT(@"%@", dFImg_t         == nil? @"": dFImg_t);
                if ([userInfo.sUserId isEqualToString:[SNGlobalInfo instance].userInfo.sUserId]) {
                    if (i < [SNGlobalInfo instance].userInfo.mar_friend.count) {
                       fdInfo.sImagePath = ((SNFriendInfo *)[SNGlobalInfo instance].userInfo.mar_friend[i]).sImagePath;
                    }
                }
                [userInfo.mar_friend addObject:fdInfo];
            }
            SNUserInfo *u                       = [HDUtility readLocalUserInfo];
            userInfo.mar_wifi                   = [[NSMutableArray alloc] initWithArray:u.mar_wifi];
            [SNGlobalInfo instance].userInfo    = userInfo;
            [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
        }
        [HUD hide:YES];
        [HDUtility mbSay:@"登录成功"];
        completionBlock(YES, userInfo, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --修改用户信息
- (void)userInfoUpdate_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    if (![HDUtility isValidateEmail:user.sEmail]) {
        [HDUtility say:@"请输入正确邮箱地址"];
        return;
    }
    
    NSString *time = [HDUtility UnixTime];
    NSString *sParameter = FORMAT(@"nickname=%@&sex=%@&birthday=%@&email=%@", (user.sUserName == nil? @"" : user.sUserName), user.sSex, user.sBirthday, user.sEmail);
    NSString *sMd5       = [HDUtility md5:FORMAT(@"evideo_%@%@", [HDUtility md5:sParameter], time)];
    NSString *sHead      = FORMAT(@"user_update_basicinfo:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId);
    NSString *b64Head    = [SNBase64 base64StringFromText:sHead];
    NSString *s          = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:4];
    [mdc_parameter setValue:FORMAT(@"%@", user.sUserName == nil? @"" : user.sUserName) forKey:@"nickname"];
    [mdc_parameter setValue:FORMAT(@"%@", user.sSex) forKey:@"sex"];
    [mdc_parameter setValue:FORMAT(@"%@", user.sBirthday) forKey:@"birthday"];
    [mdc_parameter setValue:FORMAT(@"%@", user.sEmail) forKey:@"email"];
    
    HUD.labelText = @"数据上传中...";
    [HUD show:YES];
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString    *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        HUD.labelText = @"修改成功";
        [HUD hide:YES afterDelay:1.5f];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --修改用户头像
- (void)userImageHeadUpdate_1:(SNUserInfo *)user image:(UIImage *)imgData imageName:(NSString *)iName CompletionBlock:(void (^)(BOOL isSuccess, NSString *sUrl, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    NSString *sHead     = FORMAT(@"user_update_photoinfo:%@:%@:%@:%@:0", [HDUtility UnixTime], [HDUtility md5:@""], (user.sUserId == nil? @"" : user.sUserId), (user.sSessionId == nil? @"" : user.sSessionId));
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSData *data_img    = UIImagePNGRepresentation(imgData);
    HUD.labelText = @"头像上传中...";
    [HUD show:YES];
    //上传文件
    NSMutableURLRequest *fileUpRequest = [self multipartFormRequestWithMethod:@"POST" path:@"" parameters:nil constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileData:data_img name:@"photo" fileName:iName mimeType:@"application/octet-stream"];
    }];
        
    AFHTTPRequestOperation *fileUploadOp = [[AFHTTPRequestOperation alloc] initWithRequest:fileUpRequest];
    //开始传输
    [fileUploadOp start];
    
    [fileUploadOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
        }
        NSDictionary *dic_data = [JSON objectForKey:@"data"];
        if (dic_data == nil) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
            return;
        }
        NSString *sUrl_ = [dic_data objectForKey:@"img_url"];
        [HUD hide:YES];
        completionBlock(YES, sUrl_, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --修改密码
- (void)passwordUpdate_1:(SNUserInfo *)user oldPassword:(NSString *)oPwd newPassword:(NSString *)nPwd CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    int pCount = (int)[oPwd length];
    int nCount = (int)[nPwd length];
    if ((pCount < 6 || pCount > 12) || (nCount < 6 || nCount > 12)) {
        [HDUtility say:[NSString stringWithFormat:@"密码必须使用：6-12位字母或数字组合"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
        return;
    }
    NSString *time          = [HDUtility UnixTime];
    NSString *md5Pwd_o      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@", oPwd]];
    NSString *md5Pwd_n      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@", nPwd]];
    NSString *sParameter    = [NSString stringWithFormat:@"old=%@&new=%@", md5Pwd_o, md5Pwd_n];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"user_update_password:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    NSString *s             = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:2];
    [mdc_parameter setValue:FORMAT(@"%@", md5Pwd_o) forKey:@"old"];
    [mdc_parameter setValue:FORMAT(@"%@", md5Pwd_n) forKey:@"new"];
    
    HUD.labelText = @"数据上传中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString    *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --申请找回密码
- (void)applicationFindPassword_1:(SNUserInfo *)user phone:(NSString *)phone CompletionBlock:(void (^)(BOOL isSuccess, NSString *sTranID, NSString *msgCode, NSString *sMessage))completionBlock
{
    if ([phone length] != 11 || [[phone substringToIndex:1] intValue] != 1) {
        [HDUtility say:@"请输入正确手机号码"];
        return;
    }
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"code=%@&phone=%@&action=user_applyreset_password", [HDUtility uuid], phone];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = nil;
    if (user) {
        sHead = [NSString stringWithFormat:@"user_applyreset_password:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    }else{
        sHead = [NSString stringWithFormat:@"user_applyreset_password:%@:%@:::0", time, sMd5];
    }
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mdc_parameter setValue:FORMAT(@"%@", phone) forKey:@"phone"];
    [mdc_parameter setValue:FORMAT(@"%@", [HDUtility uuid]) forKey:@"code"];
    [mdc_parameter setValue:@"user_applyreset_password" forKey:@"action"];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString    *sRetMesg   = nil;
        NSString    *sTranID    = nil;
        NSString    *verifyCode = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, nil, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *tID_t = [dic_data valueForKey:@"tranid"];
            sTranID = FORMAT(@"%@", tID_t == nil? @"" : tID_t);
            NSString *verifyCode_t = [dic_data valueForKeyPath:@"verify_code"];
            verifyCode = FORMAT(@"%@", verifyCode_t == nil? @"" : verifyCode_t);
        }
        [HUD hide:YES];
        completionBlock(YES, sTranID, verifyCode, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil, nil);
    }];
}

#pragma mark --找回方式重置密码
- (void)passwordUpadteOfFind_1:(SNUserInfo *)user tranID:(NSString *)tID password:(NSString *)pwd messageCode:msgCode CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!tID || !pwd || !msgCode) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time              = [HDUtility UnixTime];
    NSString *code_tID_mCode    = [NSString stringWithFormat:@"%@%@%@", [HDUtility uuid], tID, msgCode];
    NSString *key_t             = [NSString stringWithFormat:@"esee_tran8^%@", tID];
    NSString *tocken            = [SNBase64 hmacSha1:key_t text:code_tID_mCode];
    NSString *md5Pwd            = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@", pwd]];
    NSString *sParameter        = [NSString stringWithFormat:@"tranid=%@&code=%@&password=%@&verify_code=%@&token=%@", tID, [HDUtility uuid], md5Pwd, msgCode, tocken];
    NSString *sMd5              = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead             = nil;
    if (user) {
        sHead = [NSString stringWithFormat:@"user_reset_password:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    }else{
        sHead = [NSString stringWithFormat:@"user_reset_password:%@:%@:::0", time, sMd5];
    }
    NSString *b64Head = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:5];
    [mdc_parameter setValue:FORMAT(@"%@", tID) forKey:@"tranid"];
    [mdc_parameter setValue:FORMAT(@"%@", [HDUtility uuid]) forKey:@"code"];
    [mdc_parameter setValue:FORMAT(@"%@", md5Pwd) forKey:@"password"];
    [mdc_parameter setValue:FORMAT(@"%@", msgCode) forKey:@"verify_code"];
    [mdc_parameter setValue:FORMAT(@"%@", tocken) forKey:@"token"];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --用户注销
- (void)userLogout_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    NSString *time      = [HDUtility UnixTime];
    NSString *sMd5      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:@""], time]];
    NSString *sHead     = sHead = [NSString stringWithFormat:@"user_add_logout:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    HUD.labelText = @"注销中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            Dlog(@"返回数据出错，请稍后再试!");
            [HUD hide:YES];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                NSLog(@"%@", sRetMesg);
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --心跳包协议(获取状态变更)
- (void)heartBeat_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    Dlog(@"=========================begin=========================================");
    NSString *time      = [HDUtility UnixTime];
    NSString *sMd5      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:@""], time]];
    NSString *sHead     = sHead = [NSString stringWithFormat:@"user_get_heartbeat:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            Dlog(@"返回数据出错，请稍后再试!");
            return;
        }
        NSString *sRetMesg = nil;
        
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                completionBlock(NO, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                Dlog(@"data 没有数据");
                Dlog(@"========================== end ============================");
                completionBlock(NO, @"数据无变化");
                return;
            }
            
            NSDictionary *dic_device    = [dic_data valueForKey:@"device_0"];
            NSArray *ar_delDevice       = [[dic_device valueForKey:@"del"] componentsSeparatedByString:@","];
            NSArray *ar_wifi            = [dic_device valueForKey:@"wifi"];
            NSArray *ar_online          = [dic_device valueForKey:@"online_status"];
            NSArray *ar_sys             = [dic_device valueForKey:@"sys_status"];
            NSArray *ar_sd              = [dic_device valueForKey:@"sd_status"];
            
            SNUserInfo *user            = [SNGlobalInfo instance].userInfo;
            for (int i = 0; i < user.mar_camera.count; i++) {
                SNCameraInfo *cInfo = [user.mar_camera objectAtIndex:i];
                NSUInteger ui = [ar_delDevice indexOfObject:cInfo.sDeviceId];
                if (ui != NSNotFound && ar_delDevice != nil) {
                    [user.mar_camera removeObjectAtIndex:i];
                    i = 0;
                    continue;
                }
            }
            for (int i = 0; i < user.mar_camera.count; i++) {
                SNCameraInfo *cInfo = [user.mar_camera objectAtIndex:i];
                for (int j = 0; j < ar_wifi.count; j++) {
                    NSString *vaule_t = [[ar_wifi objectAtIndex:j] valueForKey:cInfo.sDeviceId];
                    if (vaule_t) {
                        SNWIFIInfo *wifiInfo = cInfo.wifiInfo;
                        wifiInfo.sSSID = vaule_t;
                        cInfo.wifiInfo = wifiInfo;
                        break;
                    }
                }
                for (int j = 0; j < ar_online.count; j++) {
                    NSString *vaule_t = [[ar_online objectAtIndex:j] valueForKey:cInfo.sDeviceId];
                    if (vaule_t) {
                        cInfo.lineStatus = [vaule_t intValue];
                        break;
                    }
                }
                for (int j = 0; j < ar_sys.count; j++) {
                    NSString *vaule_t = [[ar_sys objectAtIndex:j] valueForKey:cInfo.sDeviceId];
                    if (vaule_t) {
                        cInfo.sysStatus = [vaule_t intValue];
                        break;
                    }
                }
                
                for (int j = 0; j < ar_sd.count; j++) {
                    NSString *vaule_t = [[ar_sd objectAtIndex:j] valueForKey:cInfo.sDeviceId];
                    if (vaule_t) {
                        cInfo.sdStatus = [vaule_t intValue];
                        break;
                    }
                }
                [user.mar_camera removeObjectAtIndex:i];
                [user.mar_camera insertObject:cInfo atIndex:i];
            }
            
            [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
            Dlog(@"========================== end ============================");
        }
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        completionBlock(NO, nil);
    }];
    
}

#pragma mark --申请设备注册
- (void)applicationDeviceRegist_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *tranID, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"action=device_applyadd_register&code=%@", [HDUtility uuid]];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"device_applyadd_register:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    NSString *s             = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:2];
    [mdc_parameter setValue:@"device_applyadd_register" forKey:@"action"];
    [mdc_parameter setValue:FORMAT(@"%@", [HDUtility uuid]) forKey:@"code"];
 
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg  = nil;
        NSString *sTranID   = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *tID_t = [dic_data valueForKey:@"tranid"];
            sTranID = FORMAT(@"%@", tID_t == nil ? @"" : tID_t);
            
        }
        completionBlock(YES, sTranID, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --获取最新添加的设备
- (void)getDeviceForNewAdd_1:(SNUserInfo *)user tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, SNCameraInfo *cInfo, NSString *sMessage))completionBlock
{
    if (!user || !tID) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"tranid=%@", tID];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"device_query_newadd:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    NSString *s             = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [mdc_parameter setValue:tID forKey:@"tranid"];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@", JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg  = nil;
        SNCameraInfo *cInfo = nil;
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            if (![sRetCode isEqualToString:@"1"]) {
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSMutableArray  *mar_data = [JSON objectForKey:@"data"];
            if (mar_data.count <= 0) {
                completionBlock(YES, cInfo, sRetMesg);
                return;
            }
            NSDictionary    *dic_data = mar_data[0];
            if (dic_data == nil) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            NSString *dID_t     = [dic_data valueForKey:@"id"];
            NSString *sType     = dic_data[@"device_type"];
            NSString *dCode_t   = [dic_data valueForKey:@"code"];
            cInfo               = [[SNCameraInfo alloc] init];
            cInfo.sDeviceId     = FORMAT(@"%@", dID_t == nil? @"": dID_t);
            cInfo.deviceType    = [sType integerValue];
            cInfo.sDeviceCode   = FORMAT(@"%@", dCode_t == nil? @"": dCode_t);
        }
        completionBlock(YES, cInfo, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --修改设备信息
- (void)deviceInfoUpdate_1:(SNUserInfo *)user devicInfo:(SNCameraInfo *)dInfo CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user || !dInfo) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time       = [HDUtility UnixTime];
    NSString *sParameter = [NSString stringWithFormat:@"id=%@", dInfo.sDeviceId];
    if ([dInfo.sDeviceName length] > 0) {
        sParameter = [NSString stringWithFormat:@"%@&name=%@", sParameter, dInfo.sDeviceName];
    }
    if (dInfo.shareStatus == 0 || dInfo.shareStatus == 1) {
        sParameter = [NSString stringWithFormat:@"%@&is_share=%@", sParameter, FORMAT(@"%d", (int)dInfo.shareStatus)];
    }
    if (dInfo.staticStream >= 0 && dInfo.staticStream <=2) {
        sParameter = [NSString stringWithFormat:@"%@&static_stream=%d", sParameter, (int)dInfo.staticStream];
    }
    NSString *sForm = nil;
    if (dInfo.mar_event.count > 0) {
        sForm = FORMAT(@"{%@:%@}", dInfo.mar_event[0][@"code"], dInfo.mar_event[0][@"value"]);
        for (int i = 1; i < dInfo.mar_event.count; i++) {
            sForm = FORMAT(@"%@%@", sForm, [NSString stringWithFormat:@",{%@:%@}", dInfo.mar_event[i][@"code"], dInfo.mar_event[i][@"value"]]);
        }
        sParameter = [NSString stringWithFormat:@"%@&event=[%@]", sParameter, sForm];
    }
   
    Dlog(@"sParameter = %@", sParameter);
    NSString *sMd5      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead     = [NSString stringWithFormat:@"device_update_info:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mdc_parameter setValue:dInfo.sDeviceId forKey:@"id"];
    if ([dInfo.sDeviceName length] > 0) {
        [mdc_parameter setValue:dInfo.sDeviceName forKey:@"name"];
    }
    if (dInfo.shareStatus == 0 || dInfo.shareStatus == 1) {
        [mdc_parameter setValue:FORMAT(@"%d", (int)dInfo.shareStatus) forKey:@"is_share"];
    }
    if (dInfo.staticStream >= 0 && dInfo.staticStream <=2) {
        [mdc_parameter setValue:FORMAT(@"%d", (int)dInfo.staticStream) forKey:@"static_stream"];
    }
    if (dInfo.mar_event.count > 0) {
        [mdc_parameter setValue:FORMAT(@"[%@]", sForm) forKey:@"event"];
    }
    Dlog(@"mdc_parameter = %@", mdc_parameter);
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                Dlog(@"server return code:%@, message:%@", sRetCode, sRetMesg);
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --申请删除设备
- (void)applicationDeleteDevice_1:(SNUserInfo *)user devicID:(NSString *)dID CompletionBlock:(void (^)(BOOL isSuccess, NSString *tranID, NSString *msgCode, NSString *sMessage))completionBlock
{
    if (!user || !dID) {
        Dlog(@"参数传人错误!");
        return;
    }
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"code=%@&action=device_applydel_register&id=%@", [HDUtility uuid], dID];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"device_applydel_register:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mdc_parameter setValue:[HDUtility uuid] forKey:@"code"];
    [mdc_parameter setValue:@"device_applydel_register" forKey:@"action"];
    [mdc_parameter setValue:dID forKey:@"id"];
    HUD.labelText = @"网络请求中...";
    [HUD show:YES];
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HUD hide:YES];
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg      = nil;
        NSString *tID           = nil;
        NSString *verifyCode    = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HDUtility say:sRetMesg];
                [HUD hide:YES];
                completionBlock(NO, nil, nil, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                [HUD hide:YES];
                completionBlock(NO, nil, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *tID_t = [dic_data valueForKey:@"tranid"];
            tID = FORMAT(@"%@", tID_t == nil? @"" : tID_t);
            NSString *verifyCode_t = [dic_data valueForKeyPath:@"verify_code"];
            verifyCode = FORMAT(@"%@", verifyCode_t == nil? @"" : verifyCode_t);
        }
        [HUD hide:YES];
        completionBlock(YES, tID, verifyCode, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil, nil);
    }];
}

#pragma mark --手机端删除设备
- (void)deleteDevice_1:(SNUserInfo *)user devicID:(NSString *)dID messageCode:(NSString *)msgCode tranID:(NSString *)tID CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user || !dID || !msgCode || !tID) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time              = [HDUtility UnixTime];
    NSString *code_tID_mCode    = [NSString stringWithFormat:@"%@%@", dID, tID];
    NSString *key_t             = [NSString stringWithFormat:@"esee_tran8^%@", tID];
    NSString *tocken            = [SNBase64 hmacSha1:key_t text:code_tID_mCode];
    NSString *sParameter        = [NSString stringWithFormat:@"id=%@&verify_code=%@&tranid=%@&token=%@", dID, msgCode, tID, tocken];
    NSString *sMd5              = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead             = [NSString stringWithFormat:@"device_del_register:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head           = [SNBase64 base64StringFromText:sHead];
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:4];
    [mdc_parameter setValue:dID forKey:@"id"];
    [mdc_parameter setValue:msgCode forKey:@"verify_code"];
    [mdc_parameter setValue:tID forKey:@"tranid"];
    [mdc_parameter setValue:tocken forKey:@"token"];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --查询设备列表
- (void)referDevice_1:(SNUserInfo *)user deviceType:(SNDeviceType)dType CompletionBlock:(void (^)(BOOL isSuccess, NSArray *ar_cameraInfo, NSString *sMessage))completionBlock
{
    if (!user || !(dType == 0 || dType == 1)) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"device_type=%d", (int)dType];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"device_query_list:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    NSString *s             = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [mdc_parameter setValue:FORMAT(@"%d", (int)dType) forKey:@"device_type"];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        NSMutableArray *mar_device = [[NSMutableArray alloc] init];
        
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            Dlog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSArray *ar_data = [JSON objectForKey:@"data"];
            if (ar_data == nil || ar_data.count <= 0) {
                [HUD hide:YES];
                completionBlock(YES, [NSArray new], @"没有摄像头");
                return;
            }
            SNCameraInfo *cInfo;
            NSMutableArray *mar_camera = [SNGlobalInfo instance].userInfo.mar_camera;
            for (int i = 0; i < ar_data.count; i++) {
                NSString *dID_t         = [ar_data[i] valueForKey:@"id"];
                NSString *dName_t       = [ar_data[i] valueForKey:@"name"];
                NSString *dCode_t       = [ar_data[i] valueForKey:@"code"];
                NSString *dWifiID_t     = [ar_data[i] valueForKey:@"wifi"];
                NSString *dBName_t      = [ar_data[i] valueForKey:@"belong_username"];
                NSString *dPhoto_t      = [ar_data[i] valueForKey:@"img_url"];
                for (SNCameraInfo *info in mar_camera) {
                    if ([info.sDeviceId isEqualToString:dID_t]) {
                        cInfo = info;
                        break;
                    }
                }
                if (!cInfo) {
                    cInfo = [[SNCameraInfo alloc] init];
                }
                cInfo.sDeviceId         = FORMAT(@"%@", dID_t       == nil? @"": dID_t);
                cInfo.sDeviceName       = FORMAT(@"%@", dName_t     == nil? @"": dName_t);
                cInfo.sDeviceCode       = FORMAT(@"%@", dCode_t     == nil? @"": dCode_t);
                SNWIFIInfo *wifi        = [[SNWIFIInfo alloc] init];
                wifi.sSSID              = FORMAT(@"%@", dWifiID_t   == nil? @"": dWifiID_t);
                cInfo.wifiInfo          = wifi;
                cInfo.sdStatus          = [[ar_data[i] valueForKey:@"sd_status"]        intValue];
                cInfo.lineStatus        = [[ar_data[i] valueForKey:@"online_status"]    intValue];
                cInfo.sysStatus         = [[ar_data[i] valueForKey:@"sys_status"]       intValue];
                cInfo.isBelongOther     = [[ar_data[i] valueForKey:@"belong_status"]    intValue] == 0? NO: YES;
                cInfo.shareStatus       = [[ar_data[i] valueForKey:@"is_share"]         intValue];
                cInfo.sPhotoUrl         = FORMAT(@"%@", dPhoto_t == nil? @"": dPhoto_t);
                cInfo.sBelongName       = FORMAT(@"%@", dBName_t == nil? @"": dBName_t);
                [mar_device addObject:cInfo];
            }
        }
        
        [HUD hide:YES];
        completionBlock(YES, mar_device, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HUD hide:YES];
        completionBlock(NO, nil, @"请求数据失败，请检查网络！");
    }];
}

#pragma mark --查询好友列表
- (void)referFriend_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayFriend, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    NSString *time      = [HDUtility UnixTime];
    NSString *sMd5      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:@""], time]];
    NSString *sHead     = [NSString stringWithFormat:@"friend_query_list:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            [HUD hide:YES];
            return;
        }
        NSString *sRetMesg = nil;
        NSMutableArray *ar_friends = [[NSMutableArray alloc] init];
        
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            NSArray *ar_data = [JSON objectForKey:@"data"];
            for (int i = 0; i < ar_data.count; i++) {
                SNFriendInfo *fInfo = [[SNFriendInfo alloc] init];
                NSString *dFact_t   = [ar_data[i] valueForKey:@"account"];
                NSString *dFName_t  = [ar_data[i] valueForKey:@"nickname"];
                NSString *dFEmail_t = [ar_data[i] valueForKey:@"email"];
                NSString *dFImg_t   = [ar_data[i] valueForKey:@"img_url"];
                fInfo.sImageUrl     = FORMAT(@"%@", dFImg_t     == nil? @"": dFImg_t);
                fInfo.sAccount      = FORMAT(@"%@", dFact_t     == nil? @"": dFact_t);
                fInfo.sNickName     = FORMAT(@"%@", dFName_t    == nil? @"": dFName_t);
                fInfo.sEmail        = FORMAT(@"%@", dFEmail_t   == nil? @"": dFEmail_t);
                NSArray *ar_friend = [SNGlobalInfo instance].userInfo.mar_friend;
                for (SNFriendInfo *info in ar_friend) {
                    if ([fInfo.sAccount isEqualToString:info.sAccount]) {
                        fInfo.sImagePath = info.sImagePath;
                        break;
                    }
                }
                [ar_friends addObject:fInfo];
            }
        }
        [HUD hide:YES];
        completionBlock(YES, ar_friends, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --添加好友
- (void)addFriend_1:(SNUserInfo *)user account:(NSString *)act CompletionBlock:(void (^)(BOOL isSuccess, SNFriendInfo *fInfo, NSString *sMessage))completionBlock
{
    if (!user || !act) {
        Dlog(@"参数传人错误!");
        return;
    }
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"account=%@", act];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"friend_add_info:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    
    NSString *s             = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [mdc_parameter setValue:act forKey:@"account"];
    [HUD show:YES];
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HUD hide:YES];
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg      = nil;
        SNFriendInfo *fInfo     = [[SNFriendInfo alloc] init];
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HUD hide:YES];
                completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *dFAct_t   = [dic_data valueForKey:@"account"];
            NSString *dFName_t  = [dic_data valueForKey:@"nickname"];
            NSString *dFSex_t   = [dic_data valueForKey:@"email"];
            NSString *dFImg_t   = [dic_data valueForKey:@"img_url"];
            fInfo.sAccount      = FORMAT(@"%@", dFAct_t     == nil ? @"" : dFAct_t);
            fInfo.sNickName     = FORMAT(@"%@", dFName_t    == nil ? @"" : dFName_t);
            fInfo.sEmail        = FORMAT(@"%@", dFSex_t     == nil ? @"" : dFSex_t);
            fInfo.sImageUrl     = FORMAT(@"%@", dFImg_t     == nil ? @"" : dFImg_t);
            if (fInfo.sImageUrl.length > 0) {//如果有网络图片
//                NSString *sImagename    = [fInfo.sImageUrl lastPathComponent];
//                NSString *sPath         = [HDUtility imageSavedPath:sImagename];
//                NSFileManager *manager  = [NSFileManager defaultManager];
//                if (![manager fileExistsAtPath:sPath]) {//图片本地路径若不存在，保存
//                    UIImage *image      = [HDUtility imageWithUrl:fInfo.sImageUrl];
//                    [HDUtility saveToDocument:image withFilePath:sPath];
//                }
                NSString *sPath     = [HDUtility imageWithUrl:fInfo.sImageUrl savedFolderName:@FOLDER_FRIEND savedFileName:nil];
                fInfo.sImagePath    = sPath;
            }
        }
        [HUD hide:YES];
        completionBlock(YES, fInfo, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HUD hide:YES];
        completionBlock(NO, nil, @"请求数据失败，请检查网络！");
    }];
}

#pragma mark --删除好友
- (void)deleteFriend_1:(SNUserInfo *)user account:(NSString *)act CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user || !act) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"account=%@", act];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"friend_delete_info:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    NSString *s             = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [mdc_parameter setValue:act forKey:@"account"];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --获取相片列表
- (void)getPhotoList_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSArray *ar_list, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time      = [HDUtility UnixTime];
    NSString *sMd5      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:@""], time]];
    NSString *sHead     = [NSString stringWithFormat:@"album_query_list:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    
    NSString *s         = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HUD hide:YES];
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        NSMutableArray *ar_t = [[NSMutableArray alloc] init];
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
//            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSArray *ar_data = [JSON objectForKey:@"data"];
            if (ar_data == nil || ar_data.count <= 0) {
//                [HDUtility say:@"返回数据出错，请稍后再试!"];
                Dlog(@"没有图片列表数据");
                [HUD hide:YES];
                completionBlock(NO, nil, @"没有图片列表数据");
                return;
            }
            
            for (int i = 0; i < ar_data.count; i++) {
                SNPhotoInfo *pInfo = [[SNPhotoInfo alloc] init];
                NSString *pID_t = [ar_data[i] valueForKey:@"photo_id"];
                pInfo.photoID = FORMAT(@"%@", pID_t == nil ? @"" : pID_t);
                NSString *pURL_t = [ar_data[i] valueForKey:@"photo_url"];
                pInfo.photoURL = FORMAT(@"%@", pURL_t == nil ? @"" : pURL_t);
                NSString *pDeviceID = [ar_data[i] valueForKey:@"photo_device"];
                pInfo.takeDeviceID = FORMAT(@"%@", pDeviceID == nil ? @"" : pDeviceID);
                NSString *pTime = [ar_data[i] valueForKey:@"photo_time"];
                pInfo.takeTime = FORMAT(@"%@", pTime == nil ? @"" : pTime);
                
                [ar_t addObject:pInfo];
            }
        }
        [HUD hide:YES];
        completionBlock(YES, ar_t, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --上传相片
- (void)importPhoto_1:(SNUserInfo *)user pInfo:(SNPhotoInfo *)pInfo image:(UIImage *)img CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user || !img) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSDate *time_t = nil;
    if (pInfo.takeTime == nil || [pInfo.takeTime isEqualToString:@""]) {
        time_t = [NSDate date];
    }else{
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init] ;
        [formatter1 setDateFormat:@"yyyy.MM.dd"];
        time_t = [formatter1 dateFromString:pInfo.takeTime];
    }
    
    NSString *takeID = nil;
    if (pInfo.takeDeviceID == nil || [pInfo.takeDeviceID isEqualToString:@""]) {
        takeID = @"";
    }else{
        takeID = pInfo.takeDeviceID;
    }
    
    NSString *time              = [HDUtility UnixTime];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyyMMddHHmmSS"];
    NSString *sTime             = [formatter stringFromDate:time_t];
    NSString *sParameter        = [NSString stringWithFormat:@"id=%@&photo_time=%@", pInfo.takeDeviceID, sTime];
    NSString *sMd5              = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead             = [NSString stringWithFormat:@"album_add_photo:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head           = [SNBase64 base64StringFromText:sHead];
    NSString *s                 = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mdc_parameter setValue:pInfo.takeDeviceID forKey:@"id"];
    [mdc_parameter setValue:sTime forKey:@"photo_time"];
    
    NSData *imgData =  UIImagePNGRepresentation(img);
    
    HUD.labelText = @"图片上传中...";
    [HUD show:YES];
    
    //上传文件
    NSMutableURLRequest *fileUpRequest = [self multipartFormRequestWithMethod:@"POST" path:@"" parameters:mdc_parameter constructingBodyWithBlock:^(id formData) {
        
        [formData appendPartWithFileData:imgData name:@"photo" fileName:pInfo.photoName mimeType:@"application/octet-stream"];
        
    }];
    
    AFHTTPRequestOperation *fileUploadOp = [[AFHTTPRequestOperation alloc] initWithRequest:fileUpRequest];
    //开始传输
    [fileUploadOp start];
   
    [fileUploadOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HUD hide:YES];
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                [HUD hide:YES];
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, @"返回数据出错，请稍后再试!");
                return;
            }
            
            NSString *pID_t = [dic_data valueForKey:@"photo_id"];
            pInfo.photoID = FORMAT(@"%@", pID_t == nil? @"" : pID_t);
            NSString *pURL = [dic_data valueForKey:@"photo_url"];
            pInfo.photoURL = FORMAT(@"%@", pURL == nil? @"" : pURL);
            [HDUtility savePhotoInfo:pInfo];
        }
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
    
}

#pragma mark --删除相片
- (void)deletePhoto_1:(SNUserInfo *)user photoID:(NSString *)pID CompletionBlock:(void (^)(BOOL isSuccess, NSString *sMessage))completionBlock
{
    if (!user || [pID isEqualToString:@""] || !pID) {
        Dlog(@"参数传人错误!");
        completionBlock(NO, nil);
        return;
    }
    
    NSString *time         = [HDUtility UnixTime];
    NSString *sParameter   = [NSString stringWithFormat:@"id=%@", pID];
    NSString *sMd5         = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead        = [NSString stringWithFormat:@"album_delete_photo:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head      = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [mdc_parameter setValue:pID forKey:@"id"];
    
    HUD.labelText = @"网络加载中...";
    [HUD show:YES];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            [HUD hide:YES];
            return;
        }
        NSString *sRetMesg = nil;
        if(JSON != [NSNull class]){
            sRetMesg = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HUD hide:YES];
                [HDUtility say:sRetMesg];
                completionBlock(NO, sRetMesg);
                return;
            }
        }
        [HUD hide:YES];
        completionBlock(YES, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        [HUD hide:YES];
        completionBlock(NO, nil);
    }];
}

#pragma mark --查询消息列表
- (void)referMessage_1:(SNUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayMessage, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time      = [HDUtility UnixTime];
    NSString *sMd5      = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:@""], time]];
    NSString *sHead     = [NSString stringWithFormat:@"message_query_list:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head   = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg      = nil;
        NSMutableArray *ar_msg  = [[NSMutableArray alloc] init];
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSArray *ar_data = [JSON objectForKey:@"data"];
            if (ar_data == nil || ar_data.count <= 0) {
                [HDUtility say:@"返回数据出错，请稍后再试!"];
                completionBlock(NO, nil, @"返回数据出错，请稍后再试!");
                return;
            }
            
            for (int i = 0; i < ar_data.count; i++) {
                NSString *dMID_t        = [ar_data[i] valueForKey:@"id"];
                NSString *dMTime_t      = [ar_data[i] valueForKey:@"time"];
                NSString *dMContent_t   = [ar_data[i] valueForKey:@"content"];
                SNMessageInfo *msgInfo  = [[SNMessageInfo alloc] init];
                msgInfo.sMsgID          = FORMAT(@"%@", dMID_t == nil ? @"" : dMID_t);
                msgInfo.sMsgTime        = FORMAT(@"%@", dMTime_t == nil ? @"" : dMTime_t);
                msgInfo.sContent        = FORMAT(@"%@", dMContent_t == nil ? @"" : dMContent_t);
                msgInfo.msgType         = [[ar_data[i] valueForKey:@"type"] intValue];
                msgInfo.msgLevel        = [[ar_data[i] valueForKey:@"lv"] intValue];
                [ar_msg addObject:msgInfo];
            }
        }
        completionBlock(YES, ar_msg, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --开始下载图片
- (void)requestStart_1WithCompletionBlock:(void (^)(BOOL isSuccess, UIImage *img, NSString *sMessage))completionBlock
{
    [self getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *imag = [UIImage imageWithData:responseObject];
        if (imag == nil) {
            completionBlock(NO, nil, @"没有该图片");
        }
        completionBlock(YES, imag, nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --查询事件列表
- (void)getEvents:(SNUserInfo *)user deviceID:(NSString *)dID eventTypeID:(NSString *)eType start:(int)start limit:(int)limit startTime:(NSDate *)startTime endTime:(NSDate *)endTime CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayEvents, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    if (dID == nil) {
        dID = @"";
    }
    if (eType == nil) {
        eType = @"";
    }
    if (start < 0) {
        start = 0;
    }
    NSString *sLimit = [NSString stringWithFormat:@"%d", limit];
    if (limit == 0) {
        sLimit = @"";
    }
    
    NSString *s_startTime = nil;
    NSString *s_endTime = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    s_startTime = [formatter stringFromDate:startTime];
    s_endTime = [formatter  stringFromDate:endTime];
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"id=%@&event_type=%@start=%dlimit=%@start_time=%@end_time=%@", dID, eType, start, sLimit, s_startTime, s_endTime];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"event_query_list:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:6];
    [mdc_parameter setValue:dID forKey:@"id"];
    [mdc_parameter setValue:eType forKey:@"event_type"];
    [mdc_parameter setValue:FORMAT(@"%d", start) forKey:@"start"];
    [mdc_parameter setValue:sLimit forKey:@"limit"];
    [mdc_parameter setValue:s_startTime forKey:@"start_time"];
    [mdc_parameter setValue:s_endTime forKey:@"end_time"];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg      = nil;
        NSMutableArray *mar_events = [[NSMutableArray alloc] init];
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSArray *ar_data = [JSON objectForKey:@"data"];
            if (ar_data == nil || ar_data.count <= 0) {
                completionBlock(NO, nil, @"没有数据，请稍后再试!");
                return;
            }
            
            for (int i = 0; i < ar_data.count; i++) {
                NSDictionary *dic_t     = [ar_data objectAtIndex:i];
                NSMutableDictionary *mdic_dices = [[NSMutableDictionary alloc] init];
                NSString *deviceID      = [dic_t valueForKey:@"device_id"];
                NSArray *ar_event_t     = [dic_t valueForKey:@"event"];
                NSMutableArray *mar_events_d = [[NSMutableArray alloc] init];
                for(int j = 0; j < ar_event_t.count; j++){
                    NSDictionary *dic_t2 = [ar_event_t objectAtIndex:j];
                    SNEventInfo *eInfo   = [[SNEventInfo alloc] init];
                    eInfo.sDeviceID      = deviceID;
                    eInfo.sEventID       = [dic_t2 valueForKey:@"event_id"];
                    eInfo.sEventName     = [dic_t2 valueForKey:@"event_name"];
                    eInfo.sEventTypeID   = [dic_t2 valueForKey:@"event_type"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyyMMddHHmmss"];
                    eInfo.eventTime     = [formatter dateFromString:[dic_t2 valueForKey:@"event_time"]];
                    eInfo.sImageUrl      = [dic_t2 valueForKey:@"event_img"];
                    [mar_events_d addObject:eInfo];
                }
                [mdic_dices setObject:mar_events_d forKey:deviceID];
                [mar_events addObject:mdic_dices];
            }
         
        }
        completionBlock(YES, mar_events, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --查看事件视频
- (void)getEventVideoURL:(SNUserInfo *)user eventID:(NSString *)eID CompletionBlock:(void (^)(BOOL isSuccess, NSString *videoURL, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    if (eID == nil) {
        Dlog(@"参数传人错误!");
        return;
    }
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"event_id=%@", eID];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"event_play_video:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:1];
    [mdc_parameter setValue:eID forKey:@"event_id"];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        NSString *sRetMesg      = nil;
        NSString *sURL          = nil;
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSDictionary *dic_data = [JSON objectForKey:@"data"];
            if (dic_data == nil) {
                completionBlock(NO, nil, @"没有数据，请稍后再试!");
                return;
            }
            
            sURL = [dic_data valueForKey:@"rtsp_url"];
        }
        completionBlock(YES, sURL, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        completionBlock(NO, nil, nil);
    }];
}

#pragma mark --查看事件报告
- (void)getEventReport:(SNUserInfo *)user deviceID:(NSString *)dID date:(NSDate *)date CompletionBlock:(void (^)(BOOL isSuccess, NSArray *arrayReports, NSString *sMessage))completionBlock
{
    if (!user) {
        Dlog(@"参数传人错误!");
        return;
    }
    if (dID == nil) {
        dID = @"";
    }
    
    NSString *time_date = @"";
    if (date != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        time_date = [formatter stringFromDate:date];
    }
    
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = [NSString stringWithFormat:@"id=%@&date=%@s", dID, time_date];
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"event_query_report:%@:%@:%@:%@:0", time, sMd5, user.sUserId, user.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:2];
    [mdc_parameter setValue:dID forKey:@"id"];
    [mdc_parameter setValue:time_date forKey:@"date"];
    
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：returned json = %@" , JSON);
        if (!JSON) {
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        
        NSString *sRetMesg          = nil;
        NSMutableArray *mar_reports = [[NSMutableArray alloc] init];
        if(JSON != [NSNull class]){
            sRetMesg            = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode  = [JSON objectForKey:@"retcode"];
            NSLog(@"retcode = %@", sRetCode);
            if (![sRetCode isEqualToString:@"1"]) {
                [HDUtility say:sRetMesg];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            
            NSArray *ar_data = [JSON objectForKey:@"data"];
            if (ar_data == nil || ar_data.count <= 0) {
                completionBlock(NO, nil, @"没有数据，请稍后再试!");
                return;
            }
            
            for (int i = 0; i < ar_data.count; i++) {
                NSDictionary    *dic_t             = [ar_data objectAtIndex:i];
                SNEventReport   *report            = [[SNEventReport alloc] init];
                report.deviceID                    = [dic_t valueForKey:@"device_id"];
                NSArray         *ar_week_t         = [dic_t valueForKey:@"week_report"];
                NSMutableArray  *mar_week_t        = [[NSMutableArray alloc] init];
                for(int j = 0; j < ar_week_t.count; j++){
                    NSDictionary      *dic_t2      = [ar_week_t objectAtIndex:j];
                    NSString          *date_week   = [dic_t2 valueForKey:@"date"];
                    NSArray           *ar_stat     = [dic_t2 valueForKey:@"event_statistics"];
//                    NSMutableArray    *mar_stat_t  = [[NSMutableArray alloc] init];
                    for (int k = 0; k < ar_stat.count; k++) {
                        NSDictionary      *dic_info     = [ar_stat objectAtIndex:k];
                        SNEventReportInfo *reInfo  = [[SNEventReportInfo alloc] init];
                        reInfo.typeName            = [dic_info valueForKey:@"event_type_name"];
                        reInfo.type                = [dic_info valueForKey:@"event_type"];
                        reInfo.count            = [dic_info valueForKey:@"count"];
                        if (date_week) {
                            NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:@"yyyyMMdd"];
                            reInfo.date              = [formatter dateFromString:date_week];
                        }
                        [mar_week_t addObject:reInfo];
                    }
//                    [mar_week_t addObject:mar_stat_t];
                }
                report.ar_weekReport = mar_week_t;
                
                NSArray        *ar_deate_t         = [dic_t valueForKey:@"date_report"];
                NSMutableArray *mar_date_t         = [[NSMutableArray alloc] init];
                for (int j = 0; j < ar_deate_t.count; j++) {
                    NSDictionary *dic_t3           = [ar_deate_t objectAtIndex:j];
                    NSString     *date_d           = [dic_t3 valueForKey:@"date"];
                    NSArray      *ar_stat2         = [dic_t3 valueForKey:@"event_statistics"];
//                    NSMutableArray *mar_stat_t2    = [[NSMutableArray alloc] init];
                    for (int k = 0; k < ar_stat2.count; k++) {
                        SNEventReportInfo *reInfo2  = [[SNEventReportInfo alloc] init];
                        NSDictionary *dic_info2     = [ar_stat2 objectAtIndex:k];
                        reInfo2.configName          = [dic_info2 valueForKey:@"event_config_name"];
                        reInfo2.typeName            = [dic_info2 valueForKey:@"event_type_name"];
                        reInfo2.type                = [dic_info2 valueForKey:@"event_type"];
                        reInfo2.count               = [dic_info2 valueForKey:@"count"];
                        reInfo2.descrip             = [dic_info2 valueForKey:@"descrip"];
                        if (date_d) {
                            NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:@"yyyyMMdd"];
                            reInfo2.date              = [formatter dateFromString:date_d];
                        }
                        [mar_date_t addObject:reInfo2];
                    }
//                    [mar_date_t addObject:mar_stat_t2];
                }
                report.ar_dateReport = mar_date_t;
                
                [mar_reports addObject:report];
            }
            
        }
        completionBlock(YES, mar_reports, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        completionBlock(NO, nil, nil);
    }];
}
#pragma mark --查询所有摄像头事件设置列表
- (void)getEventSettingListCompletionBlock:(void (^)(BOOL isSuccess, NSArray *arList, NSString *sMessage))completionBlock
{
    NSString *time          = [HDUtility UnixTime];
    NSString *sParameter    = @"";
    NSString *sMd5          = [HDUtility md5:[NSString stringWithFormat:@"evideo_%@%@", [HDUtility md5:sParameter], time]];
    NSString *sHead         = [NSString stringWithFormat:@"event_query_configlist:%@:%@:%@:%@:0", time, sMd5, [SNGlobalInfo instance].userInfo.sUserId, [SNGlobalInfo instance].userInfo.sSessionId];
    NSString *b64Head       = [SNBase64 base64StringFromText:sHead];
    NSString *s = [NSString stringWithFormat:@"Basic %@", b64Head];
    [self setDefaultHeader:@"Authorization" value:s];
    HUD.labelText = @"请求数据..";
    [HUD show:YES];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithCapacity:2];
    [self getPath:@"" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            [HUD hide:YES];
            [HDUtility say:@"返回数据出错，请稍后再试!"];
            return;
        }
        
        NSString *sRetMesg                  = nil;
        NSMutableArray *mar_cameraEvents    = [[NSMutableArray alloc] init];
        
        if(JSON != [NSNull class]){
            sRetMesg                = [JSON objectForKey:@"retmsg"];
            NSString *sRetCode      = [JSON objectForKey:@"retcode"];
            if (![sRetCode isEqualToString:@"1"]) {
                [HDUtility say:sRetMesg];
                [HUD hide:YES];
                completionBlock(NO, nil, sRetMesg);
                return;
            }
            NSArray *ar_data = [JSON objectForKey:@"data"];
            if (ar_data == nil || ar_data.count <= 0) {
                Dlog(@"ar_data为空");
                [HUD hide:YES];
                completionBlock(NO, nil, @"没有数据，请稍后再试!");
                return;
            }
            Dlog(@"ar_data = %@", ar_data);
            for (int i = 0; i < ar_data.count; i++) {
                NSMutableDictionary *mdc = ar_data[i];
                SNCameraEvents *cameraEvents = [[SNCameraEvents alloc] init];
                cameraEvents.sDeviceID = mdc[@"device_id"];
                if (cameraEvents.sDeviceID.length == 0) {
                    [HUD hide:YES];
                    Dlog(@"服务器返回数据有误");
                    return;
                }
                NSArray *arEvent = mdc[@"event_config"];
                for (int i = 0; i < arEvent.count; i++) {
                    NSMutableDictionary *mdc_event = arEvent[i];
                    SNEventInfo *eventInfo  = [SNEventInfo new];
                    eventInfo.sEventTypeID  = mdc_event[@"event_type"];
                    eventInfo.sEventID      = mdc_event[@"id"];
                    eventInfo.sEventName    = mdc_event[@"name"];
                    eventInfo.isEffect      = [mdc_event[@"is_success"] boolValue];
                    eventInfo.ar_area       = mdc_event[@"event_area"];
                    eventInfo.sImageUrl     = mdc_event[@"event_area_img"];
                    if ([eventInfo.sEventTypeID hasPrefix:@"ES"]) {
                        [cameraEvents.mar_events insertObject:eventInfo atIndex:0];
                    }else{
                        [cameraEvents.mar_events addObject:eventInfo];
                    }
                }
                [mar_cameraEvents addObject:cameraEvents];
            }
            
        }
        [HUD hide:YES];
        completionBlock(YES, mar_cameraEvents, sRetMesg);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HUD hide:YES];
        Dlog(@" getLoginKey failed %ld", (long)operation.response.statusCode);
        [HDUtility say:[NSString stringWithFormat:@"请求数据失败，请检查网络！"]];
        completionBlock(NO, nil, nil);
    }];
}



@end
