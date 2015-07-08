//
//  SNSeeBackVideoViewCtr.m
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "SNSeeBackVideoViewCtr.h"
#import "SNPhotoSeeVideo.h"
#import "PlayViedo.h"
#import "UIImageExtensions.h"
#import "SNRequestImag.h"

@interface SNSeeBackVideoViewCtr ()
{
    
    IBOutlet UIView         *v_top;
    IBOutlet UIScrollView   *scr_time;
    
    IBOutlet UIView         *v_content;
    
    IBOutlet UIView         *v_bg_video;
    IBOutlet UIView         *v_bg_label;
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
    
    NSMutableArray          *mar_imv;
    NSMutableArray          *mar_coverView;
    NSMutableArray          *mar_borderImv;
    NSMutableArray          *mar_timeBack;
    NSMutableArray          *mar_picBack;
    
    PlayViedo               *videoCtr;
    BOOL                    playFig;
    NSTimer                 *timer_play;
    SNCameraInfo            *device_Info;
    float                   time_Select;
    int                     index_nowBack;
    CGPoint                 point_begin;
    NSString                *sSelectDate;
    
    MBProgressHUD           *HUD;
}
@end

@implementation SNSeeBackVideoViewCtr

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
    mar_timeBack    = [[NSMutableArray alloc] init];
    mar_picBack     = [[NSMutableArray alloc] init];
    playFig         = NO;
    index_nowBack   = -1;
    
    for (int i = 0; i < 24; i++) {
        [mar_picBack addObject:[NSString stringWithFormat:@"%02d:00-%02d:59", i, i]];
    }
    lb_selectTime.text = @"";
    
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
    sSelectDate = [formatter stringFromDate:[NSDate date]];
    NSString *sDate1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24]];
    NSString *sDate2 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 2]];
    [mar_timeBack addObject:sDate2];
    [mar_timeBack addObject:sDate1];
    [mar_timeBack addObject:sSelectDate];
    
    [self refreshTimeScrollView:mar_timeBack];
    
    if (device_Info) {
        lb_video_name.text      = device_Info.sDeviceName;
    }
    
    [self refreshPicSrollView];
    
    timer_play = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self selector:@selector(updateVideoPlaybackTime:) userInfo:nil repeats:YES];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"数据请求中...";
    HUD.dimBackground = YES;
    [self.view addSubview:HUD];
    
    //打开设备产生朝向通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //注册设备朝向通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    //  http://dev.umeng.com/social/ios/sdk-download
    [NSThread detachNewThreadSelector:@selector(doLoadImage) toTarget:self withObject:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


#pragma mark - image
- (void)doLoadImage{
    for (int i = 0; i < mar_imv.count; i++) {
        UIImageView *imv = [mar_imv objectAtIndex:i];
        NSString *url = [self getImageURL:i];
        [SNRequestImag requestImageWithURL:url imageView:imv acquiesceImg:[UIImage imageNamed:@"screenshot.jpg"]];
    }
    
}

- (NSString *)getImageURL:(int)index
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH"];
    NSString *sHour = [NSString stringWithFormat:@"%02d", index];
    NSString *time_s = [NSString stringWithFormat:@"%@ %@", sSelectDate, sHour];
    NSDate *time_d = [formatter dateFromString:time_s];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyyMMddHH"];
    NSString *time_name_t = [formatter1 stringFromDate:time_d];
    NSString *sURL = [NSString stringWithFormat:@"%@/%@_%@.jpg", [device_Info.sPhotoUrl stringByDeletingLastPathComponent], device_Info.sDeviceId, time_name_t];
    
    return sURL;
}

- (NSString *)getURL
{
    SNServerInfo *sInfo = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *time_s = [NSString stringWithFormat:@"%@ %@", sSelectDate, lb_minTime.text];
    NSDate *time_d = [formatter dateFromString:time_s];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyyMMddHH"];
    NSString *time_name_t = [formatter1 stringFromDate:time_d];
    NSString *sURL = [NSString stringWithFormat:@"%@%@/%@_%@.mp4", sInfo.sRtsp_real, device_Info.sDeviceId, device_Info.sDeviceId, time_name_t];
    
    return sURL;
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

- (void)refreshPicSrollView
{
    for (UIView *v_t in scrV_pic.subviews) {
        [v_t removeFromSuperview];
    }
    
    [mar_imv removeAllObjects];
    [mar_coverView removeAllObjects];
    [mar_borderImv removeAllObjects];
    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_play.png"]];
    lb_selectTime.text = @"";
    
    for (int i = 0; i < 24; i++) {
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(73 * i, 0, 71, 43)];
        [scrV_pic addSubview:imv];
        [mar_imv addObject:imv];
        
        UIImageView *imv_border = [[UIImageView alloc] initWithFrame:imv.frame];
        [imv_border setImage:[UIImage imageNamed:@"photo_video_border.png"]];
        imv_border.hidden = YES;
        if (index_nowBack == i) {
            imv_border.hidden = NO;
            lb_selectTime.text = [NSString stringWithFormat:@"%02d:00-%02d:59", i, i];
            [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_pause.png"]];
        }
        [scrV_pic addSubview:imv_border];
        [mar_borderImv addObject:imv_border];
        
        UILabel *lb_bg_t = [[UILabel alloc] initWithFrame:imv.frame];
        [lb_bg_t setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
        lb_bg_t.alpha = 0.5;
        [scrV_pic addSubview:lb_bg_t];
        [mar_coverView addObject:lb_bg_t];
        
        UILabel *lb_time_t = [[UILabel alloc] initWithFrame:imv.frame];
        [lb_time_t setBackgroundColor:[UIColor clearColor]];
        [lb_time_t setFont:[UIFont systemFontOfSize:10]];
        [lb_time_t setTextAlignment:NSTextAlignmentCenter];
        [lb_time_t setTextColor:[UIColor whiteColor]];
        lb_time_t.text = [NSString stringWithFormat:@"%02d:00-%02d:59", i, i];
        [scrV_pic addSubview:lb_time_t];
        
        UIButton *btn_t = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_t.frame = imv.frame;
        btn_t.tag = i;
        [btn_t addTarget:self action:@selector(timeImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrV_pic addSubview:btn_t];
        
    }
    
    if (index_nowBack == -1) {
        [videoCtr stopStreaming];
        
    }
    
    scrV_pic.contentSize = CGSizeMake(73 * 24, scrV_pic.frame.size.height);
}

- (void)refreshContentView
{
    [self refreshTimeScrollView:mar_timeBack];
    [self refreshPicSrollView];
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
        //            NSString *sURL = @"rtsp://121.40.95.209:554/littleApple.mp4";
        NSString *sURL = [self getURL];
        SNUserInfo *user = [HDUtility readLocalUserInfo];
        if (!device_Info) {
            SNCameraInfo *dInfo = [[SNCameraInfo alloc] init];
            dInfo.sDeviceName = @"userPhone";
            dInfo.sDeviceId = [NSString stringWithFormat:@"user_%@", user.sUserId];
            videoCtr = [[PlayViedo alloc] initWithURL:sURL deviceInfo:dInfo type:SNPlayTypeRebroadcast];
        }else{
//            videoCtr = [[PlayViedo alloc] initWithURL:sURL deviceInfo:device_Info type:SNPlayTypeRebroadcast];
            videoCtr = [[PlayViedo alloc] initWithURL:sURL deviceInfo:device_Info type:SNPlayTypeLiveTelecast];
        }
        videoCtr.view.frame = CGRectMake(0, 0, v_video_play.frame.size.width, v_video_play.frame.size.height);
        [HUD showAnimated:YES whileExecutingBlock:^{
            BOOL status = [videoCtr playStreaming];
            if (!status) {
                [self pause];
                return;
            }
            
        }];
        
        [v_video_play addSubview:videoCtr.view];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
         NSString *time_s = [NSString stringWithFormat:@"%@ %@", sSelectDate, lb_minTime.text];
         NSDate *time_d = [formatter dateFromString:time_s];
         [videoCtr setPlayWithTime:time_d playFig:playFig];
        
        //        [self orientationChanged:nil];
        
    }else{
        
        [HUD showAnimated:YES whileExecutingBlock:^{
            BOOL status = [videoCtr playStreaming];
            if (!status) {
                [self pause];
                return;
            }
            
        }];
        
    }
    
    playFig = YES;
    [imv_playBtn setImage:[UIImage imageNamed:@"photo_video_pause.png"]];
    
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
            
            lb_selectTime.text  = [NSString stringWithFormat:@"%02d:00-%02d:59", i, i];
            index_nowBack = i;
            
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
        if (index_nowBack == -1) {
            [self selectPeriodTime:0];
        }
        [self play];
    }
}

-(IBAction)screenshotButtonAction:(UIButton *)btn
{
    Dlog(@"screenshot");
    if (videoCtr != nil) {
        [videoCtr getImageStart];
    }
    
}

- (IBAction)leftButtonAction:(UIButton *)btn
{
    if (pgc_time.currentPage >= pgc_time.numberOfPages - 1) {
        [HDUtility mbSay:@"没有了"];
        return;
    }
    pgc_time.currentPage++;
    index_nowBack = -1;
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    [self refreshPicSrollView];
}

- (IBAction)rightButtonAction:(UIButton *)btn
{
    if (pgc_time.currentPage <= 0) {
        [HDUtility mbSay:@"没有了"];
        return;
    }
    pgc_time.currentPage--;
    index_nowBack = -1;
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    [self refreshPicSrollView];
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
                for (int i = 0; i < mar_timeBack.count; i++) {
                    if ([sSelectDate isEqualToString:[mar_timeBack objectAtIndex:i]]) {
                        pgc_time.currentPage = i;
                        [self refreshTimeScrollView:mar_timeBack];
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
                        index_nowBack = i;
                        [self refreshPicSrollView];
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

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    UITouch *touch = [touches anyObject];
    //    CGPoint point = [touch  locationInView:self.view];
    //    point_begin = point;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch  locationInView:self.view];
    Dlog(@"==moved==%f", point.x - point_begin.x);
    float delta_x = point.x - point_begin.x;
    
    if (delta_x > 50) {
        Dlog(@"向右走");
        pgc_time.currentPage--;
        if (pgc_time.currentPage < 0) {
            pgc_time.currentPage = 0;
        }
        [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    }else if(delta_x < -50){
        Dlog(@"向左走");
        pgc_time.currentPage++;
        if (pgc_time.currentPage >= pgc_time.numberOfPages) {
            pgc_time.currentPage = pgc_time.numberOfPages - 1;
        }
        [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
        
    }
}

@end
