//
//  SNSoundViewCtr.h
//  SNVideo
//
//  Created by Hu Dennis on 14-9-19.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_NOTIFICATION_ADD_DEVICE_BACK "addDeviceGoBack"

@interface SNSoundViewCtr : UIViewController{

}

- (id)initWithWifiInfo:(SNWIFIInfo *)info;          //主界面添加设备的时候调用
- (id)initWithSharedWifiInfo:(SNWIFIInfo *)info camera:(SNCameraInfo *)cInfo;    //wifi管理调用
@end
