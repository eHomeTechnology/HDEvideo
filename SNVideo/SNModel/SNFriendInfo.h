//
//  SNFriendInfo.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-27.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_FRIEND_ACCOUNT        "k_friendAccount"
#define K_FRIEND_NICK_NAME      "k_friendNickName"
#define K_FRIEND_IMAGE_URL      "k_friendImageUrl"
#define K_FRIEND_IMAGE_PATH     "k_friendImagePath"
#define K_FRIEND_SEX            "k_friendSex"
#define K_FRIEND_EMAIL          "k_friendEmail"

@interface SNFriendInfo : NSObject

@property (strong) NSString *sAccount;      //账号
@property (strong) NSString *sNickName;     //昵称
@property (strong) NSString *sImageUrl;     //头像图片地址
@property (strong) NSString *sImagePath;    //头像本地路径
@property (strong) NSString *sSex;          //0:男，1:女
@property (strong) NSString *sEmail;        //邮箱

+ (SNFriendInfo *)friendInfoWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)dictionaryValue;

@end
