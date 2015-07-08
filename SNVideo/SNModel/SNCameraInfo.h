//
//  SNCameraInfo.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-21.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNWIFIInfo.h"

typedef NS_ENUM(NSInteger, SNCameraLineStatus) {

    SNCameraLineStatusOff = 0,
    SNCameraLineStatusOn,
};

typedef NS_ENUM(NSInteger, SNCameraSystemStatus) {
    
    SNCameraSystemStatusError = 0,
    SNCameraSystemStatusNormal,
};

typedef NS_ENUM(NSInteger, SNCameraSharedStatus) {
    
    SNCameraSharedStatusUnshared = 0,
    SNCameraSharedStatusShared,
};

typedef NS_ENUM(NSInteger, SNCameraSDStatus) {
    
    SNCameraSDStatusNone = 0,       //未挂载
    SNCameraSDStatusNormal,         //正常
    SNCameraSDStatusNoSpace,        //空间不足
};

typedef NS_ENUM(NSInteger, SNStaticStream) {
    SNStaticStreamOff = 0,          //静止码流关闭
    SNStaticStreamLow,              //静止码流低
    SNStaticStreamHigh,             //静止码流高
    
};

typedef NS_ENUM(NSInteger, SNDeviceType) {
    
    SNDeviceTypeCamera = 0,         //摄像头
    SNDeviceTypeOther,              //其他
};

#define K_CAMERA_ID             "k_sDeviceId"
#define K_CAMERA_NAME           "k_sDeviceName"
#define K_CAMERA_CODE           "k_sDeviceCode"
#define K_CAMERA_BLONG_NAME     "k_sBelongName"
#define K_CAMERA_WIFI           "k_wifiInfo"
#define K_CAMERA_URL            "k_sPhotoUrl"
#define K_CAMERA_PATH           "k_sPhotoPath"
#define K_CAMERA_SYS            "k_sysStatus"
#define K_CAMERA_LINE           "k_lineStatus"
#define K_CAMERA_SHARE          "k_shareStatus"
#define K_CAMERA_IS_BELONG      "k_isBelongOther"
#define K_CAMERA_SD_STATUS      "k_sdStatus"
#define K_CAMERA_DEVICE_TYPE    "k_deviceType"
#define K_CAMERA_STATICSTREAM   "k_staticStream"
#define K_CAMERA_EVENT          "k_event"

@interface SNCameraInfo : NSObject

@property (strong) NSString     *sDeviceId;             //唯一标识,设备IMEI或出厂编号
@property (strong) NSString     *sDeviceName;           //设备名称
@property (strong) NSString     *sDeviceCode;           //设备编号
@property (strong) NSString     *sBelongName;           //设备所属人
@property (strong) SNWIFIInfo   *wifiInfo;              //接入的WIFI
@property (strong) NSString     *sPhotoUrl;             //设备图片地址
@property (strong) NSString     *sPhotoPath;            //设备图片本地地址
@property (assign) BOOL         isBelongOther;          //yes:该摄像头为好友共享，NO:我的摄像头（非共享）

@property (assign) SNCameraSystemStatus sysStatus;      //0:系统异常，1:系统正常
@property (assign) SNCameraLineStatus   lineStatus;     //0:离线，1:在线
@property (assign) SNCameraSharedStatus shareStatus;    //0:处于非共享状态，1:处于共享状态
@property (assign) SNCameraSDStatus     sdStatus;       //sd卡状态, 0：未挂载；1：可用；2：空间不足
@property (assign) SNDeviceType         deviceType;     //设备类型，扩展用
//协议2.0增
@property (assign) SNStaticStream       staticStream;   //静止码流
@property (strong) NSMutableArray       *mar_event;     //事件，格式如@[@{@"code":@"EP01",@"value":@"0"},@{@"code":@"ES01",@"value":@"1"},@{@"code":@"ES02",@"value":@"0"}]

- (NSMutableDictionary *)dictionaryValue;
+ (SNCameraInfo *)cameraInfoWithDictionary:(NSDictionary *)dic;

@end
