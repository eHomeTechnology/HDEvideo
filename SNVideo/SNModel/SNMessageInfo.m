//
//  SNMessageInfo.m
//  SNVideo
//
//  Created by Thinking on 14-9-9.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNMessageInfo.h"

@implementation SNMessageInfo

+ (SNMessageInfo *)messageInfoWithDictionary:(NSDictionary *)dic{
    
    SNMessageInfo *msgInfo  = [[SNMessageInfo alloc] init];
    msgInfo.sMsgID          = [dic objectForKey:@K_MESSAGE_ID];
    msgInfo.sMsgTime        = [dic objectForKey:@K_MESSAGE_TIME];
    msgInfo.sContent        = [dic objectForKey:@K_MESSAGE_CONTENT];
    msgInfo.msgType         = (SNMessageType)[[dic objectForKey:@K_MESSAGE_TYPE] intValue];
    msgInfo.msgLevel        = [[dic objectForKey:@K_MESSAGE_LEVEL] intValue];
    
    return msgInfo;
}
- (NSMutableDictionary *)dictionaryValue{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_sMsgID     forKey:@K_MESSAGE_ID];
    [dic setValue:_sMsgTime   forKey:@K_MESSAGE_TIME];
    [dic setValue:_sContent   forKey:@K_MESSAGE_CONTENT];
    [dic setValue:[NSString stringWithFormat:@"%d", (int)self.msgType]     forKey:@K_MESSAGE_TYPE];
    [dic setValue:[NSString stringWithFormat:@"%d", (int)self.msgLevel]    forKey:@K_MESSAGE_LEVEL];
    
    return dic;
}

@end
