//
//  SNPageControl.m
//  SNVideo
//
//  Created by Hu Dennis on 14-10-17.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNPageControl.h"

@implementation SNPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateDots
{
    if (_img_active == nil) {
         _img_active = [UIImage imageNamed:@"page_high.png"];
    }
    if (_img_inactive == nil) {
        _img_inactive = [UIImage imageNamed:@"page_nor.png"];
    }
    
    int iCount      =  (int)[self.subviews count];
    for (int i = 0; i < iCount; i++) {
        UIView *v_dot       = [self.subviews objectAtIndex:i];
        [v_dot setBackgroundColor:[UIColor clearColor]];
        if (IOS_VERSION < 7.0) {
            [(UIImageView *)v_dot setImage:nil];
        }
        CGRect rect         = _imageRect;
        UIImageView *imv    = [[UIImageView alloc] initWithFrame:rect];
        for (UIView *v in v_dot.subviews) {
            [v removeFromSuperview];
        }
        [v_dot addSubview:imv];
        if (i == self.currentPage){
            imv.image = _img_active;
            Dlog(@"a");
        }else{
            Dlog(@"ina");
            imv.image = _img_inactive;
        }
    }
}
- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateDots];
}
@end
