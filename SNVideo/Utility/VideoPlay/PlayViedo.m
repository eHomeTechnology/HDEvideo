//
//  playViedo.m
//  THTest
//
//  Created by Thinking on 14-8-26.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "PlayViedo.h"
#import <QuartzCore/QuartzCore.h>
#include <arpa/inet.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "audioQueue.h"
#import "MBProgressHUD.h"
#import "SNHttpUtility.h"
#import "HDFileUtility.h"

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex_video;

const Vertex_video Vertices_video[] = {
    {{1, -1, 0}, {1, 1, 1, 1}, {1, 1}},
    {{1, 1, 0}, {1, 1, 1, 1}, {1, 0}},
    {{-1, 1, 0}, {1, 1, 1, 1}, {0, 0}},
    {{-1, -1, 0}, {1, 1, 1, 1}, {0, 1}}
};

const GLubyte Indices_video[] = {
    0, 1, 2,
    2, 3, 0
};

#pragma mark - shaders

#define STRINGIZE_VIDEO(x) #x
#define STRINGIZE2_VIDEO(x) STRINGIZE_VIDEO(x)
#define SHADER_STRING_VIDEO(text) @ STRINGIZE2_VIDEO(text)

NSString *const vertexShaderString_video = SHADER_STRING_VIDEO
(
 attribute vec4 Position; // 1
 attribute vec4 SourceColor; // 2
 
 varying vec4 DestinationColor; // 3
 
 attribute vec2 TexCoordIn;
 varying vec2 TexCoordOut;
 
 void main(void) { // 4
     DestinationColor = SourceColor; // 5
     gl_Position = Position; // 6
     TexCoordOut = TexCoordIn; // New
 }
 );

NSString *const rgbFragmentShaderString_video = SHADER_STRING_VIDEO
(
 varying highp vec2 TexCoordOut;
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 uniform sampler2D s_texture_v;
 
 void main()
 {
     highp float y = texture2D(s_texture_y, TexCoordOut).r;
     highp float u = texture2D(s_texture_u, TexCoordOut).r - 0.5;
     highp float v = texture2D(s_texture_v, TexCoordOut).r - 0.5;
     
     highp float r = y +             1.402 * v;
     highp float g = y - 0.344 * u - 0.714 * v;
     highp float b = y + 1.772 * u;
     
     gl_FragColor = vec4(r,g,b,1.0);
 }
 
 );

#pragma mark - AVPlayViewCtr

@interface PlayViedo ()
{
    NSString *sAV_URL;
    int counter;
    BOOL searching;
    
    FFmpegDecod *ffmpeg_decode;
    AudioQueue *audio_queue;
    
    float curRed;
    BOOL increasing;
    GLuint vertexBuffer;
    GLuint indexBuffer;
    GLuint positionSlot;
    GLuint colorSlot;
    uint16_t textureWidth;
    uint16_t textureHeight;
    GLuint yTexture;
    GLuint uTexture;
    GLuint vTexture;
    GLuint texCoordSlot;
    GLuint yTextureUniform;
    GLuint uTextureUniform;
    GLuint vTextureUniform;
    dispatch_semaphore_t textureUpdateRenderSemaphore;
    BOOL shouldHideMaster;
    
    UIView          *v_avGL;
    UISlider        *slider_time;
    UIView          *v_bottm_redroadcast;
    UILabel         *lb_start_time;
    UILabel         *lb_end_time;
    UIView          *v_datePicker;
    UIDatePicker    *datePicker;
    UIButton        *btn_sliderNowTime;
    
    MBProgressHUD   *HUD;
    MBProgressHUD   *hud_getImag;
    UIView          *v_father;
    NSString        *sDeviceID;
    NSString        *sDeviceName;
    NSString        *sImageURL;
    NSTimer         *timer_Now;
    int             mint;
    
    UILabel         *lb_date;
    UILabel         *lb_time;
    SNPlayType      pType;
    BOOL            playFig;
    
    NSMutableArray  *ar_imv;
    NSMutableArray  *ar_coverView;
    
    float           nowPlayTime;
    int             playPausedNum;
    
}

@property (strong, nonatomic) EAGLContext   *context;
@property (strong, nonatomic) NSData        *testYUVInputData;
@property (strong, nonatomic) NSArray       *ipcamList;
@property (strong, nonatomic) NSArray       *channelList;
@property (strong, nonatomic) NSString      *currentCameraIP;
@property (strong, nonatomic) NSString      *currentCameraCh;

//@property (strong, nonatomic) CameraFinder* cameraFinder;

@end

@implementation PlayViedo

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSString *)url deviceInfo:(SNCameraInfo *)dInfo type:(SNPlayType)typ
{
    self = [super init];
    if (self) {
        sAV_URL             = url;
        sDeviceID           = dInfo.sDeviceId;
        sDeviceName         = dInfo.sDeviceName;
        sImageURL            = dInfo.sPhotoUrl;
        pType               = typ;
        ar_imv              = [[NSMutableArray alloc] init];
        ar_coverView        = [[NSMutableArray alloc] init];
        playFig             = NO;
    }
    return self;
}

-(void)initFatherView:(UIView *)fView
{
    v_father = fView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    nowPlayTime = 0;
    playPausedNum = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageNotification:) name:imgeNotificatio object:nil];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        Dlog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    v_avGL = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    [v_avGL setBackgroundColor:[UIColor clearColor]];
    v_avGL.hidden = YES;
    [self.view addSubview:v_avGL];
    if (pType == SNPlayTypeLiveTelecast) {
        [self createLiveTelecastView];
    }else{
        [self createRebroadcastView];
    }
    
    
    [self setupGL];
    [self compileShaders];
    
    // setup the textures
    textureWidth = 1280;
    textureHeight = 720;
    yTexture = [self setupTexture:nil width:textureWidth height:textureHeight textureIndex:0];
    uTexture = [self setupTexture:nil width:textureWidth/2 height:textureHeight/2 textureIndex:1];
    vTexture = [self setupTexture:nil width:textureWidth/2 height:textureHeight/2 textureIndex:2];
    
    shouldHideMaster = NO;
    
    //ffmpeg wrapper
//    self.cameraFinder.delegate = self;
//    [self.cameraFinder startSearch];
//    HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    HUD.labelText = @"数据请求中...";
//    HUD.dimBackground = YES;
//    [self.view addSubview:HUD];
//    
    mint                        = 0;
    timer_Now                   = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self selector:@selector(updateVideoNowkTime:) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [NSThread detachNewThreadSelector:@selector(doLoadImage) toTarget:self withObject:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:imgeNotificatio object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark getStringRect
- (CGSize)getStringRect:(NSString*)aString Size:(CGSize)size font:(UIFont *)font
{
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize retSize = [aString boundingRectWithSize:size
                                             options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    return retSize;
}

#pragma mark - create  play view
- (void)createLiveTelecastView
{
    UIView *v_top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 30)];
    [v_top setBackgroundColor:[UIColor clearColor]];
    [v_avGL addSubview:v_top];
    UIView *v_topBg = [[UIView alloc] initWithFrame:v_top.frame];
    [v_topBg setBackgroundColor:[UIColor blackColor]];
    [v_topBg setAlpha:0.2];
    [v_top addSubview:v_topBg];
    
    UIButton *btn_cutView = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_cutView.frame = CGRectMake(10, 0, 30, 30);
    [btn_cutView setImage:[UIImage imageNamed:@"button_分屏显示.png"] forState:UIControlStateNormal];
    [v_top addSubview:btn_cutView];
    
    CGSize titleSize = [self getStringRect:sDeviceName Size:CGSizeMake(400, 30) font:[UIFont systemFontOfSize:15]];
    UIView *v_topMiddle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleSize.width + 17 + 11 + 20, 30)];
    [v_topMiddle setBackgroundColor:[UIColor clearColor]];
    v_topMiddle.center = v_top.center;
    [v_top addSubview:v_topMiddle];
    
    UIImageView *imv_btn_friend = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 17, 14)];
    [imv_btn_friend setImage:[UIImage imageNamed:@"icon_firend_device.png"]];
    [v_topMiddle addSubview:imv_btn_friend];
    
    UILabel *lb_rec_dName = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, titleSize.width, 30)];
    [lb_rec_dName setBackgroundColor:[UIColor clearColor]];
    [lb_rec_dName setTextColor:[UIColor whiteColor]];
    [lb_rec_dName setFont:[UIFont systemFontOfSize:15]];
    lb_rec_dName.text = sDeviceName;
    [v_topMiddle addSubview:lb_rec_dName];
    
    UIImageView *imv_rec_t2 = [[UIImageView alloc] initWithFrame:CGRectMake(lb_rec_dName.frame.origin.x + titleSize.width + 10, 9, 11, 11)];
    [imv_rec_t2 setImage:[UIImage imageNamed:@"icon_online.png"]];
    [v_topMiddle addSubview:imv_rec_t2];
    
    UIButton *btn_more = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_more.frame = CGRectMake(v_top.frame.size.width - 40, 0, 30, 30);
    [btn_more setImage:[UIImage imageNamed:@"button_更多.png"] forState:UIControlStateNormal];
    [v_top addSubview:btn_more];
    
    UIView *v_bottm = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width - 44, self.view.frame.size.height, 44)];
    [v_bottm setBackgroundColor:[UIColor blackColor]];
    [v_bottm setAlpha:0.2];
    [v_avGL addSubview:v_bottm];
    lb_date = [[UILabel alloc] initWithFrame:CGRectMake(0, v_bottm.frame.origin.y, 80, 42)];
    [lb_date setBackgroundColor:[UIColor clearColor]];
    [lb_date setFont:[UIFont systemFontOfSize:13]];
    [lb_date setTextAlignment:NSTextAlignmentCenter];
    [lb_date setTextColor:[UIColor whiteColor]];
    [v_avGL addSubview:lb_date];
    lb_date.text = @"2014/09/19";
    lb_time = [[UILabel alloc] initWithFrame:CGRectMake(80, v_bottm.frame.origin.y, 80, 42)];
    [lb_time setBackgroundColor:[UIColor clearColor]];
    [lb_time setFont:[UIFont systemFontOfSize:15]];
    [lb_time setTextColor:[UIColor colorWithRed:33/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [v_avGL addSubview:lb_time];
    lb_time.text = @"08:11";
    UIButton *btn_screenshot = [[UIButton alloc] initWithFrame:CGRectMake(v_bottm.frame.size.width - 180, v_bottm.frame.origin.y, 42, 42)];
    [btn_screenshot setBackgroundColor:[UIColor clearColor]];
    [btn_screenshot setImage:[UIImage imageNamed:@"icon_screenshot_01.png"] forState:UIControlStateNormal];
    [btn_screenshot addTarget:self action:@selector(screenshotButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_avGL addSubview:btn_screenshot];
    UIButton *btn_record = [[UIButton alloc] initWithFrame:CGRectMake(v_bottm.frame.size.width - 120, v_bottm.frame.origin.y, 42, 42)];
    [btn_record setBackgroundColor:[UIColor clearColor]];
    [btn_record setImage:[UIImage imageNamed:@"icon_Recing_02.png"] forState:UIControlStateNormal];
    [btn_record addTarget:self action:@selector(recordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_avGL addSubview:btn_record];
    UIButton *btn_down = [[UIButton alloc] initWithFrame:CGRectMake(v_bottm.frame.size.width - 60, v_bottm.frame.origin.y, 42, 42)];
    [btn_down setBackgroundColor:[UIColor clearColor]];
    [btn_down setImage:[UIImage imageNamed:@"icon_cutdown_view.png"] forState:UIControlStateNormal];
    [btn_down addTarget:self action:@selector(downButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_avGL addSubview:btn_down];
}

- (void)createRebroadcastView
{
    UIView *v_top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 30)];
    [v_top setBackgroundColor:[UIColor blackColor]];
    [v_top setAlpha:0.2];
    [v_avGL addSubview:v_top];
    
    UIButton *Btn_time_t = [[UIButton alloc] initWithFrame:CGRectMake(20, 4, 80, 22)];
    [Btn_time_t setBackgroundColor:[UIColor colorWithRed:25/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    [Btn_time_t addTarget:self action:@selector(selectTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_avGL addSubview:Btn_time_t];
    lb_date = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 80, 22)];
    [lb_date setBackgroundColor:[UIColor clearColor]];
    [lb_date setTextAlignment:NSTextAlignmentCenter];
    [lb_date setFont:[UIFont systemFontOfSize:12]];
    [lb_date setTextColor:[UIColor whiteColor]];
    lb_date.text = @"2014/09/25";
    [v_avGL addSubview:lb_date];
    
    UILabel *lb_rec_dName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    [lb_rec_dName setBackgroundColor:[UIColor clearColor]];
    [lb_rec_dName setTextColor:[UIColor whiteColor]];
    [lb_rec_dName setTextAlignment:NSTextAlignmentCenter];
    [lb_rec_dName setFont:[UIFont systemFontOfSize:15]];
    [lb_rec_dName setCenter:v_top.center];
    lb_rec_dName.text = sDeviceName;
    [v_avGL addSubview:lb_rec_dName];
    
    UIButton *btn_screenshot = [[UIButton alloc] initWithFrame:CGRectMake(v_top.frame.size.width - 60, v_top.frame.origin.y, 30, 30)];
    [btn_screenshot setBackgroundColor:[UIColor clearColor]];
    [btn_screenshot setImage:[UIImage imageNamed:@"icon_screenshot_01.png"] forState:UIControlStateNormal];
    [btn_screenshot addTarget:self action:@selector(screenshotButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_avGL addSubview:btn_screenshot];
    
    v_bottm_redroadcast = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width - 30, self.view.frame.size.height, 70)];
    [v_avGL addSubview:v_bottm_redroadcast];
    UIView *v_bootm_t = [[UIView alloc] initWithFrame:CGRectMake(0, 0, v_bottm_redroadcast.frame.size.width, v_bottm_redroadcast.frame.size.height)];
    [v_bootm_t setBackgroundColor:[UIColor blackColor]];
    [v_bootm_t setAlpha:0.2];
    [v_bottm_redroadcast addSubview:v_bootm_t];
    
    lb_start_time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [lb_start_time setBackgroundColor:[UIColor clearColor]];
    [lb_start_time setTextAlignment:NSTextAlignmentCenter];
    [lb_start_time setFont:[UIFont systemFontOfSize:10]];
    [lb_start_time setTextColor:[UIColor colorWithRed:25/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    lb_start_time.text = @"00:00:00";
    [v_bottm_redroadcast addSubview:lb_start_time];
    
    slider_time = [[UISlider alloc] initWithFrame:CGRectMake(60, 0, v_bottm_redroadcast.frame.size.width - 120, 30)];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"photo_slider_01.png"];
    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
    [slider_time setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [slider_time setThumbImage:thumbImage forState:UIControlStateNormal];
    [slider_time setMinimumValue:0];
    [slider_time setMaximumValue:60 * 60];
    [slider_time addTarget:self action:@selector(sliderChangeVaule:) forControlEvents:UIControlEventValueChanged];
    [slider_time addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchUpInside];
    [v_bottm_redroadcast addSubview:slider_time];
    
    btn_sliderNowTime = [[UIButton alloc] initWithFrame:CGRectMake(55, v_bottm_redroadcast.frame.origin.y - 25, 34, 27)];
    [btn_sliderNowTime setBackgroundImage:[UIImage imageNamed:@"photo_slider_05.png"] forState:UIControlStateNormal];
    [btn_sliderNowTime setTitle:@"00:00:00" forState:UIControlStateNormal];
    [btn_sliderNowTime.titleLabel setFont:[UIFont systemFontOfSize:8]];
    [v_avGL addSubview:btn_sliderNowTime];
    
    lb_end_time = [[UILabel alloc] initWithFrame:CGRectMake(v_bottm_redroadcast.frame.size.width - 60, 0, 60, 30)];
    [lb_end_time setBackgroundColor:[UIColor clearColor]];
    [lb_end_time setTextAlignment:NSTextAlignmentCenter];
    [lb_end_time setFont:[UIFont systemFontOfSize:10]];
    [lb_end_time setTextColor:[UIColor colorWithRed:25/255.0 green:192/255.0 blue:192/255.0 alpha:1]];
    lb_end_time.text = @"01:00:00";
    [v_bottm_redroadcast addSubview:lb_end_time];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, v_bottm_redroadcast.frame.size.width, 40)];
    [v_bottm_redroadcast addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(60 * 12, scrollView.frame.size.height);
    for (int i = 0; i < 24; i++) {
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(60 * i, 0, 58, 40)];
        [imv setImage:[UIImage imageNamed:@"screenshot.jpg"]];
        [scrollView addSubview:imv];
        [ar_imv addObject:imv];
        
        UIButton *btn_t = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_t.frame = imv.frame;
        btn_t.tag = i;
        [btn_t addTarget:self action:@selector(timeImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btn_t];
        
        UILabel *lb_bg_t = [[UILabel alloc] initWithFrame:imv.frame];
        [lb_bg_t setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
        lb_bg_t.alpha = 0.5;
        if (i == 0) {
            lb_bg_t.hidden = YES;
        }
        [scrollView addSubview:lb_bg_t];
        [ar_coverView addObject:lb_bg_t];
        
        UILabel *lb_time_t = [[UILabel alloc] initWithFrame:imv.frame];
        [lb_time_t setBackgroundColor:[UIColor clearColor]];
        [lb_time_t setFont:[UIFont systemFontOfSize:8]];
        [lb_time_t setTextAlignment:NSTextAlignmentCenter];
        [lb_time_t setTextColor:[UIColor whiteColor]];
        lb_time_t.text = [NSString stringWithFormat:@"%02d:00", i];
        [scrollView addSubview:lb_time_t];
    }
    
    UIButton *btn_bg = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_bg.frame = CGRectMake(0, 30, v_avGL.frame.size.width, v_avGL.frame.size.height - 100);
    [btn_bg setBackgroundColor:[UIColor clearColor]];
    [btn_bg addTarget:self action:@selector(backgroundButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_avGL addSubview:btn_bg];
    
    v_datePicker = [[UIView alloc] initWithFrame:CGRectMake(0, v_avGL.frame.size.height , v_avGL.frame.size.width, 192)];
    [v_datePicker setBackgroundColor:[UIColor whiteColor]];
    [v_avGL addSubview:v_datePicker];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(v_datePicker.center.x - 160, 30, self.view.frame.size.width, 162)];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setDate:[NSDate date]];
    [datePicker setMaximumDate:[NSDate date]];
    [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [datePicker addTarget:self action:@selector(datePickerChangeVaule:) forControlEvents:UIControlEventValueChanged];
    [v_datePicker addSubview:datePicker];
    
    UIButton *btn_down_datePicker = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, v_datePicker.frame.size.width, 30)];
    [btn_down_datePicker setBackgroundColor:[UIColor colorWithRed:39/255.0 green:49/255.0 blue:65/255.0 alpha:1]];
    [btn_down_datePicker setTitle:@"收起" forState:UIControlStateNormal];
    [btn_down_datePicker addTarget:self action:@selector(datePickerDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_datePicker addSubview:btn_down_datePicker];
}

#pragma mark - downImage
- (void)doLoadImage{
    for (int i = 0; i < ar_imv.count; i++) {
        UIImageView *imv = [ar_imv objectAtIndex:i];
        NSURL *url = [NSURL URLWithString:[self getImageURL:i]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        [imv setImage:image];
    }
    
}

- (NSString *)getImageURL:(int)index
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH"];
    NSString *sHour = [NSString stringWithFormat:@"%02d", index];
    NSString *time_s = [NSString stringWithFormat:@"%@ %@", lb_date.text, sHour];
    NSDate *time_d = [formatter dateFromString:time_s];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyyMMddHH"];
    NSString *time_name_t = [formatter1 stringFromDate:time_d];
    NSString *sURL = [NSString stringWithFormat:@"%@/%@_%@.jpg", [sImageURL stringByDeletingLastPathComponent], sDeviceID, time_name_t];
    
    return sURL;
}

- (NSString *)getURL
{
    SNServerInfo *sInfo = [SNServerInfo serverInfoWithDictionary:[HDUtility readSeverInfo]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *time_s = [NSString stringWithFormat:@"%@ %@:%@", lb_date.text, [lb_start_time.text substringToIndex:2], btn_sliderNowTime.titleLabel.text];
    NSDate *time_d = [formatter dateFromString:time_s];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyyMMddHH"];
    NSString *time_name_t = [formatter1 stringFromDate:time_d];
    NSString *sURL = [NSString stringWithFormat:@"%@%@/%@_%@.sdp", sInfo.sRtsp_real, sDeviceID, sDeviceID, time_name_t];
    
    return sURL;
}

#pragma mark - Turn view
-(void)turnToLeft
{
    //设置状态栏旋转
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //设置旋转动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
//    self.navigationController.navigationBar.transform = CGAffineTransformMakeRotation(M_PI*1.5);
    self.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    [UIView commitAnimations];
    
     [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    
    v_avGL.hidden = NO;
    
}

-(void)turnToRight
{
    //设置状态栏旋转
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //设置旋转动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    //    self.navigationController.navigationBar.transform = CGAffineTransformMakeRotation(M_PI*1.5);
    self.view.transform = CGAffineTransformMakeRotation(M_PI*1.5);
    [UIView commitAnimations];
    
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    
    v_avGL.hidden = NO;
    
}

-(void)turnToDown
{
    //设置状态栏旋转
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown animated:YES];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //设置旋转动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
//    self.navigationController.navigationBar.transform = CGAffineTransformMakeRotation(0);
    self.view.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
    
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    v_avGL.hidden = YES;
}
#pragma mark
-(void)setPlayWithTime:(NSDate *)time_t playFig:(BOOL)fig
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *time_s = [formatter stringFromDate:time_t];
    lb_date.text = [time_s substringToIndex:10];
    int tag = [[time_s substringWithRange:NSMakeRange(11, 2)] intValue];
    
    for (int i = 0; i < ar_coverView.count; i++) {
        UILabel *lb_t = [ar_coverView objectAtIndex:i];
        lb_t.hidden = NO;
        if (i == tag) {
            lb_t.hidden = YES;
            lb_start_time.text = [NSString stringWithFormat:@"%02d:00:00", i];
            lb_end_time.text = [NSString stringWithFormat:@"%02d:00:00", i + 1];
            int vaule_m = [[time_s substringWithRange:NSMakeRange(14, 2)] intValue];
            int vaule_s = [[time_s substringFromIndex:17] intValue];
            slider_time.value = vaule_m * 60 + vaule_s;
        }
    }
    
    playFig = fig;
    [self showBottomView:!fig];
}

-(NSDate *)getPalyTime
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *time_s = [NSString stringWithFormat:@"%@ %@:%@", lb_date.text, [lb_start_time.text substringToIndex:2], btn_sliderNowTime.titleLabel.text];
    NSDate *time_d = [formatter dateFromString:time_s];
    return time_d;
}

-(BOOL)getPlayFig
{
    return playFig;
}

#pragma mark - NSTimer
-(void)updateVideoNowkTime:(id)sender
{
    if (mint >= 60) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *time_now_t = [formatter stringFromDate:[NSDate date]];
        NSArray *ar_time = [time_now_t componentsSeparatedByString:@" "];
        lb_date.text = [ar_time objectAtIndex:0];
        lb_time.text = [ar_time objectAtIndex:1];
        mint = 0;
    }else{
        mint++;
    }
    
    [hud_getImag hide:YES];
    hud_getImag.hidden = YES;
    hud_getImag = nil;
    
//    [HUD hide:YES];
//    HUD.hidden = YES;
//    HUD = nil;
    
    float time_t = [self updateVideoPlayTime];
    if (nowPlayTime != time_t) {
        nowPlayTime = time_t;
        playPausedNum = 0;
    }else{
        time_t = nowPlayTime;
    }
        
    if(playPausedNum >= 10){
        playPausedNum = 0;
        FFmpegNotice *ffNotice = [[FFmpegNotice alloc] init];
        ffNotice.playStatus = ffmpeg_playFail;
        ffNotice.message    = @"10s未等到媒体数据";
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        [self stopStreaming];
        
    }else{
        playPausedNum++;
    }
    
    if (ffmpeg_decode != nil && pType == SNPlayTypeRebroadcast) {
        //
        [slider_time setValue:time_t animated:YES];
        btn_sliderNowTime.center = CGPointMake((slider_time.frame.size.width / slider_time.maximumValue) * (0.95 * time_t) + 70, btn_sliderNowTime.center.y);
        int minute = (int)time_t / 60;
        int sec = (int)time_t % 60;
        [btn_sliderNowTime setTitle:[NSString stringWithFormat:@"%02d:%02d", minute, sec] forState:UIControlStateNormal];
    }
}

#pragma mark - button Action
-(void)downButtonAction:(UIButton *)Btn
{
    [self turnToDown];
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_EXIT_FULL_SCREEN object:nil];
}

-(void)screenshotButtonAction:(UIButton *)btn
{
    [ffmpeg_decode getImageStar];
}

-(void)recordButtonAction:(UIButton *)btn
{
    
}

-(void)friendButtonAction:(UIButton *)btn
{
    
}

-(float)updateVideoPlayTime
{

    return [ffmpeg_decode getPlayOfNowTime];
}

-(void)timeImageAction:(UIButton *)btn
{
    
    for (int i = 0; i < ar_coverView.count; i++) {
        UILabel *lb_t = [ar_coverView objectAtIndex:i];
        lb_t.hidden = NO;
        if (i == btn.tag) {
            lb_t.hidden = YES;
            lb_start_time.text = [NSString stringWithFormat:@"%02d:00:00", i];
            lb_end_time.text = [NSString stringWithFormat:@"%02d:00:00", i + 1];
   
            if (ffmpeg_decode != nil) {
                [self stopStreaming];
                NSString *sURL = [self getURL];
                [self openFileWithURL:sURL];
                slider_time.value = 0;
            }
        }
    }
    
}

- (void)selectTimeAction:(UIButton *)btn
{
//    Dlog(@"===00==");
    [UIView animateWithDuration:0.2 animations:^{
        v_datePicker.frame = CGRectMake(0, v_avGL.frame.size.height - 192, v_avGL.frame.size.width, 192);
    }];
}

- (void)datePickerDownButtonAction:(UIButton *)btn
{
//    Dlog(@"00999999==");
    [UIView animateWithDuration:0.2 animations:^{
        v_datePicker.frame = CGRectMake(0, v_avGL.frame.size.height, v_avGL.frame.size.width, 192);
    }];
}

- (void)backgroundButtonAction:(UIButton *)btn
{
    Dlog(@"====");
    if (playFig) {
        [self pauseStreaming];
        [self showBottomView:YES];
    }else{
        [self playStreaming];
        [self showBottomView:NO];
    }
}

- (void)showBottomView:(BOOL)fig
{
    if (fig) {
        [UIView animateWithDuration:0.2 animations:^{
            v_bottm_redroadcast.frame = CGRectMake(0, self.view.frame.size.width - 70, v_bottm_redroadcast.frame.size.width, v_bottm_redroadcast.frame.size.height);
            btn_sliderNowTime.frame = CGRectMake(55, v_bottm_redroadcast.frame.origin.y - 25, btn_sliderNowTime.frame.size.width, btn_sliderNowTime.frame.size.height);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            v_bottm_redroadcast.frame = CGRectMake(0, self.view.frame.size.width - 30, v_bottm_redroadcast.frame.size.width, v_bottm_redroadcast.frame.size.height);
            btn_sliderNowTime.frame = CGRectMake(55, v_bottm_redroadcast.frame.origin.y - 25, btn_sliderNowTime.frame.size.width, btn_sliderNowTime.frame.size.height);
        }];
    }
}

#pragma mark - datePicker action

- (void)datePickerChangeVaule:(UIDatePicker *)dp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy/MM/dd"];
    lb_date.text = [formatter stringFromDate:dp.date];
}

#pragma mark - slider action
-(void)sliderChangeVaule:(UISlider *)sl
{
    btn_sliderNowTime.center = CGPointMake((slider_time.frame.size.width / slider_time.maximumValue) * (0.95 * slider_time.value) + 70, btn_sliderNowTime.center.y);
    int minute = (int)slider_time.value / 60;
    int sec = (int)slider_time.value % 60;
    [btn_sliderNowTime setTitle:[NSString stringWithFormat:@"%02d:%02d", minute, sec] forState:UIControlStateNormal];
}

-(void)sliderTouchDown:(UISlider *)sl
{
    if (ffmpeg_decode != nil) {
        [self goToPlayWithTime:slider_time.value];
    }
}

#pragma mark - Display GLView
- (void)setupGL
{
    
    [EAGLContext setCurrentContext:self.context];
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices_video), Vertices_video, GL_STATIC_DRAW);
    
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices_video), Indices_video, GL_STATIC_DRAW);
    
    // init the update render semaphore
    textureUpdateRenderSemaphore = dispatch_semaphore_create((long)1);
    
}

#pragma mark - texture setup

- (void) updateTexture: (NSData*)textureData width:(uint) width height:(uint) height textureIndex:(GLuint)index
{
    long renderStatus = dispatch_semaphore_wait(textureUpdateRenderSemaphore, DISPATCH_TIME_NOW);
    if (renderStatus==0){
        GLubyte *glTextureData;
        if (textureData){
            glTextureData = (GLubyte*)(textureData.bytes);
        }else{
            glTextureData = (GLubyte *) malloc(width*height);
            memset(glTextureData, 0, width*height);
        }
        glActiveTexture(GL_TEXTURE0+index);
        glBindTexture(GL_TEXTURE_2D, index);//////////////////////特别 处理
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, glTextureData);
        
        if (!textureData){
            free(glTextureData);
        }
        dispatch_semaphore_signal(textureUpdateRenderSemaphore);
    }
}

- (GLuint)setupTexture:(NSData *)textureData width:(uint) width height:(uint) height textureIndex:(GLuint) index
{
    GLuint texName;
    
    glGenTextures(1, &texName);
    glActiveTexture(GL_TEXTURE0+index);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    [self updateTexture:textureData width:width height:height textureIndex:index];
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    return texName;
}

#pragma mark - compile and load shaders

- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType
{
    GLuint shaderHandle = glCreateShader(shaderType);
    if (shaderHandle == 0 || shaderHandle == GL_INVALID_ENUM) {
        NSLog(@"Failed to create shader %d", shaderType);
        exit(1);
    }
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void) compileShaders
{
    GLuint vertexShader = [self compileShader:vertexShaderString_video
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:rgbFragmentShaderString_video
                                       withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    positionSlot = glGetAttribLocation(programHandle, "Position");
    colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(positionSlot);
    glEnableVertexAttribArray(colorSlot);
    
    // set the shader slots
    texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    glEnableVertexAttribArray(texCoordSlot);
    yTextureUniform = glGetUniformLocation(programHandle, "s_texture_y");
    uTextureUniform = glGetUniformLocation(programHandle, "s_texture_u");
    vTextureUniform = glGetUniformLocation(programHandle, "s_texture_v");
    yTexture = 0;
    uTexture = 0;
    vTexture = 0;
}

#pragma mark - render code
- (void) setGLViewportToScale
{
    CGFloat scaleFactor = [[UIScreen mainScreen] scale];
    if (textureHeight!=0 && textureWidth!=0){
//        float targetRatio = textureWidth/(textureHeight*1.0);//横比例
//        float viewRatio = self.view.bounds.size.width/(self.view.bounds.size.height*1.0);//纵比例
        uint16_t x,y,width,height;
//        if (targetRatio>viewRatio){
//            width=self.view.bounds.size.width*scaleFactor;
//            height=width/targetRatio;
//            x=0;
//            y=(self.view.bounds.size.height*scaleFactor-height)/2;
//            
//        }else{
//            height=self.view.bounds.size.height*scaleFactor;
//            width = height*targetRatio;
//            y=0;
//            x=(self.view.bounds.size.width*scaleFactor-width)/2;
//        }
        x = y = 0;
        width=self.view.bounds.size.width*scaleFactor;
        height=self.view.bounds.size.height*scaleFactor;
        glViewport(x ,y,width,height);
    }else{
        glViewport(self.view.bounds.origin.x, self.view.bounds.origin.y,
                   self.view.bounds.size.width*scaleFactor, self.view.bounds.size.height*scaleFactor);
    }
    
}

- (void)render
{
    [EAGLContext setCurrentContext:self.context];
    
    [self setGLViewportToScale];
    
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex_video), 0);
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex_video), (GLvoid*) (sizeof(float) * 3));
    
    // load the texture
    glVertexAttribPointer(texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex_video), (GLvoid*) (sizeof(float) * 7));
    
    //    glActiveTexture(GL_TEXTURE0);
    //    glBindTexture(GL_TEXTURE_2D, _yTexture);
    glUniform1i(yTextureUniform, 0);
    
    //    glActiveTexture(GL_TEXTURE0+1);
    //    glBindTexture(GL_TEXTURE_2D, _uTexture);
    glUniform1i(uTextureUniform, 1);
    
    //    glActiveTexture(GL_TEXTURE0+2);
    //    glBindTexture(GL_TEXTURE_2D, _vTexture);
    glUniform1i(vTextureUniform, 2);
    
    // draw
    glDrawElements(GL_TRIANGLES, sizeof(Indices_video)/sizeof(Indices_video[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    
}


#pragma mark - loading the texture data

- (int) loadFrameData:(AVFrameData *)frameData
{
    if (frameData && self.context){
        
        
        [EAGLContext setCurrentContext:self.context];
        
        if (yTexture && uTexture && vTexture){
            [self updateTexture:frameData.colorPlane0 width:frameData.width.intValue height:frameData.height.intValue textureIndex:0];
            [self updateTexture:frameData.colorPlane1 width:frameData.width.intValue/2 height:frameData.height.intValue/2 textureIndex:1];
            [self updateTexture:frameData.colorPlane2 width:frameData.width.intValue/2 height:frameData.height.intValue/2 textureIndex:2];
            textureWidth = frameData.width.intValue;
            textureHeight = frameData.height.intValue;
        }
        return 0;
    }else{
        return -1;
    }
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    long textureUpdateStatus = dispatch_semaphore_wait(textureUpdateRenderSemaphore, DISPATCH_TIME_NOW);
    if (textureUpdateStatus==0){
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self render];
        dispatch_semaphore_signal(textureUpdateRenderSemaphore);
    }
}

#pragma mark - GLKViewControllerDelegate

- (void) update
{
    if (increasing) {
        curRed += 1.0 * self.timeSinceLastUpdate;
    } else {
        curRed -= 1.0 * self.timeSinceLastUpdate;
    }
    if (curRed >= 1.0) {
        curRed = 1.0;
        increasing = NO;
    }
    if (curRed <= 0.0) {
        curRed = 0.0;
        increasing = YES;
    }
    
    
    [self.view bringSubviewToFront:v_avGL];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    self.paused = !self.paused;
//    shouldHideMaster=!shouldHideMaster;
//    [self.splitViewController willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
//    [self.splitViewController.view setNeedsLayout];
    FFmpegNotice *ffNotice = [[FFmpegNotice alloc] init];
    ffNotice.playStatus = ffmpeg_touchBackground;
    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
}

-(BOOL) shouldHideMaster
{
    return shouldHideMaster;
}

#pragma mark - ffmpeg init
-(FFmpegDecod *)ffmpegInit
{
    if (!ffmpeg_decode){
        ffmpeg_decode = [[FFmpegDecod alloc] init];
    }
    return ffmpeg_decode;
}

- (void) setFFmpegDec:(FFmpegDecod *)fdec
{
    if (ffmpeg_decode != fdec){
        [ffmpeg_decode stopDecode];  // send the stop decode message to the decoder so it will not wait forever
        ffmpeg_decode = fdec;
    }
}

//- (CameraFinder*) fCameraFinder
//{
//    if (!self.cameraFinder){
//        self.cameraFinder = [[CameraFinder alloc] init];
//    }
//    return self.cameraFinder;
//}

- (NSArray *) ipcamList
{
    if (!self.ipcamList){
        self.ipcamList = [[NSArray alloc] init];
    }
    return self.ipcamList;
}

- (BOOL)getOpenFig
{
    if (ffmpeg_decode == nil) {
        return NO;
    }else{
        return YES;
    }
}

- (void)openFileWithURL:(NSString *)url
{
    sAV_URL = url;
    
    [self stopStreaming];
    
    [self startStreaming];
}

- (BOOL)startStreaming
{
    BOOL isSuc = NO;
    playFig = YES;
    
    [self ffmpegInit];
    
    isSuc = [ffmpeg_decode openUrl:sAV_URL];
    
    if (isSuc == YES){
        
       /* audio_queue = [[AudioQueue alloc] initWith:ffmpeg_decode];
        [audio_queue startAudio];
        */
        
        [ffmpeg_decode startDecodingWithCallbackBlock:^(AVFrameData *frame) {
            
            [self loadFrameData:frame];
            
        } waitForConsumer:YES completionCallback:^{
            NSLog(@"decode complete.");
            
        }];
    }else{
        
        ffmpeg_decode = nil;
    }
    
    if (timer_Now == nil) {
        timer_Now                   = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                       target:self selector:@selector(updateVideoNowkTime:) userInfo:nil repeats:YES];
    }
    
    return isSuc;
}

- (void)stopStreaming
{
//    [HUD hide:NO];
    playFig = NO;
    
    [ffmpeg_decode stopDecode];
    ffmpeg_decode = nil;
    [timer_Now invalidate];
    timer_Now = nil;
//    [audio_queue stopAudio];
//    audio_queue = nil;
}

- (BOOL)playStreaming
{
    if (ffmpeg_decode) {
        
//        [audio_queue startAudio];
        playFig = YES;
        
        [ffmpeg_decode startDecodingWithCallbackBlock:^(AVFrameData *frame) {
            [self loadFrameData:frame];
        } waitForConsumer:YES completionCallback:^{
            NSLog(@"play decode complete.");
        }];
        
        return YES;
    }else{
        
        BOOL isSuc = [self startStreaming];
        if (isSuc == NO) {
            ffmpeg_decode = nil;
        }
        return isSuc;
    }
    
}

- (void)pauseStreaming
{
    playFig = NO;
    if (ffmpeg_decode) {
        [ffmpeg_decode stopDecode];
    }
}

- (void)getImageStart
{
    if (ffmpeg_decode) {
        [ffmpeg_decode getImageStar];
    }
}

- (void)goToPlayWithTime:(int)second
{
    nowPlayTime = second;
    if (ffmpeg_decode) {
        [ffmpeg_decode goToPalyWithTime:second];
    }
    
}

#pragma mark - get image Action

- (void)getImageNotification:(NSNotification *)obj
{
    AVFrameData *frameData = [obj object];
   // UIImage *image = [ffmpeg_decode convertFramToImage:ffmpeg_decode.codecCtx_video frma:ffmpeg_decode.frame_video];
    UIImage *image = [ffmpeg_decode convertFrameDataToImage:frameData];
    //保存到手机相册
//    UIImageWriteToSavedPhotosAlbum(image,nil, @selector(errorCheck:didFinishSavingWithError:contextInfo:),nil);
    //保存到本地文件夹
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy.MM.dd"];
    NSDate *time_d = [NSDate date];
    NSString *time_t = [formatter stringFromDate:time_d];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init] ;
    [formatter1 setDateFormat:@"yyyyMMddHHmmSS"];
    NSString *time_t2 = [formatter1 stringFromDate:time_d];
    NSString *name = [NSString stringWithFormat:@"%@%@.png", time_t2, user.sUserId];
//    NSString *saPath = [[HDFileUtility instance] saveImag:image imagName:name];
    NSString *saPath = [HDUtility pathOfSavedImageName:name folderName:@FOLDER_DEVICE];
    BOOL saveFig = [HDUtility saveToDocument:image withFilePath:saPath];
    if (saveFig) {
        SNPhotoInfo *pInfo = [[SNPhotoInfo alloc] init];
        pInfo.pType = SNPhotoPicture;
        pInfo.photoName = name;
        pInfo.photoPath = saPath;
        pInfo.takeDeviceID = sDeviceID;
        pInfo.takeTime = time_t;
        [HDUtility savePhotoInfo:pInfo];
        
        if (hud_getImag != nil) {
            [hud_getImag hide:YES];
            hud_getImag.hidden = YES;
            hud_getImag = nil;
        }
        hud_getImag = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud_getImag.mode = MBProgressHUDModeText;
        hud_getImag.labelText = @"截图成功";
        hud_getImag.margin = 10.f;
        hud_getImag.removeFromSuperViewOnHide = YES;
    }
}

- (void)errorCheck:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	NSString *informText;
	
	if(error)
		informText = [error localizedDescription];
	else
	{
		informText = @"Finished!";
	}
	
    NSLog(@"===%@", informText);
}

#pragma mark CameraFinder delegate

-(void) processCameraList:(NSArray *)cameraList
{
    /* self.ipcamList = [[NSArray alloc] initWithArray:cameraList];
     [self.macAddressPickerView reloadAllComponents];
     if (!self.currentCameraIP){
     NSInteger currentCameraRow = [self.macAddressPickerView selectedRowInComponent:0];
     NSInteger currentChRow = [self.macAddressPickerView selectedRowInComponent:1];
     NSString *cameraIP = [[self.ipcamList objectAtIndex:currentCameraRow] objectForKey:@"address"];
     self.currentCameraIP = [[NSString alloc] initWithString:cameraIP];
     self.currentCameraCh = [NSString stringWithFormat:@"%d", currentChRow];
     [self updateCurrentUrl];
     }
     */
}

@end
