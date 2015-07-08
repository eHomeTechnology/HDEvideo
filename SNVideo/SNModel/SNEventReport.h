//
//  SNEventReport.h
//  SNVideo
//
//  Created by Thinking on 14-11-5.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNEventReport : NSObject

#define K_EVENTREP_DEVICEID        "k_eventReportDeviceID"
#define K_EVENTREP_WEEK            "k_eventReportWeek"
#define K_EVENTREP_DATE            "k_eventReportDate"

@property (strong) NSString     *deviceID;      //设备ID
@property (strong) NSArray      *ar_weekReport; //事件周报
@property (strong) NSArray      *ar_dateReport; //事件日报
@property (strong) NSArray      *ar_eventTimes; //事件时间列表；

+ (SNEventReport *)eventInfoWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)dictionaryValue;
+ (NSDictionary *)classFullForEventType:(NSArray *)ar_t;
+ (NSDictionary *)classFullForEventTime:(NSArray *)ar_t;

@end

@interface SNEventReportInfo : NSObject

#define K_EVENT_REPORTINFO_TYPENAME     "k_eventReportInfoTypeName"
#define K_EVENT_REPORTINFO_CONFIGNAME   "k_eventReportInfoConfigName"
#define K_EVENT_REPORTINFO_TYPE         "k_eventReportInfoType"
#define K_EVENT_REPORTINFO_DESCRIP      "k_eventReportInfoDescrip"
#define K_EVENT_REPORTINFO_DATE         "k_eventReportInfoDate"
#define K_EVENT_REPORTINFO_COUNT        "k_eventReportInfoCount"

@property (strong) NSString         *typeName;      //事件类型名称
@property (strong) NSString         *configName;    //事件设置名称
@property (strong) NSString         *type;          //事件类型编号
@property (strong) NSString         *descrip;       //描述
@property (strong) NSDate           *date;          //日期
@property (strong) NSString         *count;         //事件次数
@property (strong) NSMutableArray   *mar_statistics;//统计列表

+ (SNEventReportInfo *)eventInfoWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)dictionaryValue;

@end