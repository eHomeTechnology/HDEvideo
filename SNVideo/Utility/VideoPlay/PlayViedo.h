//
//  playViedo.h
//  THTest
//
//  Created by Thinking on 14-8-26.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "FFmpegDecod.h"

typedef NS_ENUM(int, SNPlayType) {
    SNPlayTypeLiveTelecast = 0, //直播
    SNPlayTypeRebroadcast,    //重播
};

@interface PlayViedo : GLKViewController
{
    
}

- (id)initWithURL:(NSString *)url deviceInfo:(SNCameraInfo *)dInfo type:(SNPlayType)typ;
-(void)initFatherView:(UIView *)fView;

- (void)openFileWithURL:(NSString *)url;
- (BOOL)getOpenFig;

- (void)stopStreaming;
- (BOOL)playStreaming;
- (void)pauseStreaming;
- (void)getImageStart;
- (void)goToPlayWithTime:(int)second;
-(float)updateVideoPlayTime;

-(void)turnToDown;
-(void)turnToLeft;
-(void)turnToRight;
-(void)screenshotButtonAction:(UIButton *)btn;

-(void)setPlayWithTime:(NSDate *)time_t playFig:(BOOL)fig;
-(NSDate *)getPalyTime;
-(BOOL)getPlayFig;

@end
