//
//  SNServerInfo.h
//  SNVideo
//
//  Created by Hu Dennis on 14-9-5.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <Foundation/Foundation.h>

#define K_SERVER_HTTP       "k_serverHttp"
#define K_SERVER_REAL       "k_serverReal"
#define K_SERVER_BACK       "k_serverBack"
#define K_SERVER_SOCKET     "k_serverSocket"
#define K_SERVER_P2P        "k_serverP2p"
#define K_SERVER_UDT_IP     "k_serverUdtIp"
#define K_SERVER_UDT_PORT   "k_serverUdtPort"

@interface SNServerInfo : NSObject

@property (strong) NSString *sHttp;         //http通信url
@property (strong) NSString *sRtsp_real;    //实时中转服务器地址 self+设备编号.sdp
@property (strong) NSString *sRtsp_back;    //回放服务器地址 self+设备id/设备id_yyyyMMddHH.mp4
@property (strong) NSString *sSocket;       //udt长连接通信ip和端口 IP和端口间用冒号“:”隔开
@property (strong) NSString *sP2p;          //P2P穿透服务器ip
@property (strong) NSString *sUdtIp;
@property (strong) NSString *sUdtPort;

+ (SNServerInfo *)serverInfoWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)dictionaryValue;

@end
