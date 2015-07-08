//
//  FFmpegDecod.h
//  THTest
//
//  Created by Thinking on 14-8-27.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "libavcodec/avcodec.h"
#import "libavformat/avformat.h"
#import "libswscale/swscale.h"
#import "libavcodec/avfft.h"

#define NSNOTICE_FFMPEG_PLAYSTATUS "NSNoctice_ffmpeg_playStatus"

typedef NS_ENUM(int, SNFFmpegPlayStatus) {
    ffmpeg_initSuccess = 0,         //初始化成功
    ffmpeg_initFail,                //初始化失败
    ffmpeg_openVideoSuccess,        //打开视频成功
    ffmpeg_openVideoFail,           //打开视频失败
    ffmpeg_cushioning,              //缓冲准备播放
    ffmpeg_playStart,               //开始播放
    ffmpeg_playPause,               //暂停播放
    ffmpeg_playStop,                //停止播放
    ffmpeg_playFail,                //播放异常
    ffmpeg_touchBackground,         //点击播放背景
    
};

@interface FFmpegNotice : NSObject

@property (nonatomic, assign) SNFFmpegPlayStatus playStatus;
@property (nonatomic, strong) NSString           *message;

@end

@interface AVFrameData : NSObject

@property (nonatomic, strong) NSMutableData *colorPlane0;
@property (nonatomic, strong) NSMutableData *colorPlane1;
@property (nonatomic, strong) NSMutableData *colorPlane2;
@property (nonatomic, strong) NSNumber      *lineSize0;
@property (nonatomic, strong) NSNumber      *lineSize1;
@property (nonatomic, strong) NSNumber      *lineSize2;
@property (nonatomic, strong) NSNumber      *width;
@property (nonatomic, strong) NSNumber      *height;
@property (nonatomic, strong) NSDate        *presentationTime;

@end

#define imgeNotificatio @"getImageFromAV"


@interface FFmpegDecod : NSObject

@property (nonatomic, assign) AVCodecContext *codecCtx_video;
@property (nonatomic, assign) AVFrame *frame_video;

@property AVCodecContext *codecCtx_audio;
@property int16_t *buffer_audio;


-(id) init;

-(BOOL)openUrl:(NSString *)url;

- (void)getImageStar;

-(int) startDecodingWithCallbackBlock: (void (^) (AVFrameData *frame)) frameCallbackBlock  waitForConsumer: (BOOL) wait completionCallback: (void (^)()) completion;

-(void) stopDecode;

- (NSTimeInterval)getPlayTime;
- (NSTimeInterval)duration;
- (float)getPlayOfNowTime;

- (NSInteger)getBufferSize;

- (void)nextPacket;

- (void)goToPalyWithTime:(NSTimeInterval)seconds;

-(UIImage *)convertFramToImage: (AVCodecContext *) avFrameContext frma:(AVFrame *)frame_;

-(UIImage *) convertFrameDataToImage: (AVFrameData *) avFrameData;

@end
