//
//  SNPicket.h
//  SNVideo
//
//  Created by Thinking on 14-9-5.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

typedef NS_ENUM(NSInteger, SNPicketUpdateType) {
    SNWithOutUpdate = 0,    //为不需要更新升级
    SNNeedUpdate,           //需要更新升级
    SNMustUpdate,           //强制更新升级

};

#import <Foundation/Foundation.h>

#define K_PICKET_UPDATE     "k_picketUpdate"
#define K_PICKET_NAME       "k_picketName"
#define K_PICKET_VERSION    "k_picketVersion"
#define K_PICKET_SIZE       "k_picketSize"
#define K_PICKET_URL        "k_picketURL"

@interface SNPicketInfo : NSObject

@property (assign) SNPicketUpdateType iUpdate;
@property (strong) NSString *sName;
@property (strong) NSString *sVersion;
@property (strong) NSString *sSize;
@property (strong) NSString *sURL;

@end
