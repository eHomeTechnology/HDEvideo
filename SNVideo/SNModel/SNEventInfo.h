//
//  SNEventInof.h
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNCameraEvents;
@interface SNEventInfo : NSObject

#define K_EVENT_DEVICEID        "k_eventDeviceID"
#define K_EVENT_ID              "k_eventID"
#define K_EVENT_NAME            "k_eventName"
#define K_EVENT_TYPE            "k_eventType"
#define K_EVENT_TIME            "k_eventTime"
#define K_EVENT_IMAGEURL        "k_eventImageUrl"
#define K_EVENT_IMAGEPATH       "k_eventImagePath"

@property (strong) NSString     *sDeviceID;      //设备ID
@property (strong) NSString     *sEventID;       //事件ID
@property (strong) NSString     *sEventName;     //事件名称
@property (strong) NSString     *sEventTypeID;   //事件类型
@property (strong) NSDate       *eventTime;     //事件发生的时间
@property (strong) NSString     *sImageUrl;      //事件图片网络地址
@property (strong) NSString     *sImagePath;     //事件图片本地地址
@property (assign) BOOL         isEffect;       //事件是否生效
@property (strong) NSArray      *ar_area;       //事件检测区域

+ (SNEventInfo *)eventInfoWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)dictionaryValue;

@end


@interface SNCameraEvents : NSObject

@property (strong) NSString         *sDeviceID;
@property (strong) NSMutableArray   *mar_events;

@end