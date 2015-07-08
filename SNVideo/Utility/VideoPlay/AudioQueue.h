//
//  audioQueue.h
//  THTest
//
//  Created by Thinking on 14-8-28.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FFmpegDecod.h"

#define kNumAQBufs 3
#define kAudioBufferSeconds 3

typedef enum _AUDIO_QUEUE_STATE {
    AUDIO_QUEUE_STATE_READY           = 0,
    AUDIO_QUEUE_STATE_STOP            = 1,
    AUDIO_QUEUE_STATE_PLAYING         = 2,
    AUDIO_QUEUE_STATE_PAUSE           = 3,
    AUDIO_QUEUE_STATE_SEEKING         = 4
} AUDIO_QUEUE_STATE;


@interface AudioQueue : NSObject


@property (nonatomic, assign)NSInteger state;

- (id)initWith:(FFmpegDecod *)fDecod;

- (void)startAudio;
- (void)stopAudio;
- (void)timeOutAudio;

- (BOOL)createAudioQueue;
- (void)removeAudioQueue;

- (void)audioQueueOutputCallback_:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer;
- (void)audioQueueIsRunningCallback_;

- (OSStatus)enqueueBuffer:(AudioQueueBufferRef)buffer;
- (OSStatus)startQueue;

@end
