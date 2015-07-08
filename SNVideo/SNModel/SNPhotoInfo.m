//
//  SNPhotoInfo.m
//  SNVideo
//
//  Created by Thinking on 14-9-11.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNPhotoInfo.h"

@implementation SNPhotoInfo

- (id)init
{
    
    if (self = [super init]) {
        
    }
    return self;
}

+ (SNPhotoInfo *)serverInfoWithDictionary:(NSDictionary *)dic
{
    SNPhotoInfo *photo      = [[SNPhotoInfo alloc] init];
    photo.pType             = [dic[@K_PHOTO_TYPE] intValue];
    photo.takeTime          = dic[@K_PHOTO_TIME];
    photo.takeDeviceID      = dic[@K_PHOTO_DEVICEID];
    photo.photoName         = dic[@K_PHOTO_NAME];
    photo.photoPath         = dic[@K_PHOTO_PATH];
    photo.photoID           = dic[@K_PHOTO_ID] == nil? @"" : dic[@K_PHOTO_ID];
    photo.photoURL          = dic[@K_PHOTO_URL] == nil? @"" : dic[@K_PHOTO_URL];
    return photo;
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:FORMAT(@"%d", (int)self.pType)   forKey:@K_PHOTO_TYPE];
    [dic setValue:_takeTime                forKey:@K_PHOTO_TIME];
    [dic setValue:_takeDeviceID            forKey:@K_PHOTO_DEVICEID];
    [dic setValue:_photoName               forKey:@K_PHOTO_NAME];
    [dic setValue:_photoPath               forKey:@K_PHOTO_PATH];
    [dic setValue:_photoURL                forKey:@K_PHOTO_URL];
    [dic setValue:_photoID                 forKey:@K_PHOTO_ID];
    return dic;
}

+ (NSArray *)classFullForTime:(NSArray *)ar_t
{
    NSMutableArray      *ar_relut = [[NSMutableArray alloc] init];
    NSString            *time = nil;
    NSMutableDictionary *dic_time = nil;
    NSMutableArray      *ar_time = nil;
    //按日期归类到数组
    for (int i = 0; i < ar_t.count; i++) {
        NSDictionary *dic_info = [ar_t objectAtIndex:i];
        
        if ([time isEqualToString:dic_info[@K_PHOTO_TIME]]) {
            [ar_time addObject:dic_info];
            
        }else{
            if (time != nil) {
                [dic_time setObject:ar_time forKey:@K_PHOTO_ARRAY];
                [ar_relut addObject:dic_time];
                ar_time  = nil;
                dic_time = nil;
            }
            time        = dic_info[@K_PHOTO_TIME];
            dic_time    = [[NSMutableDictionary alloc] init];
            ar_time     = [[NSMutableArray alloc] init];
            [dic_time setObject:time forKey:@K_PHOTO_TIME];
            [ar_time addObject:dic_info];
        }
        
        if (i == (ar_t.count - 1)) {
            [dic_time setObject:ar_time forKey:@K_PHOTO_ARRAY];
            [ar_relut addObject:dic_time];
        }
        
    }
    
    return ar_relut;
}

@end
