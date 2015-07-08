//
//  SNEventCenter.m
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNEventCenterViewCtr.h"
#import "SNSegmentedControl.h"
#import "SNEventReportViewCtr.h"
#import "SNEventSetViewCtr.h"

@interface SNEventCenterViewCtr ()
{
    IBOutlet UIView         *v_top;
    IBOutlet UIView         *v_content;
}
@end

@implementation SNEventCenterViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"事件中心";
    
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
        
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
    
    SNSegmentedControl *segmentedCtr = [[SNSegmentedControl alloc] initWithFrame:CGRectMake(50, 10, 220, 33)
                                                                           items:[NSArray arrayWithObjects:@"报表", @"配置", nil]
                                                                   selectedColor:[UIColor  colorWithRed:23/255.0 green:129/255.0 blue:135/255.0 alpha:1]
                                                                     normalColor:[UIColor colorWithRed:36/255.0 green:46/255.0 blue:60/255.0 alpha:1]
                                                                     borderColor:[UIColor whiteColor]
                                                               selectedTextColor:[UIColor whiteColor]
                                                                 normalTextColor:[UIColor grayColor]];
    segmentedCtr.selectedSegmentIndex = 0;
    [segmentedCtr addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
    [v_top addSubview:segmentedCtr];
 
    SNEventReportViewCtr *reportViewCtr = [[SNEventReportViewCtr alloc] init];
    [self addChildViewController:reportViewCtr];
    [v_content addSubview:reportViewCtr.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button Action
-(void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - uisegmentedControl action
- (void)segmentedAction:(UISegmentedControl *)segCtr
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.type = @"oglFlip";
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    int segIndex = (int)segCtr.selectedSegmentIndex;
    switch (segIndex) {
        case 0:
        {
            Dlog(@"==UISegmentedControl====0000=====");
            transition.subtype = kCATransitionFromRight;
            for (UIView *view in v_content.subviews) {
                [view removeFromSuperview];
            }
            SNEventReportViewCtr *reportViewCtr = [[SNEventReportViewCtr alloc] init];
            [self addChildViewController:reportViewCtr];
            [v_content addSubview:reportViewCtr.view];
        }
            break;
        case 1:
        {
            Dlog(@"==UISegmentedControl====1111=====");
            transition.subtype = kCATransitionFromLeft;
            for (UIView *view in v_content.subviews) {
                [view removeFromSuperview];
            }
            SNEventSetViewCtr *setViewCtr = [[SNEventSetViewCtr alloc] init];
            [self addChildViewController:setViewCtr];
            [v_content addSubview:setViewCtr.view];
        }
            break;
        default:
            break;
    }
    
    [v_content.layer addAnimation:transition forKey:nil];
}

@end
