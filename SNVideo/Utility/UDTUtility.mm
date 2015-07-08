//
//  SNUtility.m
//  UDTTest
//
//  Created by Hu Dennis on 14-8-8.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "UDTUtility.h"

//------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/ethernet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>

#define min(a,b)    ((a) < (b) ? (a) : (b))
#define max(a,b)    ((a) > (b) ? (a) : (b))
#define BUFFERSIZE  4000

char    *if_names[MAXADDRS];
char    *ip_names[MAXADDRS];
char    *hw_addrs[MAXADDRS];

unsigned long ip_addrs[MAXADDRS];
const NSString *g_sPort = @"9999";
const NSString *burrow_port = @"7777";

@implementation UDTUtility

+ (NSString *)localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

int createUDTSocketWithModel(UDTSOCKET& usock, int port, bool isRendezvous)
{
    addrinfo hints;
    addrinfo* res;
    
    memset(&hints, 0, sizeof(struct addrinfo));
    
    hints.ai_flags = AI_PASSIVE;
    hints.ai_family = g_IP_Version;
    hints.ai_socktype = g_Socket_Type;
    
    //string service("9000");
    char service[16];
    sprintf(service, "%d", port);
    Dlog("绑定穿透本地iPort:%s\n", service);
    if (0 != getaddrinfo(NULL, service, &hints, &res))
    {
        cout << "------" << endl;
        cout << "illegal port number or port is busy.\n" << endl;
        return -1;
    }
    usock = UDT::socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    // since we will start a lot of connections, we set the buffer size to smaller value.
    int snd_buf = 64000;
    int rcv_buf = 64000;
    UDT::setsockopt(usock, 0, UDT_SNDBUF, &snd_buf, sizeof(int));
    UDT::setsockopt(usock, 0, UDT_RCVBUF, &rcv_buf, sizeof(int));
    snd_buf = 64000;
    rcv_buf = 64000;
    UDT::setsockopt(usock, 0, UDP_SNDBUF, &snd_buf, sizeof(int));
    UDT::setsockopt(usock, 0, UDP_RCVBUF, &rcv_buf, sizeof(int));
    int fc = 64;
    UDT::setsockopt(usock, 0, UDT_FC, &fc, sizeof(int));
    bool reuse = true;
    bool rendezvous = isRendezvous;
    UDT::setsockopt(usock, 0, UDT_REUSEADDR, &reuse, sizeof(bool));
    UDT::setsockopt(usock, 0, UDT_RENDEZVOUS, &rendezvous, sizeof(bool));
    UDT::setsockopt(usock, 0, UDT_MSS, new int(9000), sizeof(int));
    UDT::setsockopt(usock, 0, UDT_SNDTIMEO, new int(3), sizeof(int));
    UDT::setsockopt(usock, 0, UDT_RCVTIMEO, new int(3), sizeof(int));
    
    if (UDT::ERROR == UDT::bind(usock, res->ai_addr, res->ai_addrlen))
    {
        cout << "bind: " << UDT::getlasterror().getErrorMessage() << endl;
        return -1;
    }
    
    freeaddrinfo(res);
    return 0;
}


int createUDTSocket(UDTSOCKET& usock, int port)
{
    addrinfo hints;
    addrinfo* res;
    
    memset(&hints, 0, sizeof(struct addrinfo));
    
    hints.ai_flags = AI_PASSIVE;
    hints.ai_family = g_IP_Version;
    hints.ai_socktype = g_Socket_Type;
    
    //string service("9000");
    char service[16];
    sprintf(service, "%d", port);
    Dlog("绑定本地port:%s\n", service);
    if (0 != getaddrinfo(NULL, service, &hints, &res)){
        cout << "------" << endl;
        cout << "illegal port number or port is busy.\n" << endl;
        return -1;
    }
    
    usock = UDT::socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    
    // since we will start a lot of connections, we set the buffer size to smaller value.
    // 第一个参数为要设置的UDTSocket
    // 第二个参数0是会被忽略的，没有实际意义
    // 第三个参数为要设置的参数，有以下几种选项、来自enum UDTOpt：
    //     UDT_MSS 最大传输单位
    //     UDT_SNDSYN 是否阻塞发送
    //     UDT_RCVSYN 是否阻塞接收
    //     UDT_CC 自定义拥塞控制算法
    //     UDT_FC 窗口大小
    //     UDT_SNDBUF 发送队列缓冲最大值
    //     UDT_RCVBUF UDT接收缓冲大小
    //     UDT_LINGER 关闭时等待数据发送完成
    //     UDP_SNDBUF UDP发送缓冲大小
    //     UDP_RCVBUF UDP接收缓冲大小
    //     UDT_RENDEZVOUS 会合连接模式
    //     UDT_SNDTIMEO send()超时
    //     UDT_RCVTIMEO recv()超时
    //     UDT_REUSEADDR 复用一个已存在的端口或者创建一个新的端口
    //     UDT_MAXBW 当前连接可以使用的最大带宽(bytes per second)
    // 第四个参数是参数值
    // 第五个参数为参数值长度，在底层也会被忽略，没有意义
    int snd_buf = 64000;
    int rcv_buf = 64000;
    UDT::setsockopt(usock, 0, UDT_SNDBUF, &snd_buf, sizeof(int));
    UDT::setsockopt(usock, 0, UDT_RCVBUF, &rcv_buf, sizeof(int));
    snd_buf = 64000;
    rcv_buf = 64000;
    UDT::setsockopt(usock, 0, UDP_SNDBUF, &snd_buf, sizeof(int));
    UDT::setsockopt(usock, 0, UDP_RCVBUF, &rcv_buf, sizeof(int));
    int fc = 64;
    UDT::setsockopt(usock, 0, UDT_FC, &fc, sizeof(int));
    bool reuse = true;
    bool rendezvous = false;
    UDT::setsockopt(usock, 0, UDT_REUSEADDR, &reuse, sizeof(bool));
    UDT::setsockopt(usock, 0, UDT_RENDEZVOUS, &rendezvous, sizeof(bool));
    UDT::setsockopt(usock, 0, UDT_MSS, new int(9000), sizeof(int));
    //UDT::setsockopt(usock, 0, UDT_MSS, new int(9000), sizeof(int));
    
    if (UDT::ERROR == UDT::bind(usock, res->ai_addr, res->ai_addrlen))
    {
        cout << "bind: " << UDT::getlasterror().getErrorMessage() << endl;
        return -1;
    }
    freeaddrinfo(res);
    return 0;
}

int connect(UDTSOCKET& usock, const char *host, int port)
{
    addrinfo hints, *peer;
    
    memset(&hints, 0, sizeof(struct addrinfo));
    
    /*  
    ai_flagsde值范围为0~7，取决于程序如何设置3个标志位，比如设置ai_flags为
    “AI_PASSIVE|AI_CANONNAME”，ai_flags值就为3。三个参数的含义分别为：
    (1)AI_PASSIVE当此标志置位时，表示调用者将在bind()函数调用中使用返回的地址结构。当此
        标志不置位时，表示将在connect()函数调用中使用。当节点名位NULL，且此标志置位，则
        返回的地址将是通配地址。如果节点名NULL，且此标志不置位，则返回的地址将是回环地址。
    (2)AI_CANNONAME当此标志置位时，在函数所返回的第一个addrinfo结构中的ai_cannoname
        成员中，应该包含一个以空字符结尾的字符串，字符串的内容是节点名的正规名。
    (3)AI_NUMERICHOST当此标志置位时，此标志表示调用中的节点名必须是一个数字地址字符串。
     */
    hints.ai_flags = AI_PASSIVE;
    /* 
    AF_UNIX（本机通信）
    AF_INET（TCP/IP – IPv4）
    AF_INET6（TCP/IP – IPv6）
     */
    hints.ai_family =  g_IP_Version;
    /*  
    SOCK_STREAM：        提供面向连接的稳定数据传输，即TCP协议。
    OOB：                在所有数据传送前必须使用connect()来建立连接状态。
    SOCK_DGRAM：         使用不连续不可靠的数据包连接。
    SOCK_SEQPACKET：     提供连续可靠的数据包连接。
    SOCK_RAW：           提供原始网络协议存取。
    SOCK_RDM：           提供可靠的数据包连接。
    SOCK_PACKET：        与网络驱动程序直接通信。
    注：此处的SOCK_STREAM并不是表示UDT将会使用TCP类型的Socket，在底层将会转化为UDT_STREAM
    并且在UDT中仅支持SOCK_STREAM和SOCK_DGRAM，分别对应UDT_STREAM和UDT_DGRAM
     */
    hints.ai_socktype = g_Socket_Type;
    
    char buffer[16];
    sprintf(buffer, "%d", port);
    Dlog(@"链接iPort = %d", port);
    if (0 != getaddrinfo(host, buffer, &hints, &peer)){
        cout << "incorrect server/peer address. "<< endl;
        return -1;
    }
    int i = UDT::connect(usock, peer->ai_addr, peer->ai_addrlen);
    if (UDT::ERROR == i) {
        cout << "connect error:" << UDT::getlasterror().getErrorMessage() << endl;
        return -1;
    }else{
        Dlog(@"connect success");
    }
    freeaddrinfo(peer);
    return 0;
}

string request2ConnectCamera_02(string sServerIp, int iPort, string sBuffer){
    NSLog(@"向服务器获取ip：iPort = %d, buffer ＝ %s", iPort, sBuffer.c_str());
    UDTSOCKET uSocke;
    if (createUDTSocket(uSocke, [g_sPort intValue]) < 0){
        cout << "CreateSocketError:" << UDT::getlasterror().getErrorMessage() << endl;
        UDT::close(uSocke);
        return "false";
    }
    if (connect(uSocke, sServerIp.c_str(), iPort) < 0){
        cout << "ConnectError:" << UDT::getlasterror().getErrorMessage() << endl;
        UDT::close(uSocke);
        return "false";
    }
    if (UDT::send(uSocke, sBuffer.c_str(), (int)strlen(sBuffer.c_str()), 0) < 0) {
        cout << "SendError:" << UDT::getlasterror().getErrorMessage() << endl;
        UDT::close(uSocke);
        return "false";
    }
    char msg[1000];
    memset(msg, 0x00, 1000);
    for (int i = 0; i < 5; i++) {
        if (UDT::ERROR == UDT::recv(uSocke, (char *)&msg, 500, 0)) {
            cout << "Receive Message Error:" << UDT::getlasterror().getErrorMessage() << endl;
            continue;
        }else{
            break;
        }
    }
    cout << "Receive Message:" << msg << endl;
    return string(msg);
}



/*****************************************************************************************

                                        对外接口

******************************************************************************************/
//告诉服务器开启摄像头
+ (NSDictionary *)tellServer2TurnOnCamera:(NSString *)sCameraId serverIp:(NSString *)sServerIp serverPort:(NSString *)sServerPort{
    Dlog(@"协议02，告诉服务器开启摄像头");
    if (sServerIp.length <= 0 || sServerPort.length <= 0 || sCameraId.length <= 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    const char *cIp         = [sServerIp cStringUsingEncoding:NSUTF8StringEncoding];
    string sIp              = string(cIp);
    int iPort               = [sServerPort intValue];
    NSString *sHead0        = FORMAT(@"02%@00%@|%@", [UIDevice new].identifierForVendor.UUIDString, [SNGlobalInfo instance].userInfo.sUserId, sCameraId);
    NSString *sBuffer       = [NSString stringWithFormat:@"000000%d%@", (int)sHead0.length, sHead0];
    const char *buf         = [sBuffer cStringUsingEncoding:NSUTF8StringEncoding];
    string s0               = string(buf);
    string s                = request2ConnectCamera_02(sIp, iPort, s0);
    if (s == "false") {
        [HDUtility say:@"网络出错，请稍后再试"];
        return nil;
    }
    NSString *strings       = [NSString stringWithCString:s.c_str() encoding:NSUTF8StringEncoding];
    NSArray *ar             = [strings componentsSeparatedByString:@"|"];
    if (ar.count < 2) {
        Dlog(@"服务器返回数据错误");
        return nil;
    }
    NSString *ss = ar[0];
    NSString *s1 = [ss substringFromIndex:ss.length - 1];
    NSMutableDictionary *mdc_result = [NSMutableDictionary new];
    [mdc_result setValue:s1 forKey:@"result"];
    [mdc_result setValue:ar[1] forKey:@"message"];
    if (ar.count >= 4) {
        [mdc_result setValue:ar[2] forKey:@"port"];
        [mdc_result setValue:ar[3] forKey:@"serial"];
    }
    return mdc_result;
}

//协议11，告诉服务器我的本地ip地址和端口，以获🉐摄像头的ip和端口
+ (NSDictionary *)tellServerMyLocalAddress:(NSDictionary *)dic serverIp:(NSString *)sServerIp{
    if (dic == nil || sServerIp.length <= 0){
        Dlog(@"参数传入错误");
        return nil;
    }
    Dlog(@"协议11，向服务端请求摄像头的打洞ip和端口");
    const char *cIp         = [sServerIp cStringUsingEncoding:NSUTF8StringEncoding];
    string sIp              = string(cIp);
    int iPort               = [dic[@"port"] intValue];
    NSString *sLocalIP      = [UDTUtility localWiFiIPAddress];
    if (sLocalIP.length <= 0) {
        sLocalIP = @"170.132.22.13";
    }
    Dlog(@"本地ip读取：%@", sLocalIP);
    NSString *sHead0        = FORMAT(@"11%@00%@0|%@|%@", [UIDevice new].identifierForVendor.UUIDString, dic[@"serial"], sLocalIP, burrow_port);
    NSString *sBuffer       = [NSString stringWithFormat:@"000000%d%@", (int)sHead0.length, sHead0];
    const char *buf         = [sBuffer cStringUsingEncoding:NSUTF8StringEncoding];
    string s0               = string(buf);
    string s                = request2ConnectCamera_02(sIp, iPort, s0);
    if (s == "false") {
        [HDUtility say:@"网络出错，请稍后再试"];
        return nil;
    }
    NSString *strings       = [NSString stringWithCString:s.c_str() encoding:NSUTF8StringEncoding];
    NSArray *ar             = [strings componentsSeparatedByString:@"|"];
    if (ar.count < 2) {
        Dlog(@"服务器返回数据错误");
        return nil;
    }
    NSString *ss = ar[0];
    NSString *s1 = [ss substringFromIndex:ss.length - 1];
    NSMutableDictionary *mdc_result = [NSMutableDictionary new];
    [mdc_result setValue:s1 forKey:@"result"];
    [mdc_result setValue:ar[1] forKey:@"message"];
    if (ar.count >= 6) {
        [mdc_result setValue:ar[2] forKey:@"cameraLocalIp"];
        [mdc_result setValue:ar[3] forKey:@"cameraLocalPort"];
        [mdc_result setValue:ar[4] forKey:@"cameraNatIP"];
        [mdc_result setValue:ar[5] forKey:@"cameraNatPort"];
    }
    return mdc_result;
}

//协议12，告诉服务器打洞步骤完成
+ (NSDictionary *)tellServerBurrowComplete:(NSDictionary *)dc isSuccess:(BOOL)isSuc{
    if (dc.count != 3) {
        Dlog(@"dc参数传入错误");
        return nil;
    }
    Dlog(@"isSuc = %d", (int)isSuc);
    NSString *sServerIp     = dc[@"serverIp"];
    NSString *sServerPort   = dc[@"serverPort"];
    NSString *sSerial       = dc[@"serial"];
    if (sServerIp.length <= 0 || sServerIp.length <= 0 || sSerial.length <= 0){
        Dlog(@"参数传入错误");
        return nil;
    }
    Dlog(@"协议12，告诉服务器打洞步骤完成");
    const char *cIp         = [sServerIp cStringUsingEncoding:NSUTF8StringEncoding];
    string sIp              = string(cIp);
    int iPort               = [sServerPort intValue];
    NSString *sHead0        = FORMAT(@"12%@00%@0|L2L|%d", [UIDevice new].identifierForVendor.UUIDString, sSerial, isSuc);
    NSString *sBuffer       = [NSString stringWithFormat:@"000000%d%@", (int)sHead0.length, sHead0];
    const char *buf         = [sBuffer cStringUsingEncoding:NSUTF8StringEncoding];
    string s0               = string(buf);
    string s                = request2ConnectCamera_02(sIp, iPort, s0);
    if (s == "false") {
        [HDUtility say:@"网络出错，请稍后再试"];
        return nil;
    }
    NSString *strings       = [NSString stringWithCString:s.c_str() encoding:NSUTF8StringEncoding];
    NSArray *ar             = [strings componentsSeparatedByString:@"|"];
    if (ar.count < 2) {
        Dlog(@"服务器返回数据错误");
        return nil;
    }
    NSString *ss = ar[0];
    NSString *s1 = [ss substringFromIndex:ss.length - 1];
    NSMutableDictionary *mdc_result = [NSMutableDictionary new];
    [mdc_result setValue:s1 forKey:@"result"];
    [mdc_result setValue:ar[1] forKey:@"message"];
    if (ar.count >= 3) {
        [mdc_result setValue:ar[2] forKey:@"step"];
    }
    return mdc_result;
}

//协议14，告诉服务器打洞成功
+ (NSDictionary *)tellServerBurrowSuccess:(NSDictionary *)dic_server parameter:(NSDictionary *)dic_p{
    Dlog(@"告诉服务器打洞成功");
    if (dic_server.count != 3 || !dic_server || !dic_p || dic_p.count != 2) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSString *sCameraIp     = dic_p[@"cameraIP"];
    NSString *sCameraPort   = dic_p[@"cameraPort"];
    NSString *sSerial       = dic_server[@"serial"];
    int iServerPort         = [dic_server[@"serverPort"] intValue];
    const char *cIp         = [dic_server[@"serverIp"] cStringUsingEncoding:NSUTF8StringEncoding];
    string sIp              = string(cIp);
    NSString *sHead0        = FORMAT(@"14%@00%@0|%@|%@|3", [HDUtility uuid], sSerial, sCameraIp, sCameraPort);
    NSString *sBuffer       = [NSString stringWithFormat:@"000000%d%@", (int)sHead0.length, sHead0];
    const char *buf         = [sBuffer cStringUsingEncoding:NSUTF8StringEncoding];
    string s0               = string(buf);
    string s                = request2ConnectCamera_02(sIp, iServerPort, s0);
    if (s == "false") {
        [HDUtility say:@"网络出错，请稍后再试"];
        return nil;
    }
    NSString *strings       = [NSString stringWithCString:s.c_str() encoding:NSUTF8StringEncoding];
    NSArray *ar             = [strings componentsSeparatedByString:@"|"];
    if (ar.count < 2) {
        Dlog(@"服务器返回数据错误");
        return nil;
    }
    NSString *ss = ar[0];
    NSString *s1 = [ss substringFromIndex:ss.length - 1];
    NSMutableDictionary *mdc_result = [NSMutableDictionary new];
    [mdc_result setValue:s1 forKey:@"result"];
    [mdc_result setValue:ar[1] forKey:@"message"];
    if (ar.count >= 3) {
        [mdc_result setValue:ar[2] forKey:@"rtsp"];
    }
    return mdc_result;
}

//协议04，告诉服务器开启摄像头声波
+ (NSArray *)tellService2TurnOnCameraSoundListening:(NSString *)sCameraId{
    SNServerInfo *sInfo     = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
    const char *cIp         = [sInfo.sUdtIp cStringUsingEncoding:NSUTF8StringEncoding];
    string sIp              = string(cIp);
    int iPort               = [sInfo.sUdtPort intValue];
    NSString *sHead0        = FORMAT(@"04%@00%@|%@", [UIDevice new].identifierForVendor.UUIDString, [SNGlobalInfo instance].userInfo.sUserId, (sCameraId == nil? @"" : sCameraId));
    NSString *sBuffer       = [NSString stringWithFormat:@"000000%d%@", (int)sHead0.length, sHead0];
    const char *buf         = [sBuffer cStringUsingEncoding:NSUTF8StringEncoding];
    string s0               = string(buf);
    string s                = request2ConnectCamera_02(sIp, iPort, s0);
    if (s == "false") {
        [HDUtility say:@"网络出错，请稍后再试"];
        return nil;
    }
    NSString *strings       = [NSString stringWithCString:s.c_str() encoding:NSUTF8StringEncoding];
    NSArray *ar = [strings componentsSeparatedByString:@"|"];
    if (ar.count < 2) {
        Dlog(@"服务器返回数据错误");
        return nil;
    }
    NSString *ss = ar[0];
    NSString *s1 = [ss substringFromIndex:ss.length - 1];
    NSArray *ar_result = [[NSArray alloc] initWithObjects:s1, ar[1], nil];
    return ar_result;
}

//打洞－内网
string burrowLocal(NSString *sBurrowIp, int iPort){
    NSLog(@"开始打洞");
    Dlog(@"burrow:ip = %@, iPort = %d", sBurrowIp, iPort);
    UDTSOCKET burrowSocke;
    if (createUDTSocketWithModel(burrowSocke, [burrow_port intValue], true) < 0){
        cout << "CreateSocketError:" << UDT::getlasterror().getErrorMessage() <<endl;
        UDT::close(burrowSocke);
        Dlog(@"链接失败");
        return "false";
    }
    NSLog(@"iPort = %d", iPort);
    if (connect(burrowSocke, [sBurrowIp cStringUsingEncoding:NSUTF8StringEncoding], iPort) < 0){
        cout << "ConnectError:" << UDT::getlasterror().getErrorMessage() <<endl;
        UDT::close(burrowSocke);
        Dlog(@"链接失败");
        return "false";
    }else{
        Dlog(@"连接成功");
        return "suc";
    }
    return "suc";
}


@end




