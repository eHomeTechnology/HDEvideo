//
//  SNGuideViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-25.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNGuideViewCtr.h"
#import "SNRegisterViewCtr.h"
#import "SNLoginViewCtr.h"
#import "SNGuideRegisterViewCtr.h"
#import "SNLoginViewCtr.h"

@interface SNGuideViewCtr (){

    IBOutlet UIView *v_sub;
    
}

@end

@implementation SNGuideViewCtr


- (void)viewDidLoad
{
    [super viewDidLoad];
    v_sub.frame = CGRectMake(35, 100, CGRectGetWidth(v_sub.frame), CGRectGetHeight(v_sub.frame));
    [self.view addSubview:v_sub];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)doRegister:(id)sender{
    SNGuideRegisterViewCtr *ctr = [[SNGuideRegisterViewCtr alloc] init];
    ctr.view.frame = CGRectMake(320, 70, 0, CGRectGetHeight(ctr.view.frame));
    [self.view addSubview:ctr.view];
    [self addChildViewController:ctr];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        v_sub.frame = CGRectMake(-320, CGRectGetMinY(v_sub.frame), 0, CGRectGetHeight(v_sub.frame));
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            ctr.view.frame = CGRectMake(35, 70, 250, CGRectGetHeight(ctr.view.frame));
        }];
    }];
}

- (IBAction)doChangeUser:(id)sender{
    for (UIView *v in kWindow.subviews) {
        [v removeFromSuperview];
    }
    [kWindow setRootViewController:[SNLoginViewCtr new]];
    Dlog(@"1111111");
}

- (IBAction)doCancel:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_GUIDE_VIEW object:nil];
}


@end
