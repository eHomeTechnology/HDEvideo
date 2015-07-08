//
//  SNPhotoInfo.h
//  SNVideo
//
//  Created by Thinking on 14-9-11.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

typedef NS_ENUM(NSInteger, SNPhotoType) {
    SNPhotoPicture = 0,    //图片
    SNPhotoVideo,          //视频
};

#import <Foundation/Foundation.h>

@interface SNPhotoInfo : NSObject

#define K_PHOTO_TYPE        "k_photoType"
#define K_PHOTO_TIME        "k_photoTime"
#define K_PHOTO_DEVICEID    "k_photoDeviceID"
#define K_PHOTO_NAME        "k_photoName"
#define K_PHOTO_PATH        "k_photoPath"
#define K_PHOTO_URL         "k_photoURL"
#define K_PHOTO_ID          "k_photoID"
#define K_PHOTO_ARRAY       "k_photoArray"

@property (assign) SNPhotoType  pType;          //数据类型，图片、视频
@property (strong) NSString     *takeTime;      //拍摄时间
@property (strong) NSString     *takeDeviceID;  //拍摄设备ID
@property (strong) NSString     *photoName;     //要保存的图片名字
@property (strong) NSString     *photoPath;     //在本地的路径
@property (strong) NSString     *photoURL;      //在服务器的路径
@property (strong) NSString     *photoID;       //在服务器中的ID

+ (SNPhotoInfo *)serverInfoWithDictionary:(NSDictionary *)dic;

- (NSMutableDictionary *)dictionaryValue;

+ (NSArray *)classFullForTime:(NSArray *)ar_t;

@end
