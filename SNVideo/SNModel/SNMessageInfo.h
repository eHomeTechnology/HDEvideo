//
//  SNMessageInfo.h
//  SNVideo
//
//  Created by Thinking on 14-9-9.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#define MSG_SYSTEM      @"系统通知"
#define MSG_DEVICEPUSH  @"推送消息"
#define MSG_EVENT       @"事件监测消息"

typedef NS_ENUM(int, SNMessageType) {
    SNMsgSystem = 0,    //系统通知
    SNMsgDevicePush,    //设备推送消息
    SNMsgEvent,         //事件监测消息
};

#import <Foundation/Foundation.h>

#define K_MESSAGE_ID       "k_msgId"
#define K_MESSAGE_TIME     "k_msgTime"
#define K_MESSAGE_CONTENT  "k_msgContent"
#define K_MESSAGE_TYPE     "k_msgType"
#define K_MESSAGE_LEVEL    "k_msgLevel"


@interface SNMessageInfo : NSObject

@property (strong) NSString         *sMsgID;       //唯一标识
@property (strong) NSString         *sMsgTime;     //时间
@property (strong) NSString         *sContent;     //内容
@property (assign) SNMessageType    msgType;       //消息类型
@property (assign) int              msgLevel;      //消息级别 0:低 1:中 2-9:高

+ (SNMessageInfo *)messageInfoWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)dictionaryValue;

@end
