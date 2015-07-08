//
//  SNWIFIInfo.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-21.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_WIFI_SSID       "k_sSSID"
#define K_WIFI_PWD        "k_sPassword"

@interface SNWIFIInfo : NSObject

@property (strong) NSString          *sSSID;         //WIFI名称
@property (strong) NSString          *sPassword;     //密码

+ (SNWIFIInfo *)wifiInfoWithDictionary:(NSDictionary *)dic;
+ (id)infoWithSSID:(NSString *)sId password:(NSString *)sPwd;
- (id)initWithSSID:(NSString *)sId password:(NSString *)sPwd;
- (NSMutableDictionary *)dictionaryValue;
@end