//
//  UIImageExtensions.h
//  THTest
//
//  Created by Thinking on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface UIImage (CS_Extensions)
@interface UIImageExtension : NSObject

- (id)initWihtImge:(UIImage *)img;

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageRotatedByFiyDegrees:(CGFloat)degrees;

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

@end
