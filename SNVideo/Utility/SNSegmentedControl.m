//
//  SNSegmentedControl.m
//  THTest
//
//  Created by Thinking on 14-10-29.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNSegmentedControl.h"

@implementation SNSegmentedControl

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

- (id)initWithFrame:(CGRect)frame
              items:(NSArray *)items
      selectedColor:(UIColor *)selectedColor
        normalColor:(UIColor *)normalColor
        borderColor:(UIColor *)borderColor
  selectedTextColor:(UIColor *)selectTextColor
    normalTextColor:(UIColor *)normalTextCorlor
{
    if (self = [super initWithItems:items]) {
        
        self.frame = frame;
        
        [[UISegmentedControl appearance] setBackgroundImage:[self imageWithColor:selectedColor size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateSelected
                                                 barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setBackgroundImage:[self imageWithColor:normalColor size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateNormal
                                                 barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setDividerImage:[self imageWithColor:borderColor size:CGSizeMake(1, 29)]
                                     forLeftSegmentState:UIControlStateNormal
                                       rightSegmentState:UIControlStateSelected
                                              barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor: normalTextCorlor,
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] }
                                                                                forState:UIControlStateNormal];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor: selectTextColor,
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]}
                                                                                forState:UIControlStateSelected];
        
        self.layer.borderColor      = borderColor.CGColor;
        self.layer.borderWidth      = 1.0f;
        self.layer.cornerRadius     = 4.0f;
        self.layer.masksToBounds    = YES;
    }
    
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
