//
//  SNButtonItem.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-24.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNButtonItem.h"
@implementation SNButtonItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor    = [UIColor clearColor];
        _mar_buttons            = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
            [btn setTitle:@[@"扫码", @"二维码", @"账号", @""][i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            if (i < 3) {
                [HDUtility circleTheView:btn];
                [btn setBackgroundColor:COLOR_SUB_BG];
            }else{
                [HDUtility circleWithNoBorder:btn];
                [btn setImage:[UIImage imageNamed:@"icon_添加.png"] forState:UIControlStateNormal];
                [HDUtility rotateView:btn angle:M_PI_4];
                [btn setBackgroundColor:COLOR_ORANGE];
            }
            [_mar_buttons addObject:btn];
            [self addSubview:btn];
        }
    }
    return self;
}

- (void)layoutSubviews{
    
}

- (void)drawRect:(CGRect)rect
{

}

- (void)show{
    self.hidden         = NO;
    CGFloat pY          = 35;
    CGPoint pScan       = CGPointMake(43,   pY);
    CGPoint pBarcode    = CGPointMake(121,  pY);
    CGPoint pAccount    = CGPointMake(199,  pY);
    CGPoint pAdd        = CGPointMake(275,  pY);
    [HDUtility view:_mar_buttons[0] appearAt:pScan    withDalay:0.2 duration:0.5];
    [HDUtility view:_mar_buttons[1] appearAt:pBarcode withDalay:0.2 duration:0.5];
    [HDUtility view:_mar_buttons[2] appearAt:pAccount withDalay:0.2 duration:0.5];
    [_mar_buttons[3] setCenter:pAdd];
}

- (void)hide{
    self.hidden = YES;
}

#pragma mark - SEL
- (void)buttonAction:(UIButton *)sender{
    for (int i = 0; i < _mar_buttons.count-1; i++) {
        UIButton *btn = _mar_buttons[i];
        [btn setBackgroundColor:COLOR_SUB_BG];
    }
    switch (sender.tag) {
        case 0:{
            if (self.delegate) {
                [_mar_buttons[0] setBackgroundColor:COLOR_HILIGHT];
                [self.delegate SNDelegateTouchWithItem:SNButtonItemTypeScan];
            }
            break;
        }
        case 1:{
            if (self.delegate) {
                [_mar_buttons[1] setBackgroundColor:COLOR_HILIGHT];
                [self.delegate SNDelegateTouchWithItem:SNButtonItemTypeBarcode];
            }
            break;
        }
        case 2:{
            if (self.delegate) {
                [_mar_buttons[2] setBackgroundColor:COLOR_HILIGHT];
                [self.delegate SNDelegateTouchWithItem:SNButtonItemTypeAccount];
            }
            break;
        }
        case 3:{
            if (self.delegate) {
                [UIView animateWithDuration:ANIMATION_DURATION/5 animations:^{
                    for (int i = 0; i < _mar_buttons.count-1; i++) {
                        UIButton *btn = _mar_buttons[i];
                        btn.frame = ((UIButton *)_mar_buttons[3]).frame;
                    }
                } completion:^(BOOL finished) {
                    [self.delegate SNDelegateTouchWithItem:SNButtonItemTypeAdd];
                }];
            }
            break;
        }
        default:
            break;
    }
}

@end
