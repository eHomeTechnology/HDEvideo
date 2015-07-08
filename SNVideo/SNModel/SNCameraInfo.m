//
//  SNCameraInfo.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-21.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNCameraInfo.h"

@implementation SNCameraInfo

- (id)init{

    if (self = [super init]) {
        self.wifiInfo = [[SNWIFIInfo alloc] init];
    }
    return self;
}
- (NSMutableDictionary *)dictionaryValue{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDictionary *dic_wifi = [self.wifiInfo dictionaryValue];
    [dic setValue:self.sDeviceId                        forKey:@K_CAMERA_ID];
    [dic setValue:self.sDeviceName                      forKey:@K_CAMERA_NAME];
    [dic setValue:self.sDeviceCode                      forKey:@K_CAMERA_CODE];
    [dic setValue:self.sBelongName                      forKey:@K_CAMERA_BLONG_NAME];
    [dic setValue:dic_wifi                              forKey:@K_CAMERA_WIFI];
    [dic setValue:self.sPhotoUrl                        forKey:@K_CAMERA_URL];
    [dic setValue:self.sPhotoPath                       forKey:@K_CAMERA_PATH];
    [dic setValue:self.mar_event                        forKey:@K_CAMERA_EVENT];
    [dic setValue:FORMAT(@"%d", _isBelongOther)         forKey:@K_CAMERA_IS_BELONG];
    [dic setValue:FORMAT(@"%ld", (long)_sysStatus)      forKey:@K_CAMERA_SYS];
    [dic setValue:FORMAT(@"%ld", (long)_lineStatus)     forKey:@K_CAMERA_LINE];
    [dic setValue:FORMAT(@"%ld", (long)_shareStatus)    forKey:@K_CAMERA_SHARE];
    [dic setValue:FORMAT(@"%ld", (long)_sdStatus)       forKey:@K_CAMERA_SD_STATUS];
    [dic setValue:FORMAT(@"%ld", (long)_deviceType)     forKey:@K_CAMERA_DEVICE_TYPE];
    [dic setValue:FORMAT(@"%ld", (long)_staticStream)   forKey:@K_CAMERA_STATICSTREAM];
    return dic;
}

+ (SNCameraInfo *)cameraInfoWithDictionary:(NSDictionary *)dic{
    SNCameraInfo *info  = [[SNCameraInfo alloc] init];
    info.sDeviceId      = [dic  objectForKey:@K_CAMERA_ID];
    info.sDeviceName    = [dic  objectForKey:@K_CAMERA_NAME];
    info.sDeviceCode    = [dic  objectForKey:@K_CAMERA_CODE];
    info.sBelongName    = [dic  objectForKey:@K_CAMERA_BLONG_NAME];
    info.sPhotoUrl      = [dic  objectForKey:@K_CAMERA_URL];
    info.sPhotoPath     = [dic  objectForKey:@K_CAMERA_PATH];
    info.mar_event      = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@K_CAMERA_EVENT]];
    info.isBelongOther  = [[dic objectForKey:@K_CAMERA_IS_BELONG]       boolValue];
    info.sysStatus      = [[dic objectForKey:@K_CAMERA_SYS]             integerValue];
    info.lineStatus     = [[dic objectForKey:@K_CAMERA_LINE]            integerValue];
    info.shareStatus    = [[dic objectForKey:@K_CAMERA_SHARE]           integerValue];
    info.sdStatus       = [[dic objectForKey:@K_CAMERA_SD_STATUS]       integerValue];
    info.deviceType     = [[dic objectForKey:@K_CAMERA_DEVICE_TYPE]     integerValue];
    info.staticStream   = [[dic objectForKey:@K_CAMERA_STATICSTREAM]    integerValue];
    info.wifiInfo       = [SNWIFIInfo wifiInfoWithDictionary:[dic objectForKey:@K_CAMERA_WIFI]];
    return info;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.sDeviceId      = [aDecoder decodeObjectForKey:@"sDeviceId"];
        self.sDeviceName    = [aDecoder decodeObjectForKey:@"sDeviceName"];
        self.sDeviceCode    = [aDecoder decodeObjectForKey:@"sDeviceCode"];
        self.sBelongName    = [aDecoder decodeObjectForKey:@"sBelongName"];
        self.wifiInfo       = [aDecoder decodeObjectForKey:@"wifiInfo"];
        self.sPhotoUrl      = [aDecoder decodeObjectForKey:@"sPhotoUrl"];
        self.sPhotoPath     = [aDecoder decodeObjectForKey:@"sPhotoPath"];
        self.sysStatus      = [aDecoder decodeIntegerForKey:@"sysStatus"];
        self.lineStatus     = [aDecoder decodeIntegerForKey:@"lineStatus"];
        self.shareStatus    = [aDecoder decodeIntegerForKey:@"shareStatus"];
        self.sdStatus       = [aDecoder decodeIntegerForKey:@"sdStatus"];
        self.isBelongOther  = [aDecoder decodeBoolForKey:@"isBelongOther"];
    
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_sDeviceId     forKey:@"sDeviceId"];
    [aCoder encodeObject:_sDeviceName   forKey:@"sDeviceName"];
    [aCoder encodeObject:_sDeviceCode   forKey:@"sDeviceCode"];
    [aCoder encodeObject:_sBelongName   forKey:@"sBelongName"];
    [aCoder encodeObject:_wifiInfo      forKey:@"wifiInfo"];
    [aCoder encodeObject:_sPhotoUrl     forKey:@"sPhotoUrl"];
    [aCoder encodeObject:_sPhotoPath    forKey:@"sPhotoPath"];
    [aCoder encodeInteger:_sysStatus    forKey:@"sysStatus"];
    [aCoder encodeInteger:_lineStatus   forKey:@"lineStatus"];
    [aCoder encodeInteger:_shareStatus  forKey:@"shareStatus"];
    [aCoder encodeInteger:_sdStatus     forKey:@"sdStatus"];
    [aCoder encodeBool:_isBelongOther   forKey:@"isBelongOther"];
}


-(NSString *)description
{
    NSString *sDscpt = [NSString stringWithFormat:@"sDeviceId = %@, sDeviceName = %@, sDeviceCode = %@, sBelongName = %s, wifiInfo = %@, sPhotoUrl = %@, sPhotoPath = %@,, isBelongOther = %d, sysStatus = %d, lineStatus = %d, shareStatus = %d, sdStatus = %d, staticStream = %d, event = %@", self.sDeviceId, self.sDeviceName, self.sDeviceCode, [self.sBelongName UTF8String], self.wifiInfo, self.sPhotoUrl, self.sPhotoPath,self.isBelongOther, (int)self.sysStatus, (int)self.lineStatus, (int)self.shareStatus, (int)self.sdStatus, (int)self.staticStream, self.mar_event];
    return sDscpt;
}

@end
