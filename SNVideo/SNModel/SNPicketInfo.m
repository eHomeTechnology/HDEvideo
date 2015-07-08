//
//  SNPicket.m
//  SNVideo
//
//  Created by Thinking on 14-9-5.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNPicketInfo.h"

@implementation SNPicketInfo

- (id)init{
    
    if (self = [super init]) {
        
    }
    return self;
}

+ (SNPicketInfo *)serverInfoWithDictionary:(NSDictionary *)dic{
    
    SNPicketInfo *picket    = [[SNPicketInfo alloc] init];
    picket.iUpdate          = (SNPicketUpdateType)[dic[@K_PICKET_UPDATE] intValue];
    picket.sName            = dic[@K_PICKET_NAME];
    picket.sVersion         = dic[@K_PICKET_VERSION];
    picket.sSize            = dic[@K_PICKET_SIZE];
    picket.sURL             = dic[@K_PICKET_URL];
    
    return picket;
    
}

- (NSMutableDictionary *)dictionaryValue{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:FORMAT(@"%d", (int)self.iUpdate)  forKey:@K_PICKET_UPDATE];
    [dic setValue:_sName                    forKey:@K_PICKET_NAME];
    [dic setValue:_sVersion                 forKey:@K_PICKET_VERSION];
    [dic setValue:_sSize                    forKey:@K_PICKET_SIZE];
    [dic setValue:_sURL                     forKey:@K_PICKET_URL];
    
    return dic;
    
}

@end
