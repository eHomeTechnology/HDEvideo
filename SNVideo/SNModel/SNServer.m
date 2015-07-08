//
//  SNServerInfo.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-5.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNServer.h"

@implementation SNServerInfo


- (id)init{

    if (self = [super init]) {
        
    }
    return self;
}

+ (SNServerInfo *)serverInfoWithDictionary:(NSDictionary *)dic{

    SNServerInfo *server    = [[SNServerInfo alloc] init];
    server.sHttp            = dic[@K_SERVER_HTTP];
    server.sRtsp_real       = dic[@K_SERVER_REAL];
    server.sRtsp_back       = dic[@K_SERVER_BACK];
    server.sSocket          = dic[@K_SERVER_SOCKET];
    server.sP2p             = dic[@K_SERVER_P2P];
    server.sUdtIp           = dic[@K_SERVER_UDT_IP];
    server.sUdtPort         = dic[@K_SERVER_UDT_PORT];
    return server;

}

- (NSMutableDictionary *)dictionaryValue{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_sHttp        forKey:@K_SERVER_HTTP];
    [dic setValue:_sRtsp_real   forKey:@K_SERVER_REAL];
    [dic setValue:_sRtsp_back   forKey:@K_SERVER_BACK];
    [dic setValue:_sSocket      forKey:@K_SERVER_SOCKET];
    [dic setValue:_sP2p         forKey:@K_SERVER_P2P];
    [dic setValue:_sUdtIp       forKey:@K_SERVER_UDT_IP];
    [dic setValue:_sUdtPort     forKey:@K_SERVER_UDT_PORT];
    return dic;

}
@end
