//
//  SNRequestImag.m
//  SNVideo
//
//  Created by Thinking on 14-10-10.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNRequestImag.h"
#import "SNHttpUtility.h"

@implementation SNRequestImag

+ (void)requestImageWithURL:(NSString *)url imageView:(UIImageView *)imv acquiesceImg:(UIImage *)img_t
{
    if(url == nil){
        Dlog(@"====url===error=");
        return;
    }
    
    UIActivityIndicatorView *activity;
    [imv addSubview:activity = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
    activity.center = CGPointMake(imv.frame.size.width / 2, imv.frame.size.height / 2);
    [imv addSubview:activity];
    [activity startAnimating];
    
    [[SNHttpUtility requestImageWithURL:url] requestStart_1WithCompletionBlock:^(BOOL isSuccess, UIImage *img, NSString *sMessage) {
        
        [activity stopAnimating];
        
        if (isSuccess) {
            [imv setImage:img];
        }else{
            [imv setImage:img_t];
        }
    }];
    
}

@end
