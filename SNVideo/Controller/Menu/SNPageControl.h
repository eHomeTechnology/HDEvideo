//
//  SNPageControl.h
//  SNVideo
//
//  Created by Hu Dennis on 14-10-17.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNPageControl : UIPageControl{

}

@property (nonatomic, strong)UIImage *img_inactive;
@property (nonatomic, strong)UIImage *img_active;
@property (nonatomic, assign)CGRect  imageRect;

@end
