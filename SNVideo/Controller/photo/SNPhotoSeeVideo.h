//
//  SNPhotoSeeVideo.h
//  SNVideo
//
//  Created by Thinking on 14-9-15.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, SNSeeVideoType) {
    seeVideo_event = 0,         //事件
    seeVideo_back,                //录制回放
    
};

@interface SNPhotoSeeVideo : UIViewController


- (id)initWithDeviceInfo:(SNCameraInfo *)dInfo;

@end
