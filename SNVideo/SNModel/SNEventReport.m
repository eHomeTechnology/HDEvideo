//
//  SNEventReport.m
//  SNVideo
//
//  Created by Thinking on 14-11-5.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNEventReport.h"

@implementation SNEventReport

+ (SNEventReport *)eventInfoWithDictionary:(NSDictionary *)dic
{
    SNEventReport *eventReport      = [[SNEventReport alloc] init];
    eventReport.deviceID            = dic[@K_EVENTREP_DEVICEID]    == nil? @"" : dic[@K_EVENTREP_DEVICEID];
    eventReport.ar_weekReport       = dic[@K_EVENTREP_WEEK];
    eventReport.ar_dateReport       = dic[@K_EVENTREP_DATE];
    return eventReport;
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_deviceID           forKey:@K_EVENTREP_DEVICEID];
    [dic setValue:_ar_weekReport      forKey:@K_EVENTREP_WEEK];
    [dic setValue:_ar_dateReport      forKey:@K_EVENTREP_DATE];
    return dic;
}

NSComparisonResult (^sortBlock)(id, id) = ^(SNEventReportInfo *obj1, SNEventReportInfo *obj2) {
    
    if ([obj1.date timeIntervalSinceDate:obj2.date] > 0) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    if ([obj1.date timeIntervalSinceDate:obj2.date] < 0) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

/* 按日期降序排序，按事件归类*/
+ (NSDictionary *)classFullForEventType:(NSArray *)ar_t
{
    NSMutableArray      *mar_key  = [[NSMutableArray alloc] init];
    NSString            *type     = @"";
    NSMutableDictionary *dic_type = [[NSMutableDictionary alloc] init];
    //按日期归类到数组
    for (int i = 0; i < ar_t.count; i++) {
        SNEventReportInfo *reInfo = [ar_t objectAtIndex:i];
        
        if ([type isEqualToString:reInfo.type]) {
            NSMutableArray  *ar_type = [dic_type valueForKey:reInfo.type];
            [ar_type addObject:reInfo];
            [dic_type setObject:ar_type forKey:type];
        }else{
            NSMutableArray  *ar_type = [dic_type valueForKey:reInfo.type];
            if (ar_type == nil) {
                ar_type = [[NSMutableArray alloc] init];
                [mar_key addObject:reInfo.type];
            }
            type = reInfo.type;
            [ar_type addObject:reInfo];
            [dic_type setObject:ar_type forKey:type];
        }
        
    }
    
    for (int i = 0; i < mar_key.count; i++) {
        NSString *key = [mar_key objectAtIndex:i];
        NSArray *ar_key_t = [dic_type valueForKey:key];
        NSArray *ar_result_t = [ar_key_t sortedArrayUsingComparator:sortBlock];
        [dic_type setObject:ar_result_t forKey:key];
        
    }
    
    
    return dic_type;
}

NSComparisonResult (^sortTimeString)(id, id) = ^(NSString *obj1, NSString *obj2) {
    
   
    return [obj1 compare:obj2];
};

/* 按日期降序排序，按时间归类*/
+ (NSDictionary *)classFullForEventTime:(NSArray *)ar_t
{
    NSMutableArray      *mar_key  = [[NSMutableArray alloc] init];
    NSString            *date_t   = @"";
    NSMutableDictionary *dic_type = [[NSMutableDictionary alloc] init];
    NSDateFormatter *formatter    = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd"];
    //按日期归类到数组
    for (int i = 0; i < ar_t.count; i++) {
        SNEventReportInfo *reInfo = [ar_t objectAtIndex:i];
        NSString *date_rep = [formatter stringFromDate:reInfo.date];
        if ([date_t isEqualToString:date_rep]) {
            NSMutableArray  *ar_date = [dic_type valueForKey:date_rep];
            [ar_date addObject:reInfo];
            [dic_type setObject:ar_date forKey:date_t];
        }else{
            NSMutableArray  *ar_date = [dic_type valueForKey:date_rep];
            if (ar_date == nil) {
                ar_date = [[NSMutableArray alloc] init];
                [mar_key addObject:date_rep];
            }
            date_t = date_rep;
            [ar_date addObject:reInfo];
            [dic_type setObject:ar_date forKey:date_t];
        }
        
    }
    
    NSArray *ar_result_t = [mar_key sortedArrayUsingComparator:sortTimeString];
   
    [dic_type setObject:ar_result_t forKey:@"time"];
    
    
    return dic_type;
}

@end

@implementation SNEventReportInfo

+ (SNEventReportInfo *)eventInfoWithDictionary:(NSDictionary *)dic
{
    SNEventReportInfo *eventReportInof  = [[SNEventReportInfo alloc] init];
    eventReportInof.typeName            = dic[@K_EVENT_REPORTINFO_TYPENAME]    == nil? @"" : dic[@K_EVENT_REPORTINFO_TYPENAME];
    eventReportInof.configName          = dic[@K_EVENT_REPORTINFO_CONFIGNAME]  == nil? @"" : dic[@K_EVENT_REPORTINFO_CONFIGNAME];
    eventReportInof.type                = dic[@K_EVENT_REPORTINFO_TYPE]        == nil? @"" : dic[@K_EVENT_REPORTINFO_TYPE];
    eventReportInof.descrip             = dic[@K_EVENT_REPORTINFO_DESCRIP]     == nil? @"" : dic[@K_EVENT_REPORTINFO_DESCRIP];
    eventReportInof.count               = dic[@K_EVENT_REPORTINFO_COUNT]       == nil? @"" : dic[@K_EVENT_REPORTINFO_COUNT];
    if (dic[@K_EVENT_REPORTINFO_DATE] != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        eventReportInof.date = [formatter dateFromString:dic[@K_EVENT_REPORTINFO_DATE]];
    }else{
        eventReportInof.date = nil;
    }
    return eventReportInof;
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_typeName             forKey:@K_EVENT_REPORTINFO_TYPENAME];
    [dic setValue:_configName           forKey:@K_EVENT_REPORTINFO_CONFIGNAME];
    [dic setValue:_type                 forKey:@K_EVENT_REPORTINFO_TYPE];
    [dic setValue:_descrip              forKey:@K_EVENT_REPORTINFO_DESCRIP];
    [dic setValue:_count                forKey:@K_EVENT_REPORTINFO_COUNT];
    if (_date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *time = [formatter stringFromDate:_date];
        [dic setValue:time forKey:@K_EVENT_REPORTINFO_DATE];
    }
    
    return dic;
}

@end
