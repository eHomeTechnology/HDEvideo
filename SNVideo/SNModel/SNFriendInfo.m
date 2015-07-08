//
//  SNFriendInfo.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-27.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNFriendInfo.h"

@implementation SNFriendInfo

+ (SNFriendInfo *)friendInfoWithDictionary:(NSDictionary *)dic{
    
    SNFriendInfo *friendInfo    = [[SNFriendInfo alloc] init];
    friendInfo.sAccount         = [dic objectForKey:@K_FRIEND_ACCOUNT];
    friendInfo.sNickName        = [dic objectForKey:@K_FRIEND_NICK_NAME];
    friendInfo.sImageUrl        = [dic objectForKey:@K_FRIEND_IMAGE_URL];
    friendInfo.sImagePath       = [dic objectForKey:@K_FRIEND_IMAGE_PATH];
    friendInfo.sSex             = [dic objectForKey:@K_FRIEND_SEX];
    friendInfo.sEmail           = [dic objectForKey:@K_FRIEND_EMAIL];
    return friendInfo;
}
- (NSMutableDictionary *)dictionaryValue{
   
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_sAccount     forKey:@K_FRIEND_ACCOUNT];
    [dic setValue:_sNickName    forKey:@K_FRIEND_NICK_NAME];
    [dic setValue:_sImageUrl    forKey:@K_FRIEND_IMAGE_URL];
    [dic setValue:_sImagePath   forKey:@K_FRIEND_IMAGE_PATH];
    [dic setValue:_sSex         forKey:@K_FRIEND_SEX];
    [dic setValue:_sEmail       forKey:@K_FRIEND_EMAIL];
    return dic;
}

@end
