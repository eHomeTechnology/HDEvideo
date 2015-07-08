//
//  SNGlobalInfo.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-25.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNGlobalInfo.h"


static SNGlobalInfo* pData = NULL;
@implementation SNGlobalInfo

+ (SNGlobalInfo *)instance{
    @synchronized(self){
        if (pData == NULL){
            pData = [[SNGlobalInfo alloc] init];
            pData.userInfo = [[SNUserInfo alloc] init];
        }
    }
    return pData;
}

- (void)reset{
    pData = NULL;
}

@end
