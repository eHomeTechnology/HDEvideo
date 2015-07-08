//
//  SNUserInfo.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-21.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNUserInfo.h"

@implementation SNUserInfo

- (id)init{

    if (self = [super init]) {
        
        self.mar_wifi   = [[NSMutableArray alloc] init];
        self.mar_camera = [[NSMutableArray alloc] init];
        self.mar_friend = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSMutableDictionary *)dictionaryValue{
    NSMutableDictionary *dic        = [[NSMutableDictionary alloc] init];
    NSMutableArray *mar_camera      = [[NSMutableArray alloc] init];
    NSMutableArray *mar_wifi        = [[NSMutableArray alloc] init];
    NSMutableArray *mar_friend      = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.mar_camera.count; i++) {
        if (![self.mar_camera[i] isKindOfClass:[SNCameraInfo class]]) {
            Dlog(@"数据出错！");
            return nil;
        }
        NSDictionary *dic_ = [((SNCameraInfo *)self.mar_camera[i]) dictionaryValue];
        [mar_camera addObject:dic_];
    }
    for (int i = 0; i < self.mar_wifi.count; i++) {
        if (![self.mar_wifi[i] isKindOfClass:[SNWIFIInfo class]]) {
            Dlog(@"数据出错！");
            return nil;
        }
        NSDictionary *dic_ = [((SNWIFIInfo *)self.mar_wifi[i]) dictionaryValue];
        [mar_wifi addObject:dic_];
    }
    
    for (int i = 0; i < self.mar_friend.count; i++) {
        if (![self.mar_friend[i] isKindOfClass:[SNFriendInfo class]]) {
            Dlog(@"数据出错！");
            return nil;
        }
        NSDictionary *dic_ = [((SNFriendInfo *)self.mar_friend[i]) dictionaryValue];
        [mar_friend addObject:dic_];
    }
    NSString *s = FORMAT(@"%d", self.registerType);
    [dic setValue:self.sUserId          forKey:@K_LOGIN_USER_ID];
    [dic setValue:self.sUserName        forKey:@K_LOGIN_USER_NAME];
    [dic setValue:self.sPassword        forKey:@K_LOGIN_USER_PWD];
    [dic setValue:self.sPhone           forKey:@K_LOGIN_USER_PHONE];
    [dic setValue:self.sSex             forKey:@K_LOGIN_USER_SEX];
    [dic setValue:self.sBirthday        forKey:@K_LOGIN_USER_BIRTHDAY];
    [dic setValue:self.sEmail           forKey:@K_LOGIN_USER_EMAIL];
    [dic setValue:self.sHeadPath        forKey:@K_LOGIN_USER_HEADPATH];
    [dic setValue:self.sHeadUrl         forKey:@K_LOGIN_USER_HEADURL];
    [dic setValue:self.sSessionId       forKey:@K_LOGIN_USER_SESSION];
    [dic setValue:self.sUnreadEvent     forKey:@K_LOGIN_USER_EVENT];
    [dic setValue:self.sUnreadMessage   forKey:@K_LOGIN_USER_MESSAGE];
    [dic setValue:self.mar_eventType    forKey:@K_LOGIN_USER_EVENTTYPE];
    [dic setValue:s                     forKey:@K_LOGIN_USER_REGISTER];
    [dic setValue:mar_camera            forKey:@K_LOGIN_USER_CAMERA];
    [dic setValue:mar_wifi              forKey:@K_LOGIN_USER_WIFI];
    [dic setValue:mar_friend            forKey:@K_LOGIN_USER_FRIEND];
    return dic;
}

+ (SNUserInfo *)userInfoWithDictionary:(NSDictionary *)dic{

    SNUserInfo *info    = [[SNUserInfo alloc] init];
    info.sUserId        = [dic objectForKey:@K_LOGIN_USER_ID];
    info.sUserName      = [dic objectForKey:@K_LOGIN_USER_NAME];
    info.sPassword      = [dic objectForKey:@K_LOGIN_USER_PWD];
    info.sPhone         = [dic objectForKey:@K_LOGIN_USER_PHONE];
    info.sSex           = [dic objectForKey:@K_LOGIN_USER_SEX];
    info.sBirthday      = [dic objectForKey:@K_LOGIN_USER_BIRTHDAY];
    info.sEmail         = [dic objectForKey:@K_LOGIN_USER_EMAIL];
    info.sHeadUrl       = [dic objectForKey:@K_LOGIN_USER_HEADURL];
    info.sHeadPath      = [dic objectForKey:@K_LOGIN_USER_HEADPATH];
    info.sSessionId     = [dic objectForKey:@K_LOGIN_USER_SESSION];
    info.sUnreadEvent   = [dic objectForKey:@K_LOGIN_USER_EVENT];
    info.sUnreadMessage = [dic objectForKey:@K_LOGIN_USER_MESSAGE];
    info.mar_eventType  = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@K_LOGIN_USER_EVENTTYPE]];
    info.registerType   = (int)[[dic objectForKey:@K_LOGIN_USER_REGISTER] integerValue];
    
    NSArray *ar_camera = [dic objectForKey:@K_LOGIN_USER_CAMERA];
    for (int i = 0; i < ar_camera.count; i++) {
        if (![ar_camera[i] isKindOfClass:[NSDictionary class]]) {
            Dlog(@"数据出错");
            return nil;
        }
        SNCameraInfo *cmrInfo = [SNCameraInfo cameraInfoWithDictionary:ar_camera[i]];
        [info.mar_camera addObject:cmrInfo];
    }
    NSArray *ar_wf = [dic objectForKey:@K_LOGIN_USER_WIFI];
    for (int i = 0; i < ar_wf.count; i++) {
        if (![ar_wf[i] isKindOfClass:[NSDictionary class]]) {
            Dlog(@"数据出错");
            return nil;
        }
        SNWIFIInfo *wfInfo = [SNWIFIInfo wifiInfoWithDictionary:ar_wf[i]];
        [info.mar_wifi addObject:wfInfo];
    }
    NSArray *ar_frd = [dic objectForKey:@K_LOGIN_USER_FRIEND];
    for (int i = 0; i < ar_frd.count; i++) {
        if (![ar_frd[i] isKindOfClass:[NSDictionary class]]) {
            Dlog(@"数据出错");
            return nil;
        }
        SNFriendInfo *frdInfo = [SNFriendInfo friendInfoWithDictionary:ar_frd[i]];
        [info.mar_friend addObject:frdInfo];
    }
    return info;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.sUserId        = [aDecoder decodeObjectForKey:@"sUserId"];
        self.sUserName      = [aDecoder decodeObjectForKey:@"sUserName"];
        self.sPassword      = [aDecoder decodeObjectForKey:@"sPassword"];
        self.sPhone         = [aDecoder decodeObjectForKey:@"sPhone"];
        self.sSex           = [aDecoder decodeObjectForKey:@"sSex"];
        self.sBirthday      = [aDecoder decodeObjectForKey:@"sBirthday"];
        self.sEmail         = [aDecoder decodeObjectForKey:@"sEmail"];
        self.sHeadUrl       = [aDecoder decodeObjectForKey:@"sHeadUrl"];
        self.sHeadPath      = [aDecoder decodeObjectForKey:@"sHeadPath"];
        self.sSessionId     = [aDecoder decodeObjectForKey:@"sSessionId"];
        self.mar_camera     = [aDecoder decodeObjectForKey:@"mar_camera"];
        self.mar_wifi       = [aDecoder decodeObjectForKey:@"mar_wifi"];
        self.mar_friend     = [aDecoder decodeObjectForKey:@"mar_friend"];
        self.registerType   = (int)[aDecoder decodeIntegerForKey:@"registerType"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_sUserId       forKey:@"sUserId"];
    [aCoder encodeObject:_sUserName     forKey:@"sUserName"];
    [aCoder encodeObject:_sPassword     forKey:@"sPassword"];
    [aCoder encodeObject:_sPhone        forKey:@"sPhone"];
    [aCoder encodeObject:_sSex          forKey:@"sSex"];
    [aCoder encodeObject:_sBirthday     forKey:@"sBirthday"];
    [aCoder encodeObject:_sEmail        forKey:@"sEmail"];
    [aCoder encodeObject:_sHeadUrl      forKey:@"sHeadUrl"];
    [aCoder encodeObject:_sHeadPath     forKey:@"sHeadPath"];
    [aCoder encodeObject:_sSessionId    forKey:@"sSessionId"];
    [aCoder encodeObject:_mar_camera    forKey:@"mar_camera"];
    [aCoder encodeObject:_mar_wifi      forKey:@"mar_wifi"];
    [aCoder encodeObject:_mar_friend    forKey:@"mar_friend"];
    [aCoder encodeInteger:_registerType forKey:@"registerType"];
}


-(NSString *)description
{
    NSString *sDscpt = [NSString stringWithFormat:@"sUserId = %@, sUserName = %@, sPassword = %@, sPhone = %@, sSex = %@, sBirthday = %@, sEmail = %@, sHeadUrl = %@, sHeadPath = %@, sSessionId = %@, registerType = %d, mar_camera = %@, mar_wifi = %@, mar_friend = %@, eventType = %@", self.sUserId, self.sUserName, self.sPassword, self.sPhone, self.sSex, self.sBirthday, self.sEmail, self.sHeadUrl, self.sHeadPath, self.sSessionId, (int)self.registerType, self.mar_camera, self.mar_wifi, self.mar_friend, self.mar_eventType];
    return sDscpt;
}


@end
