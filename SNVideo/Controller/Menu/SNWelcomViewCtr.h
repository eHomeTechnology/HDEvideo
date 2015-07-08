//
//  SNWelcomViewCtr.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-18.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNMenuViewCtr.h"
#import "SNHttpUtility.h"

@interface SNWelcomViewCtr : UIViewController<UIGestureRecognizerDelegate, RESideMenuDelegate>{


}

+ (RESideMenu *)newMenuController;
@end
