//
//  audioQueue.m
//  THTest
//
//  Created by Thinking on 14-8-28.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "AudioQueue.h"

@interface AudioQueue()
{
    NSString *playingFilePath;
    AudioStreamBasicDescription audioStreamBasicDesc;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];
    BOOL started, finished;
    NSTimeInterval durationTime, startedTime;
    NSInteger _state;
    NSTimer *seekTimer;
    NSLock *decodeLock;
    
    FFmpegDecod *ffDecod;
}

@end

void audioQueueOutputCallback_(void *inClientData, AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer);
void audioQueueIsRunningCallback_(void *inClientData, AudioQueueRef inAQ,
                                 AudioQueuePropertyID inID);

void audioQueueOutputCallback_(void *inClientData, AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer) {
    
    AudioQueue *play_obj = (__bridge AudioQueue*)inClientData;
    [play_obj audioQueueOutputCallback_:inAQ inBuffer:inBuffer];
}

void audioQueueIsRunningCallback_(void *inClientData, AudioQueueRef inAQ,
                                 AudioQueuePropertyID inID) {
    
    AudioQueue *play_obj = (__bridge AudioQueue*)inClientData;
    [play_obj audioQueueIsRunningCallback_];
}

@implementation AudioQueue

- (id)initWith:(FFmpegDecod *)fDecod
{
    if (self = [super init]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        ffDecod = fDecod;
    }
    
    return self;
}

- (void)startAudio
{
    if (started) {
        AudioQueueStart(audioQueue, NULL);
    }
    else {
        
        if (![self createAudioQueue]) {
            //        abort();
            return ;
        }
        [self startQueue];
        
        seekTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self selector:@selector(updatePlaybackTime:) userInfo:nil repeats:YES];
    }
    
    for (NSInteger i = 0; i < kNumAQBufs; ++i) {
        [self enqueueBuffer:audioQueueBuffer[i]];
    }
    
    _state = AUDIO_QUEUE_STATE_PLAYING;
}

- (void)stopAudio
{
    if (started) {
        AudioQueueStop(audioQueue, YES);
        startedTime = 0.0;
        
        _state = AUDIO_QUEUE_STATE_STOP;
        finished = NO;
    }
}

- (void)timeOutAudio
{
    if (started) {
        _state = AUDIO_QUEUE_STATE_PAUSE;
        
        AudioQueuePause(audioQueue);
        AudioQueueReset(audioQueue);
    }
}

- (BOOL)createAudioQueue{
    _state = AUDIO_QUEUE_STATE_READY;
    finished = NO;
    
    decodeLock = [[NSLock alloc] init];
    
    // 16bit PCM LE.
    audioStreamBasicDesc.mFormatID = kAudioFormatLinearPCM;
    audioStreamBasicDesc.mSampleRate = ffDecod.codecCtx_audio->sample_rate;
    audioStreamBasicDesc.mBitsPerChannel = 16;
    audioStreamBasicDesc.mChannelsPerFrame = ffDecod.codecCtx_audio->channels;
    audioStreamBasicDesc.mFramesPerPacket = 1;
    audioStreamBasicDesc.mBytesPerFrame = audioStreamBasicDesc.mBitsPerChannel / 8
    *audioStreamBasicDesc.mChannelsPerFrame;
    audioStreamBasicDesc.mBytesPerPacket = audioStreamBasicDesc.mBytesPerFrame * audioStreamBasicDesc.mFramesPerPacket;
    audioStreamBasicDesc.mReserved = 0;
    audioStreamBasicDesc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    
    durationTime = [ffDecod duration];
    dispatch_async(dispatch_get_main_queue(), ^{
        //        SInt64 time = floor(durationTime_);
        //        seekLabel_.text = [NSString stringWithFormat:@"0 / %02llu:%02llu:%02llu",
        //                           ((time / 60) / 60), (time / 60), (time % 60)];
        //
        //        seekSlider_.maximumValue = durationTime_;
    });
    
    
    OSStatus status = AudioQueueNewOutput(&audioStreamBasicDesc, audioQueueOutputCallback_, (__bridge void*)self,
                                          NULL, NULL, 0, &audioQueue);
    if (status != noErr) {
        NSLog(@"Could not create new output.");
        return NO;
    }
    
    status = AudioQueueAddPropertyListener(audioQueue, kAudioQueueProperty_IsRunning,
                                           audioQueueIsRunningCallback_, (__bridge void*)self);
    if (status != noErr) {
        NSLog(@"Could not add propery listener. (kAudioQueueProperty_IsRunning)");
        return NO;
    }
    
    
    //    [ffmpegDecoder_ seekTime:10.0];
    
    for (NSInteger i = 0; i < kNumAQBufs; ++i) {
        status = AudioQueueAllocateBufferWithPacketDescriptions(audioQueue, ffDecod.codecCtx_audio->bit_rate * kAudioBufferSeconds / 8, ffDecod.codecCtx_audio->sample_rate * kAudioBufferSeconds / ffDecod.codecCtx_audio->frame_size + 1, audioQueueBuffer + i);
        if (status != noErr) {
            NSLog(@"Could not allocate buffer.");
            return NO;
        }
    }
    
    return YES;
}

- (void)removeAudioQueue {
    [self stopAudio];
    started = NO;
    
    for (NSInteger i = 0; i < kNumAQBufs; ++i) {
        AudioQueueFreeBuffer(audioQueue, audioQueueBuffer[i]);
    }
    AudioQueueDispose(audioQueue, YES);
}

#pragma mark - view

- (void)updatePlaybackTime:(NSTimer*)timer {
    AudioTimeStamp timeStamp;
    OSStatus status = AudioQueueGetCurrentTime(audioQueue, NULL, &timeStamp, NULL);
    
    if (status == noErr) {
        SInt64 time = floor(durationTime);
        NSTimeInterval currentTimeInterval = timeStamp.mSampleTime / audioStreamBasicDesc.mSampleRate;
        SInt64 currentTime = floor(startedTime + currentTimeInterval);
        
        NSString *time_kkk = [NSString stringWithFormat:@"%02llu:%02llu:%02llu / %02llu:%02llu:%02llu", ((currentTime / 60) / 60), (currentTime / 60), (currentTime % 60), ((time / 60) / 60), (time / 60), (time % 60)];
        NSLog(@"===%@", time_kkk);
        //        seekLabel_.text = [NSString stringWithFormat:@"%02llu:%02llu:%02llu / %02llu:%02llu:%02llu", ((currentTime / 60) / 60), (currentTime / 60), (currentTime % 60), ((time / 60) / 60), (time / 60), (time % 60)];
        //
        //        seekSlider_.value = startedTime_ + currentTimeInterval;
    }
}

#pragma mark - queue
- (OSStatus)enqueueBuffer:(AudioQueueBufferRef)buffer {
    OSStatus status = noErr;
    NSInteger decodedDataSize = 0;
    buffer->mAudioDataByteSize = 0;
    buffer->mPacketDescriptionCount = 0;
    
    [decodeLock lock];
    
    while (buffer->mPacketDescriptionCount < buffer->mPacketDescriptionCapacity) {
        decodedDataSize = [ffDecod getBufferSize];
        
        if (decodedDataSize && buffer->mAudioDataBytesCapacity - buffer->mAudioDataByteSize >= decodedDataSize) {
            memcpy(buffer->mAudioData + buffer->mAudioDataByteSize,
                   ffDecod.buffer_audio, decodedDataSize);
            
            buffer->mPacketDescriptions[buffer->mPacketDescriptionCount].mStartOffset = buffer->mAudioDataByteSize;
            buffer->mPacketDescriptions[buffer->mPacketDescriptionCount].mDataByteSize = (UInt32)decodedDataSize;
            buffer->mPacketDescriptions[buffer->mPacketDescriptionCount].mVariableFramesInPacket =
            audioStreamBasicDesc.mFramesPerPacket;
            
            buffer->mAudioDataByteSize += decodedDataSize;
            buffer->mPacketDescriptionCount++;
            [ffDecod nextPacket];
        }
        else {
            break;
        }
    }
    
    
    if (buffer->mPacketDescriptionCount > 0) {
        status = AudioQueueEnqueueBuffer(audioQueue, buffer, 0, NULL);
        if (status != noErr) {
            NSLog(@"Could not enqueue buffer.");
        }
    }
    else {
        AudioQueueStop(audioQueue, NO);
        finished = YES;
    }
    
    [decodeLock unlock];
    
    return status;
}

- (OSStatus)startQueue {
    OSStatus status = noErr;
    
    if (!started) {
        status = AudioQueueStart(audioQueue, NULL);
        if (status == noErr) {
            started = YES;
        }
        else {
            NSLog(@"Could not start audio queue.");
        }
    }
    
    return status;
}


#pragma mark - 回调
- (void)audioQueueOutputCallback_:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer
{
    if (_state == AUDIO_QUEUE_STATE_PLAYING) {
        [self enqueueBuffer:inBuffer];
    }
}

- (void)audioQueueIsRunningCallback_
{
    UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
    OSStatus status = AudioQueueGetProperty(audioQueue, kAudioQueueProperty_IsRunning, &isRunning, &size);
    
    if (status == noErr && !isRunning && _state == AUDIO_QUEUE_STATE_PLAYING) {
        _state = AUDIO_QUEUE_STATE_STOP;
        
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //                SInt64 time = floor(durationTime);
                //                seekLabel.text = [NSString stringWithFormat:@"%02llu:%02llu:%02llu / %02llu:%02llu:%02llu",
                //                                   ((time / 60) / 60), (time / 60), (time % 60),
                //                                   ((time / 60) / 60), (time / 60), (time % 60)];
            });
        }
    }
}

@end
