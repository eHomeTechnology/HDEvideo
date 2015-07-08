//
//  SNBese64.h
//  SNVideo
//
//  Created by Thinking on 14-9-5.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNBase64 : NSObject

+ (NSString *)base64StringFromText:(NSString *)text;

+ (NSString *)textFromBase64String:(NSString *)base64;

+ (NSString *) hmacSha1:(NSString*)key text:(NSString*)text;

@end
