//
//  SNRequestImag.h
//  SNVideo
//
//  Created by Thinking on 14-10-10.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRequestImag : NSObject

+ (void)requestImageWithURL:(NSString *)url imageView:(UIImageView *)imv acquiesceImg:(UIImage *)img_t;

@end
