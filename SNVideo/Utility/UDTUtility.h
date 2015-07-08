//
//  SNUtility.h
//  UDTTest
//
//  Created by Hu Dennis on 14-8-8.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "api.h"
#import <UIKit/UIKit.h>
#include <arpa/inet.h>
#include <netdb.h>

#include <net/if.h>

#include <ifaddrs.h>
#import <dlfcn.h>

#ifndef WIN32
#include <cstdlib>
#include <cstring>
#include <netdb.h>
#include <signal.h>
#include <unistd.h>
#else
#include <winsock2.h>
#include <ws2tcpip.h>
#include <wspiapi.h>
#endif
#include <algorithm>
#include <iostream>

#include "udt.h"

#define IS_LAN 0
#define SERVER_HOST @"121.40.133.242"

using namespace std;

const int g_IP_Version = AF_INET;
const int g_Socket_Type = SOCK_STREAM;
//const char g_ServerHost[] = "121.40.133.242";//"192.168.73.249";//
//const NSString *g_sPort = @"9999";

#define MAXADDRS    32
extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];


@interface UDTUtility : NSObject

string request2ConnectCamera_02(string sServerIp, int iPort, string sBuffer);

//正式封装接口

//协议02，告诉服务器开启摄像头
+ (NSDictionary *)tellServer2TurnOnCamera:(NSString *)sCameraId serverIp:(NSString *)sServerIp serverPort:(NSString *)sServerPort;
//协议11，告诉服务器我的本地ip地址和端口，以获🉐摄像头的ip和端口
+ (NSDictionary *)tellServerMyLocalAddress:(NSDictionary *)dic serverIp:(NSString *)sServerIp;
//协议12，告诉服务器打洞完成
+ (NSDictionary *)tellServerBurrowComplete:(NSDictionary *)dc isSuccess:(BOOL)isSuc;
//协议14，告诉服务器打洞成功
+ (NSDictionary *)tellServerBurrowSuccess:(NSDictionary *)dic_server parameter:(NSDictionary *)dic_p;
//协议04，告诉服务器开启声波
+ (NSArray *)tellService2TurnOnCameraSoundListening:(NSString *)sCameraId;
//打洞－内网
string burrowLocal(NSString *sBurrowIp, int iPort);
@end
