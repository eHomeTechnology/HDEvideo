//
//  NSObject_Instance.h
//  FEPosUniversal
//
//  Created by DennisHu on 12-8-6.
//  Copyright (c) 2012年 __iDennisHu__. All rights reserved.
//

#define LOGIN_USER      "loginUser"
#define USER_PHOTO      "userPhoto"
#define SEVER_INFO      "severInfo"
#define HTTP_URL        "http://121.40.133.242:8080/ESeeServer/ESeeServlet"
#define HTTP_TEST       "http://192.168.73.249:8080/ESeeServer/ESeeServlet"
#define UmengAppkey     "5211818556240bc9ee01db2f"

#define URL_VIDEO_RTSP  "rtsp://121.40.95.209:554/littleApple.mp4"
#define KEY_WIFI        FORMAT(@"%@_%@", @"KEY_WIFI", [SNGlobalInfo instance].userInfo.sPhone)

#define KEYBOARD_HEIGHT         216.0   //键盘高度
#define ANIMATION_DURATION      0.2     //动画时间
#define MIN_LENTH_NAME          2       //名字的最小长度
#define MAX_LENTH_NAME          8       //名字的最大长度
#define MAX_LENTH_WIFI          20      //wifi名称最大长度
#define MAX_LENTH_PASSWORD      12      //密码最大长度
#define MIN_LENTH_PASSWORD      6       //密码最小长度
#define MAX_LENTH_EMAIL         30      //邮箱最大长度
#define MAX_LENTH_DEVICENAME    5       //摄像头名称最大长度

#define COLOR_BACKGLOUND    [UIColor colorWithRed:36/255.   green:46/255.   blue:60/255.    alpha:1.0f]
#define COLOR_CELL          [UIColor colorWithRed:39/255.   green:49/255.   blue:64/255.    alpha:1.0f]
#define COLOR_SUB_BG        [UIColor colorWithRed:39/255.   green:49/255.   blue:64/255.    alpha:1.0f]
#define COLOR_ORANGE        [UIColor colorWithRed:246/255.  green:131/255.  blue:73/255.    alpha:1.0f]
#define COLOR_HILIGHT       [UIColor colorWithRed:22/255.   green:129/255.  blue:135/255.   alpha:1.0f]

#define KEY_NOTI_ADD_DEVICE_CANCEL      "ADD_DEVICE"                //退出添加设备界面
#define KEY_NOTI_DELETE_DEVICE_CANCEL   "DELETE_DEVICE_CANCEL"      //退出删除设备界面
#define KEY_NOTI_FORGET_PWD             "FORGET_PASSWORD"           //退出忘记密码界面
#define KEY_NOTI_WIFI_ADD               "WIFI_ADD"                  //退出添加wifi界面
#define KEY_NOTI_WIFI_SHARE             "WIFI_SHARE"                //退出wifi分享界面
#define KEY_NOTI_WIFI_RESET             "WIFI_RESET"                //退出wifi重置界面
#define KEY_NOTI_FRIEND_ADD             "FRIEND_ADD"                //退出添加好友界面
#define KEY_NOTI_FRIEND_DETAIL          "FRIEND_DETAIL"             //退出好友详情页面
#define KEY_NOTI_MODIFY_PWD             "MODIFY_PASSWORD"           //退出修改密码界面
#define KEY_NOTI_GUIDE_VIEW             "GUIDE_VIEW"                //退出引导注册界面
#define KEY_NOTI_MAIN_PLAY              "MAIN_PLAY"                 //主界面播放通知
#define KEY_NOTI_MAIN_HEART_REFRESH     "MAIN_REFRESH_HEART"        //心跳包通知刷新主界面
#define KEY_NOTI_MAIN_VIEW_REFRESH      "MAIN_REFRESH"              //主页面摄像头controller刷新
#define KEY_NOTI_MAIN_HEART             "HEART"                     //通知触发心跳包
#define KEY_NOTI_EXIT_FULL_SCREEN       "EXIT_FUUL_SCREEN"          //退出全屏通知

#define FOLDER_USER         "user"          //用户相关图片保存的文件夹名称，如用户头像等
#define FOLDER_FRIEND       "friend"        //好友相关图片保存的文件夹名称，如好友头像等
#define FOLDER_DEVICE       "device"        //设备相关图片保存的文件夹名称，如设备截图等
#define FOLDER_EVENT        "event"         //事件相关图片保存的文件夹名称，如事件截图等



