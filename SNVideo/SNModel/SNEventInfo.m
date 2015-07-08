//
//  SNEventInof.m
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNEventInfo.h"

@implementation SNEventInfo

+ (SNEventInfo *)eventInfoWithDictionary:(NSDictionary *)dic
{
    SNEventInfo *event      = [[SNEventInfo alloc] init];
    event.sDeviceID          = dic[@K_EVENT_DEVICEID]    == nil? @"" : dic[@K_EVENT_DEVICEID];
    event.sEventID           = dic[@K_EVENT_ID]          == nil? @"" : dic[@K_EVENT_ID];
    event.sEventName         = dic[@K_EVENT_NAME]        == nil? @"" : dic[@K_EVENT_NAME];
    event.sEventTypeID       = dic[@K_EVENT_TYPE]        == nil? @"" : dic[@K_EVENT_TYPE];
    NSString *time          = dic[@K_EVENT_TIME];
    if (time == nil) {
        event.eventTime     = nil;
    }else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        event.eventTime     = [formatter dateFromString:time];
    }
    event.sImageUrl          = dic[@K_EVENT_IMAGEURL]    == nil? @"" : dic[@K_EVENT_IMAGEURL];
    event.sImagePath         = dic[@K_EVENT_IMAGEPATH]   == nil? @"" : dic[@K_EVENT_IMAGEPATH];
    return event;
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *time = [formatter stringFromDate:_eventTime];
    [dic setValue:_sDeviceID           forKey:@K_EVENT_DEVICEID];
    [dic setValue:_sEventID            forKey:@K_EVENT_ID];
    [dic setValue:_sEventName          forKey:@K_EVENT_NAME];
    [dic setValue:_sEventTypeID        forKey:@K_EVENT_TYPE];
    [dic setValue:time                forKey:@K_EVENT_TIME];
    [dic setValue:_sImageUrl           forKey:@K_EVENT_IMAGEURL];
    [dic setValue:_sImagePath          forKey:@K_EVENT_IMAGEPATH];
    return dic;
}

@end

@implementation SNCameraEvents

- (id)init{

    if (self = [super init]) {
        self.mar_events = [[NSMutableArray alloc] init];
    }
    return self;
}

@end