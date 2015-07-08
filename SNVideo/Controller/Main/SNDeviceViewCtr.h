//
//  SNDeviceViewCtr.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-26.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCameraInfo.h"

#define COLOR_MENU_DARK     [UIColor colorWithRed:34/255.0f green:63/255.0f blue:73/255.0f alpha:1.0f]
#define COLOR_MENU_LIGHT    [UIColor colorWithRed:25/255.0f green:193/255.0f blue:193/255.0f alpha:1.0f]

@interface SNDeviceViewCtr : UIViewController{


}

@property (strong) IBOutlet UILabel         *lb_name;
@property (strong) IBOutlet UILabel         *lb_noCamera;
@property (strong) IBOutlet UIImageView     *imv_noCamera;
@property (strong) IBOutlet UIImageView     *imv_screen;
@property (strong) IBOutlet UIButton        *btn_replay;
@property (strong) IBOutlet UIButton        *btn_setting;
@property (strong) IBOutlet UIView          *v_back;
@property (strong) IBOutlet UIView          *v_settingMenuBack;
@property (strong) IBOutlet UIView          *v_replayMenuBack;
@property (strong) IBOutlet UIView          *v_statusBack;
@property (strong) IBOutlet UIImageView     *imv_isBelongOther;
@property (strong) SNCameraInfo             *cameraInfo;
@property (strong) NSString                 *sPlayURL;

- (SNDeviceViewCtr *)initWithCamera:(SNCameraInfo *)info;
- (void)refreshView;
@end
