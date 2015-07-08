//
//  SNPhotoSeeVideo.m
//  SNVideo
//
//  Created by Thinking on 14-9-15.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "SNPhotoSeeVideo.h"
#import "PlayViedo.h"
#import "UIImageExtensions.h"
#import "SNRequestImag.h"
#import "SNSegmentedControl.h"
#import "SNSeeBackVideoViewCtr.h"
#import "SNSeeEventVideoViewCtr.h"

@interface SNPhotoSeeVideo ()
{
    
    IBOutlet UIView         *v_content;
    IBOutlet UIScrollView   *scr_bg;
    SNSeeVideoType          videoType;
    
    SNCameraInfo            *device_Info;

    
}
@end

@implementation SNPhotoSeeVideo

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDeviceInfo:(SNCameraInfo *)dInfo
{
    if (self == [super init]) {
        device_Info = dInfo;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"监视回放";
    
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
    
    [scr_bg setContentSize:CGSizeMake(scr_bg.frame.size.width, 568 - 64 - 50)];
    
    SNSegmentedControl *segmentedCtr = [[SNSegmentedControl alloc] initWithFrame:CGRectMake(50, 10, 220, 33)
                                                                           items:[NSArray arrayWithObjects:@"事件", @"录制", nil]
                                                                   selectedColor:[UIColor  colorWithRed:23/255.0 green:129/255.0 blue:135/255.0 alpha:1]
                                                                     normalColor:[UIColor colorWithRed:36/255.0 green:46/255.0 blue:60/255.0 alpha:1]
                                                                     borderColor:[UIColor whiteColor]
                                                               selectedTextColor:[UIColor whiteColor]
                                                                 normalTextColor:[UIColor grayColor]];
    segmentedCtr.selectedSegmentIndex = 0;
    [segmentedCtr addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedCtr];
    videoType = seeVideo_event;
    
    SNSeeEventVideoViewCtr *eventCtr = [[SNSeeEventVideoViewCtr alloc] initWithDeviceInfo:device_Info];
    [self addChildViewController:eventCtr];
    [v_content addSubview:eventCtr.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
  //  http://dev.umeng.com/social/ios/sdk-download
   // [NSThread detachNewThreadSelector:@selector(doLoadImage) toTarget:self withObject:nil];
    
}
/*
- (void)doLoadImage{
    for (int i = 0; i < mar_imv.count; i++) {
        UIImageView *imv = [mar_imv objectAtIndex:i];
        NSString *url = [self getImageURL:i];
        [SNRequestImag requestImageWithURL:url imageView:imv acquiesceImg:[UIImage imageNamed:@"screenshot.jpg"]];
    }

}*/

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
            videoType = seeVideo_event;
            for (UIView *view in v_content.subviews) {
                [view removeFromSuperview];
            }
            SNSeeEventVideoViewCtr *eventCtr = [[SNSeeEventVideoViewCtr alloc] initWithDeviceInfo:device_Info];
            [self addChildViewController:eventCtr];
            [v_content addSubview:eventCtr.view];
        }
            break;
        case 1:
        {
            Dlog(@"==UISegmentedControl====1111=====");
            transition.subtype = kCATransitionFromLeft;
            videoType = seeVideo_back;
            for (UIView *view in v_content.subviews) {
                [view removeFromSuperview];
            }
            SNSeeBackVideoViewCtr *eventCtr = [[SNSeeBackVideoViewCtr alloc] initWithDeviceInfo:device_Info];
            [self addChildViewController:eventCtr];
            [v_content addSubview:eventCtr.view];
        }
            break;
        default:
            break;
    }
    
    [v_content.layer addAnimation:transition forKey:nil];
}

#pragma mark - button Action
-(void)doBack:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
