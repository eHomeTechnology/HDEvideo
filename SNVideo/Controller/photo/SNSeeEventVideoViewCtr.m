//
//  SNSeeEventVideoViewCtr.m
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "SNSeeEventVideoViewCtr.h"
#import "PlayViedo.h"
#import "UIImageExtensions.h"
#import "SNRequestImag.h"
#import "SNHttpUtility.h"
#import "SNUserInfo.h"
#import "SNEventInfo.h"

@interface SNSeeEventVideoViewCtr ()
{
    IBOutlet UIView         *v_top;
    IBOutlet UIScrollView   *scr_time;
    
    IBOutlet UIView         *v_content;
    
    IBOutlet UIView         *v_bg_video;
    IBOutlet UIView         *v_bg_label;
    IBOutlet UIImageView    *imv_selectType;
    IBOutlet UILabel        *lb_selectTime;
    IBOutlet UILabel        *lb_video_name;
    IBOutlet UIView         *v_video_play;
    IBOutlet UIView         *v_play_time;
    IBOutlet UISlider       *slider_time;
    IBOutlet UILabel        *lb_minTime;
    IBOutlet UILabel        *lb_maxTime;
    
    IBOutlet UIView         *v_playBtn;
    IBOutlet UIImageView    *imv_playBtn;
    
    IBOutlet UIPageControl  *pgc_time;
    
    IBOutlet UIView         *v_pic;
    IBOutlet UIScrollView   *scrV_pic;
    
    IBOutlet UIView         *v_eventType;
    IBOutlet UILabel        *lb_eventLine;
    
    IBOutlet UIView         *v_eventTime;
    
    NSMutableArray          *mar_imv;
    NSMutableArray          *mar_coverView;
    NSMutableArray          *mar_borderImv;
    NSMutableArray          *mar_timeEvent;
    NSMutableArray          *mar_picEvent;
    
    PlayViedo               *videoCtr;
    BOOL                    playFig;
    NSTimer                 *timer_play;
    SNCameraInfo            *device_Info;
    float                   time_Select;
    int                     index_nowEvent;
    CGPoint                 point_begin;
    NSString                *sSelectDate;
    
    MBProgressHUD           *HUD;
}
@end

@implementation SNSeeEventVideoViewCtr

- (id)initWithDeviceInfo:(SNCameraInfo *)dInfo
{
    if (self == [super init]) {
        device_Info = dInfo;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mar_imv         = [[NSMutableArray alloc] init];
    mar_coverView   = [[NSMutableArray alloc] init];
    mar_borderImv   = [[NSMutableArray alloc] init];
    mar_timeEvent   = [[NSMutableArray alloc] init];
    mar_picEvent    = [[NSMutableArray alloc] init];
    playFig         = NO;
    index_nowEvent  = -1;
    
    v_bg_video.layer.shadowColor        = [[UIColor blackColor] CGColor];//阴影的颜色
    v_bg_video.layer.shadowOffset       = CGSizeMake(0, 0);
    v_bg_video.layer.shadowOpacity      = 0.5;//阴影透明度
    v_bg_video.layer.shadowRadius       = 1.0;//阴影圆角度数
    v_bg_label.layer.shadowColor        = [[UIColor blackColor] CGColor];//阴影的颜色
    v_bg_label.layer.shadowOffset       = CGSizeMake(0, 0);
    v_bg_label.layer.shadowOpacity      = 0.5;//阴影透明度
    v_bg_label.layer.shadowRadius       = 2.0;//阴影圆角度数
    
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"photo_slider_01.png"];
    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
    [slider_time setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [slider_time setThumbImage:thumbImage forState:UIControlStateNormal];
    slider_time.maximumValue    = 60 * 60;
    slider_time.minimumValue    = 0;
    lb_minTime.text             = @"00:00:00";
    lb_maxTime.text             = @"01:00:00";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    for (int i = 14; i >= 0; i--) {
        NSString *sDate_t = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * i]];
        [mar_timeEvent addObject:sDate_t];
    }
    
    lb_selectTime.text = @"";
    
    [self refreshTimeScrollView:mar_timeEvent];
    
    if (device_Info) {
        lb_video_name.text      = device_Info.sDeviceName;
    }
    
    for (int i = 0; i < 10; i++) {
        SNEventInfo *eInfo = [[SNEventInfo alloc] init];
        eInfo.sDeviceID = device_Info.sDeviceId;
        eInfo.sEventID = @"EP01";
        eInfo.sEventName = @"沉迷报警";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        eInfo.eventTime = [formatter dateFromString:@"20141031120000"];
        [mar_picEvent addObject:eInfo];
    }
    
    [self refreshPicSrollView:mar_picEvent];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"数据请求中...";
    HUD.dimBackground = YES;
    HUD.center = self.view.center;
    [self.view addSubview:HUD];
    
    timer_play = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self selector:@selector(updateVideoPlaybackTime:) userInfo:nil repeats:YES];
    
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] getEvents:user deviceID:device_Info.sDeviceId eventTypeID:nil start:0 limit:0 startTime:[NSDate date] endTime:[NSDate date] CompletionBlock:^(BOOL isSuccess, NSArray *arrayEvents, NSString *sMessage) {
        if (isSuccess) {
            NSArray *ar_t = [[arrayEvents objectAtIndex:0] valueForKey:device_Info.sDeviceId];
            [mar_picEvent removeAllObjects];
            [mar_picEvent addObjectsFromArray:ar_t];
            [self refreshPicSrollView:mar_picEvent];
        }else{
            [mar_picEvent removeAllObjects];
            index_nowEvent = -1;
        }
    }];
    
    //打开设备产生朝向通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //注册设备朝向通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


#pragma mark - down Image
- (void)doLoadImage{
    for (int i = 0; i < mar_imv.count; i++) {
        UIImageView *imv = [mar_imv objectAtIndex:i];
        SNEventInfo *eInfo = [mar_picEvent objectAtIndex:i];
        NSString *url = eInfo.sImageUrl;
        [SNRequestImag requestImageWithURL:url imageView:imv acquiesceImg:[UIImage imageNamed:@"screenshot.jpg"]];
    }
    
}

#pragma mark - refresh view
- (void)refreshTimeScrollView:(NSArray *)times
{
    for (UIView *v_t in scr_time.subviews) {
        [v_t removeFromSuperview];
    }
    
    pgc_time.numberOfPages = times.count;
    pgc_time.currentPage   = times.count - 1;
    
    float width = scr_time.frame.size.width;
    for (int i = 0; i < times.count; i++) {
        UILabel *lb_time_t = [[UILabel alloc] initWithFrame:CGRectMake(width * i, 0, width, 15)];
        [lb_time_t setBackgroundColor:[UIColor clearColor]];
        [lb_time_t setTextAlignment:NSTextAlignmentCenter];
        [lb_time_t setTextColor:[UIColor colorWithRed:23/255.0 green:178/255.0 blue:178/255.0 alpha:1]];
        [lb_time_t setFont:[UIFont systemFontOfSize:15]];
        lb_time_t.text = [times objectAtIndex:i];
        [scr_time addSubview:lb_time_t];
    }
    
    [scr_time setContentSize:CGSizeMake(width * times.count, scr_time.frame.size.height)];
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:NO];
    
}

- (void)refreshPicSrollView:(NSArray *)pics
{
    for (UIView *v_t in scrV_pic.subviews) {
        [v_t removeFromSuperview];
    }
    
    [mar_imv removeAllObjects];
    [mar_coverView removeAllObjects];
    [mar_borderImv removeAllObjects];
    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_play.png"]];
    lb_selectTime.text = @"";
    
    for (int i = 0; i < pics.count; i++) {
        SNEventInfo *eInfo = [pics objectAtIndex:i];
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(73 * i, 0, 71, 43)];
        [SNRequestImag requestImageWithURL:eInfo.sImageUrl imageView:imv acquiesceImg:[UIImage imageNamed:@"screenshot.jpg"]];
        [scrV_pic addSubview:imv];
        [mar_imv addObject:imv];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *time = [formatter stringFromDate:eInfo.eventTime];
        
        NSString *imgName = nil;
        if ([eInfo.sEventID isEqualToString:@"ES01"]) {
            imgName = @"photo_video_event_02.png";
        }else if ([eInfo.sEventID isEqualToString:@"ES02"]){
            imgName = @"photo_video_event_03.png";
        }else{
            imgName = @"photo_video_event_04.png";
        }
        
        UIImageView *imv_border = [[UIImageView alloc] initWithFrame:imv.frame];
        [imv_border setImage:[UIImage imageNamed:@"photo_video_border.png"]];
        imv_border.hidden = YES;
        if (index_nowEvent == i) {
            imv_border.hidden = NO;
            lb_selectTime.text = [NSString stringWithFormat:@"%@:%@", [time substringWithRange:NSMakeRange(8, 2)], [time substringWithRange:NSMakeRange(10, 2)]];
            lb_video_name.text = eInfo.sEventName;
            [imv_selectType setImage:[UIImage imageNamed:imgName]];
            [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_pause.png"]];
        }
        
        [scrV_pic addSubview:imv_border];
        [mar_borderImv addObject:imv_border];
        
        UILabel *lb_bg_t = [[UILabel alloc] initWithFrame:imv.frame];
        [lb_bg_t setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
        lb_bg_t.alpha = 0.5;
        [scrV_pic addSubview:lb_bg_t];
        [mar_coverView addObject:lb_bg_t];
        
        UIImageView *imv_type = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        imv_type.center = CGPointMake(imv.center.x - 20, imv.center.y);
        [imv_type setImage:[UIImage imageNamed:imgName]];
        [scrV_pic addSubview:imv_type];
        
        UILabel *lb_time_t = [[UILabel alloc] initWithFrame:imv.frame];
        [lb_time_t setBackgroundColor:[UIColor clearColor]];
        [lb_time_t setFont:[UIFont systemFontOfSize:10]];
        [lb_time_t setTextAlignment:NSTextAlignmentCenter];
        [lb_time_t setTextColor:[UIColor whiteColor]];
        lb_time_t.text = [NSString stringWithFormat:@"%@:%@", [time substringWithRange:NSMakeRange(8, 2)], [time substringWithRange:NSMakeRange(10, 2)]];;
        [scrV_pic addSubview:lb_time_t];
        
        UIButton *btn_t = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_t.frame = imv.frame;
        btn_t.tag = i;
        [btn_t addTarget:self action:@selector(timeImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrV_pic addSubview:btn_t];
        
    }
    
    if (index_nowEvent == -1) {
        [videoCtr stopStreaming];
        
    }
    scrV_pic.contentSize = CGSizeMake(73 * pics.count, scrV_pic.frame.size.height);
}

- (void)refreshContentView
{
    [self refreshTimeScrollView:mar_timeEvent];
    [self refreshPicSrollView:mar_picEvent];
}

#pragma mark - NSTimer
-(void)updateVideoPlaybackTime:(id)sender
{
    if (videoCtr != nil) {
        float time_t = [videoCtr updateVideoPlayTime];
        [slider_time setValue:time_t animated:YES];
       
    }
}

#pragma mark - play action
-(void)play
{
    if (videoCtr == nil || ![videoCtr getOpenFig]) {
        
        SNUserInfo *user = [HDUtility readLocalUserInfo];
        if (index_nowEvent == -1 || mar_picEvent.count <= index_nowEvent) {
            [HDUtility sayAfterFail:@"获取数据失败！"];
            return;
        }
        SNEventInfo *eInfo = [mar_picEvent objectAtIndex:index_nowEvent];
        
        [HUD showAnimated:YES whileExecutingBlock:^{
            
            [[SNHttpUtility sharedClient] getEventVideoURL:user eventID:eInfo.sEventID CompletionBlock:^(BOOL isSuccess, NSString *videoURL, NSString *sMessage) {
                if (isSuccess) {
                    if (!device_Info) {
                        SNCameraInfo *dInfo = [[SNCameraInfo alloc] init];
                        dInfo.sDeviceName = @"userPhone";
                        dInfo.sDeviceId = [NSString stringWithFormat:@"user_%@", user.sUserId];
                        videoCtr = [[PlayViedo alloc] initWithURL:videoURL deviceInfo:dInfo type:SNPlayTypeRebroadcast];
                    }else{
                        videoCtr = [[PlayViedo alloc] initWithURL:videoURL deviceInfo:device_Info type:SNPlayTypeRebroadcast];
                    }
                    videoCtr.view.frame = CGRectMake(0, 0, v_video_play.frame.size.width, v_video_play.frame.size.height);
                    
                    BOOL status = [videoCtr playStreaming];
                    if (!status) {
                        [self pause];
                        return;
                    }
                    
                    [v_video_play addSubview:videoCtr.view];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
                    NSString *time_s = [NSString stringWithFormat:@"%@ %@", sSelectDate, lb_minTime.text];
                    NSDate *time_d = [formatter dateFromString:time_s];
                    [videoCtr setPlayWithTime:time_d playFig:playFig];
                    
                    //        [self orientationChanged:nil];
                    
                    playFig = YES;
                    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_pause.png"]];
                }else{
                    playFig = NO;
                    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_play.png"]];
                }
            }];
        }];
        
    }else{
        
        [HUD showAnimated:YES whileExecutingBlock:^{
            BOOL status = [videoCtr playStreaming];
            if (!status) {
                [self pause];
                return;
            }
            
        }];
        
        playFig = YES;
        [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_pause.png"]];
    }
    
}

-(void)pause
{
    [videoCtr pauseStreaming];
    playFig = NO;
    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_play.png"]];
}

-(void)selectPeriodTime:(int)index
{
    for (int i = 0; i < mar_coverView.count; i++) {
        UILabel *lb_t       = [mar_coverView objectAtIndex:i];
        lb_t.hidden         = NO;
        UIImageView *imv_b  = [mar_borderImv objectAtIndex:i];
        imv_b.hidden        = YES;
        if (i == index) {
            lb_t.hidden     = YES;
            imv_b.hidden    = NO;
            
            index_nowEvent = i;
            [self refreshPicSrollView:mar_picEvent];
            
            if (videoCtr != nil) {
                [videoCtr stopStreaming];
                videoCtr    = nil;
                playFig     = NO;
                [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_play.png"]];
            }
        }
    }
}

#pragma mark - button Action
-(void)doBack:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)timeImageAction:(UIButton *)btn
{
    [self selectPeriodTime:(int)btn.tag];
    [self play];
    
}

-(IBAction)playButtonAction:(UIButton *)btn
{
    Dlog(@"play");
    if (playFig && videoCtr != nil) {
        [self pause];
    }else{
        if (index_nowEvent == -1) {
            [self selectPeriodTime:0];
        }
        [self play];
    }
}

- (IBAction)leftButtonAction:(UIButton *)btn
{
    if (pgc_time.currentPage >= pgc_time.numberOfPages - 1) {
        [HDUtility mbSay:@"没有了"];
        return;
    }
    pgc_time.currentPage++;
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    index_nowEvent = -1;
    [self refreshPicSrollView:mar_picEvent];
}

- (IBAction)rightButtonAction:(UIButton *)btn
{
    if (pgc_time.currentPage <= 0) {
        [HDUtility mbSay:@"没有了"];
        return;
    }
    pgc_time.currentPage--;
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    index_nowEvent = -1;
    [self refreshPicSrollView:mar_picEvent];
}

- (IBAction)selectEventTypeAll:(UIButton *)btn
{
    lb_eventLine.frame = CGRectMake(84, lb_eventLine.frame.origin.y, lb_eventLine.frame.size.width, lb_eventLine.frame.size.height);
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] getEvents:user deviceID:device_Info.sDeviceId eventTypeID:nil start:0 limit:0 startTime:[NSDate date] endTime:[NSDate date] CompletionBlock:^(BOOL isSuccess, NSArray *arrayEvents, NSString *sMessage) {
        if (isSuccess) {
            Dlog("===event %@", arrayEvents);
            NSArray *ar_t = [[arrayEvents objectAtIndex:0] valueForKey:device_Info.sDeviceId];
            [mar_picEvent removeAllObjects];
            [mar_picEvent addObjectsFromArray:ar_t];
            [self refreshPicSrollView:mar_picEvent];
        }else{
            [mar_picEvent removeAllObjects];
            index_nowEvent = -1;
        }
    }];
}

- (IBAction)selectEventTypeRed:(UIButton *)btn
{
    lb_eventLine.frame = CGRectMake(134, lb_eventLine.frame.origin.y, lb_eventLine.frame.size.width, lb_eventLine.frame.size.height);
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] getEvents:user deviceID:device_Info.sDeviceId eventTypeID:nil start:0 limit:0 startTime:[NSDate date] endTime:[NSDate date] CompletionBlock:^(BOOL isSuccess, NSArray *arrayEvents, NSString *sMessage) {
        if (isSuccess) {
            Dlog("===event %@", arrayEvents);
            NSArray *ar_t = [[arrayEvents objectAtIndex:0] valueForKey:device_Info.sDeviceId];
            [mar_picEvent removeAllObjects];
            [mar_picEvent addObjectsFromArray:ar_t];
            [self refreshPicSrollView:mar_picEvent];
        }else{
            [mar_picEvent removeAllObjects];
            index_nowEvent = -1;
        }
    }];
}

- (IBAction)selectEventTypeYellow:(UIButton *)btn
{
    lb_eventLine.frame = CGRectMake(184, lb_eventLine.frame.origin.y, lb_eventLine.frame.size.width, lb_eventLine.frame.size.height);
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] getEvents:user deviceID:device_Info.sDeviceId eventTypeID:nil start:0 limit:0 startTime:[NSDate date] endTime:[NSDate date] CompletionBlock:^(BOOL isSuccess, NSArray *arrayEvents, NSString *sMessage) {
        if (isSuccess) {
            Dlog("===event %@", arrayEvents);
            NSArray *ar_t = [[arrayEvents objectAtIndex:0] valueForKey:device_Info.sDeviceId];
            [mar_picEvent removeAllObjects];
            [mar_picEvent addObjectsFromArray:ar_t];
            [self refreshPicSrollView:mar_picEvent];
        }else{
            [mar_picEvent removeAllObjects];
            index_nowEvent = -1;
        }
    }];
}

- (IBAction)selectEventTypePurle:(UIButton *)btn
{
    lb_eventLine.frame = CGRectMake(234, lb_eventLine.frame.origin.y, lb_eventLine.frame.size.width, lb_eventLine.frame.size.height);
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] getEvents:user deviceID:device_Info.sDeviceId eventTypeID:nil start:0 limit:0 startTime:[NSDate date] endTime:[NSDate date] CompletionBlock:^(BOOL isSuccess, NSArray *arrayEvents, NSString *sMessage) {
        if (isSuccess) {
            Dlog("===event %@", arrayEvents);
            NSArray *ar_t = [[arrayEvents objectAtIndex:0] valueForKey:device_Info.sDeviceId];
            [mar_picEvent removeAllObjects];
            [mar_picEvent addObjectsFromArray:ar_t];
            [self refreshPicSrollView:mar_picEvent];
        }else{
            [mar_picEvent removeAllObjects];
            index_nowEvent = -1;
        }
    }];
}

#pragma mark - UIDeviiceOrientation Notification
- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait://up
        case UIDeviceOrientationPortraitUpsideDown://down
        {
            if (videoCtr != nil) {
                [videoCtr turnToDown];
                videoCtr.view.frame = CGRectMake(0, 0, v_video_play.frame.size.width, v_video_play.frame.size.height);
                [v_video_play addSubview:videoCtr.view];
                self.navigationController.navigationBarHidden = NO;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
                NSDate *time_d = [videoCtr getPalyTime];
                NSString *time_s = nil;
                if (time_d == nil) {
                    time_s = [NSString stringWithFormat:@"%@ %@", sSelectDate, lb_minTime.text];
                }else{
                    time_s = [formatter stringFromDate:time_d];
                }
                
                sSelectDate = [time_s substringToIndex:10];
                for (int i = 0; i < mar_timeEvent.count; i++) {
                    if ([sSelectDate isEqualToString:[mar_timeEvent objectAtIndex:i]]) {
                        pgc_time.currentPage = i;
                        [self refreshTimeScrollView:mar_timeEvent];
                        break;
                    }
                }
                
                int tag = [[time_s substringWithRange:NSMakeRange(11, 2)] intValue];
                for (int i = 0; i < mar_coverView.count; i++) {
                    UILabel *lb_t = [mar_coverView objectAtIndex:i];
                    lb_t.hidden = NO;
                    if (i == tag) {
                        lb_t.hidden = YES;
                        lb_minTime.text = [NSString stringWithFormat:@"%02d:00:00", i];
                        lb_maxTime.text = [NSString stringWithFormat:@"%02d:59:00", i];
                        index_nowEvent = i;
                        [self refreshPicSrollView:mar_picEvent];
                        int vaule_m = [[time_s substringWithRange:NSMakeRange(14, 2)] intValue];
                        int vaule_s = [[time_s substringFromIndex:17] intValue];
                        slider_time.value = vaule_m * 60 + vaule_s;
                    }
                }
                
                playFig = [videoCtr getPlayFig];
                if (playFig) {
                    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_pause.png"]];
                }else{
                    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_play.png"]];
                }
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft://left
        {
            if (videoCtr != nil) {
                [videoCtr turnToLeft];
                videoCtr.view.frame = [UIApplication sharedApplication].keyWindow.frame;
                [[UIApplication sharedApplication].keyWindow addSubview:videoCtr.view];
                self.navigationController.navigationBarHidden = YES;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
                NSString *time_s = [NSString stringWithFormat:@"%@ %@", sSelectDate, lb_minTime.text];
                NSDate *time_d = [formatter dateFromString:time_s];
                [videoCtr setPlayWithTime:time_d playFig:playFig];
            }
        }
            break;
        case UIDeviceOrientationLandscapeRight://right
        {
            if (videoCtr != nil) {
                [videoCtr turnToRight];
                videoCtr.view.frame = [UIApplication sharedApplication].keyWindow.frame;
                [[UIApplication sharedApplication].keyWindow addSubview:videoCtr.view];
                self.navigationController.navigationBarHidden = YES;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
                NSString *time_s = [NSString stringWithFormat:@"%@ %@", sSelectDate, lb_minTime.text];
                NSDate *time_d = [formatter dateFromString:time_s];
                [videoCtr setPlayWithTime:time_d playFig:playFig];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == scr_time) {
        CGFloat pageWith = scrollView.frame.size.width;//页面宽度
        int pageNumber = floor((scrollView.contentOffset.x - pageWith / 2) / pageWith) + 1;
        pgc_time.currentPage = pageNumber;
    }
    
    
}

- (IBAction)pageControlAction:(UIPageControl *)sender
{
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * sender.currentPage, 0) animated:YES];
}

@end
