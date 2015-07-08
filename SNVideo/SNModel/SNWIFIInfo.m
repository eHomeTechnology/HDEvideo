//
//  SNWIFIInfo.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-21.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNWIFIInfo.h"

@implementation SNWIFIInfo

+ (SNWIFIInfo *)wifiInfoWithDictionary:(NSDictionary *)dic{
    SNWIFIInfo *info    = [[SNWIFIInfo alloc] init];
    info.sSSID          = [dic objectForKey:@K_WIFI_SSID];
    info.sPassword      = [dic objectForKey:@K_WIFI_PWD];
    return info;
}

+ (id)infoWithSSID:(NSString *)sId password:(NSString *)sPwd{
    SNWIFIInfo *info = [SNWIFIInfo new];
    info.sSSID      = sId;
    info.sPassword  = sPwd;
    return info;
}

- (id)initWithSSID:(NSString *)sId password:(NSString *)sPwd{
    if (self) {
        self.sSSID      = sId;
        self.sPassword  = sPwd;
        return self;
    }
    return nil;
}

- (NSMutableDictionary *)dictionaryValue{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.sSSID        forKey:@K_WIFI_SSID];
    [dic setValue:self.sPassword    forKey:@K_WIFI_PWD];
    return dic;
}



-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.sSSID        = [aDecoder decodeObjectForKey:@"sSSID"];
        self.sPassword    = [aDecoder decodeObjectForKey:@"sPassword"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.sSSID      forKey:@"sSSID"];
    [aCoder encodeObject:self.sPassword  forKey:@"sPassword"];

}


-(NSString *)description
{
    NSString *sDscpt = [NSString stringWithFormat:@"sSSID = %@, sPassword = %@", self.sSSID, self.sPassword];
    return sDscpt;
}


@end
