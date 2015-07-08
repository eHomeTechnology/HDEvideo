//
//  SNEventSetViewCtr.h
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNEventInfo.h"

@interface SNEventSetViewCtr : UIViewController

@end


@interface SNEventButton : UIButton

@property (strong) SNEventInfo *eventInfo;

@end
