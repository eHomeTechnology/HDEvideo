//
//  FFmpegDecod.m
//  THTest
//
//  Created by Thinking on 14-8-27.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "FFmpegDecod.h"
#include <libkern/OSAtomic.h>
#import "UIImageExtensions.h"

#define AV_NUM_DATA_POINTERS 8

#define ALL_DEBUG

#ifdef ALL_DEBUG
#define AV_DEBUG
#define AUDIO_DEBUG
#endif

#define MIN_FRAME_INTERVAL 0.005
#define AVCODEC_MAX_AUDIO_FRAME_SIZE  192000// (0x10000)/4
#define SAFE_SEEK_SECONDS 24*60*60

@implementation AVFrameData
@synthesize colorPlane0         = _colorPlane0;
@synthesize colorPlane1         = _colorPlane1;
@synthesize colorPlane2         = _colorPlane2;
@synthesize lineSize0           = _lineSize0;
@synthesize lineSize1           = _lineSize1;
@synthesize lineSize2           = _lineSize2;
@synthesize width               = _width;
@synthesize height              = _height;
@synthesize presentationTime    = _presentationTime;

@end

@implementation FFmpegNotice

@synthesize playStatus = _playStatus;
@synthesize message    = _message;

@end

@interface FFmpegDecod()
{
    AVFormatContext *formatCtx;
    AVCodecContext  *_codecCtx_video;
    AVCodec         *codec_video;
    AVFrame         *_frame_video;
    AVPacket        packet_video;
    AVDictionary    *optionsDict_video;
    int             videoStreamIndex;
    CFTimeInterval  previousDecodedFrameTime_video;
    BOOL            isGetImag;
    BOOL            isSeek;
    volatile bool   stopDecode;
    int             seekTime;
    
    //audio
    AVCodecContext  *_codecCtx_audio;
    AVStream        *stream_audio;
    AVPacket        packet_audio, currentPacket_audio;
    
    NSString        *inputFilePath_audio;
    NSInteger       audioStreamIndex, decodedDataSize_audio;
    int16_t         *_buffer_audio;
    NSUInteger      bufferSize_audio;
    BOOL            inBuffer_audio;
    float           Stream_nowTime;
    BOOL            playFig;
}

@end

@implementation FFmpegDecod

-(id) init
{
    self=[super init];
    // initialize all instance variables
    formatCtx           = NULL;
    _codecCtx_video     = NULL;
    codec_video         = NULL;
    _frame_video        = NULL;
    optionsDict_video   = NULL;
    isGetImag           = NO;
    isSeek              = NO;
    Stream_nowTime      = 0.0f;
    playFig             = NO;
    
    // register av
    av_register_all();
    avformat_network_init();
    
    // set memory barrier
    OSMemoryBarrier();
    stopDecode = false;
    previousDecodedFrameTime_video = 0;
    
    //audio
    bufferSize_audio    = AVCODEC_MAX_AUDIO_FRAME_SIZE;
    _buffer_audio       = av_malloc(bufferSize_audio);
    av_init_packet(&packet_audio);
    inBuffer_audio      = NO;
    
    FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
    ffNotice.playStatus     = ffmpeg_initSuccess;
    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
    
    return self;
}

-(BOOL)openUrl:(NSString *)url
{
    if (formatCtx != NULL || codec_video != NULL){
        
        FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
        ffNotice.playStatus     = ffmpeg_openVideoFail;
        ffNotice.message        = @"已经被打开了";
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        
        return NO;  //url already opened
    }
    
    // open video stream
    AVDictionary *serverOpt = NULL;
    av_dict_set(&serverOpt, "rtsp_transport", "udp", 0);
    int err_code = 0;
    err_code = avformat_open_input(&formatCtx, [url UTF8String], NULL, &serverOpt);
    if (err_code!=0){
        NSLog(@"error opening stream %d", err_code);
        char buf[1000];
        av_strerror(err_code, buf, 1024);
//        NSLog(@"Couldn't open file %@: %d = (%s)", url, err_code, buf);
        [self dealloc_helper];
        FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
        ffNotice.playStatus     = ffmpeg_openVideoFail;
        ffNotice.message        = [NSString stringWithFormat:@"Couldn't open file %@: %d = (%s)", url, err_code, buf];
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        return NO; // Couldn't open file
    }
    
    // Retrieve stream information
    AVDictionary * options = NULL;
    av_dict_set(&options, "max_delay", "10000", 0);
    
    int avTime = avformat_find_stream_info(formatCtx, &options);
    if(avTime < 0){
        [self dealloc_helper];
        FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
        ffNotice.playStatus     = ffmpeg_openVideoFail;
        ffNotice.message        = @"没有找到可播放的媒体流";
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        return NO; // Couldn't find stream information
    }
    
    // Dump information about file onto standard error
    av_dump_format(formatCtx, 0, [url UTF8String], 0);
    
    // Find the first video stream
    videoStreamIndex = -1;
//    audioStreamIndex = -1;
    
    for(int i = 0; i < formatCtx->nb_streams; i++){
        if(formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStreamIndex = i;
        }/*else if (formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO){
            audioStreamIndex = i;
        }*/
    }
    
    if(videoStreamIndex == -1){
        [self dealloc_helper];
        FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
        ffNotice.playStatus     = ffmpeg_openVideoFail;
        ffNotice.message        = @"没有找到可播放放得视频流";
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        return NO; // Didn't find a video stream
    }
    
    // Get a pointer to the codec context for the video stream
    _codecCtx_video = formatCtx->streams[videoStreamIndex]->codec;
    
    // Find the decoder for the video stream
    codec_video = avcodec_find_decoder(_codecCtx_video->codec_id);
    if(codec_video == NULL) {
        fprintf(stderr, "Unsupported codec!\n");
        [self dealloc_helper];
        
        FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
        ffNotice.playStatus     = ffmpeg_openVideoFail;
        ffNotice.message        = @"没有找到可用的解码器";
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        
        return NO; // Codec not found
    }
    
    // Open codec
    if(avcodec_open2(_codecCtx_video, codec_video, &optionsDict_video)<0){
        [self dealloc_helper];
        FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
        ffNotice.playStatus     = ffmpeg_openVideoFail;
        ffNotice.message        = @"打开视频流失败";
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        return NO; // Could not open codec
    }
    
    // Allocate video frame
    _frame_video = nil;
    _frame_video = av_frame_alloc();
    if (!_frame_video){
        [self dealloc_helper];
        FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
        ffNotice.playStatus     = ffmpeg_openVideoFail;
        ffNotice.message        = @"分配AVFrame空间失败";
        [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
        return NO;  // Could not allocate frame buffer
    }

    //audio
  /*  stream_audio = formatCtx->streams[audioStreamIndex];
    _codecCtx_audio = stream_audio->codec;
   
    AVCodec *codec = avcodec_find_decoder(_codecCtx_audio->codec_id);
    if (codec == NULL) {
        NSLog(@"Not found audio codec.");
        return -4;
    }
    if (avcodec_open2(_codecCtx_audio, codec, NULL) < 0) {
        NSLog(@"Could not open audio codec.");
        return -5;
    }
   */
    inputFilePath_audio = url;
    
    FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
    ffNotice.playStatus     = ffmpeg_openVideoSuccess;
    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
    
    return YES;
}

#pragma mark -  video
-(AVFrameData *) createFrameData: (AVFrame *) frame
                     trimPadding: (BOOL) trim
{
    AVFrameData *frameData = [[AVFrameData alloc] init];
    if (trim){
        frameData.colorPlane0 = [[NSMutableData alloc] init];
        frameData.colorPlane1 = [[NSMutableData alloc] init];
        frameData.colorPlane2 = [[NSMutableData alloc] init];
        for (int i=0; i<frame->height; i++){
            [frameData.colorPlane0 appendBytes:(void*) (frame->data[0]+i*frame->linesize[0])
                                        length:frame->width];
        }
        for (int i=0; i<frame->height/2; i++){
            [frameData.colorPlane1 appendBytes:(void*) (frame->data[1]+i*frame->linesize[1])
                                        length:frame->width/2];
            [frameData.colorPlane2 appendBytes:(void*) (frame->data[2]+i*frame->linesize[2])
                                        length:frame->width/2];
        }
        frameData.lineSize0 = [[NSNumber alloc] initWithInt:frame->width];
        frameData.lineSize1 = [[NSNumber alloc] initWithInt:frame->width/2];
        frameData.lineSize2 = [[NSNumber alloc] initWithInt:frame->width/2];
    }else{
        frameData.colorPlane0 = [[NSMutableData alloc] initWithBytes:frame->data[0] length:frame->linesize[0]*frame->height];
        frameData.colorPlane1 = [[NSMutableData alloc] initWithBytes:frame->data[1] length:frame->linesize[1]*frame->height/2];
        frameData.colorPlane2 = [[NSMutableData alloc] initWithBytes:frame->data[2] length:frame->linesize[2]*frame->height/2];
        frameData.lineSize0 = [[NSNumber alloc] initWithInt:frame->linesize[0]];
        frameData.lineSize1 = [[NSNumber alloc] initWithInt:frame->linesize[1]];
        frameData.lineSize2 = [[NSNumber alloc] initWithInt:frame->linesize[2]];
    }
    frameData.width = [[NSNumber alloc] initWithInt:frame->width];
    frameData.height = [[NSNumber alloc] initWithInt:frame->height];
    return frameData;
}

-(void) stopDecode
{
    stopDecode = true;
    FFmpegNotice *ffNotice = [[FFmpegNotice alloc] init];
    ffNotice.playStatus = ffmpeg_playPause;
    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
}

- (NSTimeInterval)getPlayTime
{
    return (formatCtx == NULL ?
            0.0f : (NSTimeInterval)formatCtx->duration);
}

- (NSTimeInterval)duration
{
    return formatCtx == NULL ?
    0.0f : (NSTimeInterval)formatCtx->duration / AV_TIME_BASE;
}

- (float)getPlayOfNowTime
{
    return Stream_nowTime;
}

- (void)goToPalyWithTime:(NSTimeInterval)seconds
{
    Stream_nowTime = seconds;
    
    if (seconds < [self getPlayTime]) {
        isSeek = YES;
        seekTime = seconds;
        av_free_packet(&packet_video);
        inBuffer_audio = NO;
//        av_free_packet(&packet_audio);
//        currentPacket_audio = packet_audio;
    }
}

-(void)seekFrame
{
    if (seekTime > SAFE_SEEK_SECONDS) {
        seekTime -= SAFE_SEEK_SECONDS;
    }
    int a = av_seek_frame(formatCtx, -1, seekTime * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD);
    if (a < 0) {
        NSLog(@"====eeeero===%d==", a);
    }else{
        Stream_nowTime = seekTime;
    }
    //                        avcodec_flush_buffers(_formatCtx->streams[videoStream]->codec);
}

- (void)getImageStar
{
    isGetImag = YES;
}

#pragma mark - audio
- (AVPacket*)readPacket
{
    if (currentPacket_audio.size > 0 || inBuffer_audio) return &currentPacket_audio;
    
    av_free_packet(&packet_audio);
    
    for (;;) {
        NSInteger ret = av_read_frame(formatCtx, &packet_audio);
        if (ret == AVERROR(EAGAIN)) {
            continue;
        }
        else if (ret < 0) {
            return NULL;
        }
        
        if (packet_audio.stream_index != audioStreamIndex) {
            av_free_packet(&packet_audio);
            continue;
        }
        
        if (packet_audio.dts != AV_NOPTS_VALUE) {
            packet_audio.dts += av_rescale_q(0, AV_TIME_BASE_Q, stream_audio->time_base);
        }
        if (packet_audio.pts != AV_NOPTS_VALUE) {
            packet_audio.pts += av_rescale_q(0, AV_TIME_BASE_Q, stream_audio->time_base);
        }
        
        break;
    }
    
    currentPacket_audio = packet_audio;
    
    return &currentPacket_audio;
}

- (void)nextPacket
{
    inBuffer_audio = NO;
}

- (NSInteger)decode
{
    if (inBuffer_audio) return decodedDataSize_audio;
    
    decodedDataSize_audio = 0;
    AVFrame *audio_frame = av_frame_alloc();
    AVPacket *packet = [self readPacket];
    while (packet && packet->size > 0) {
        if (bufferSize_audio< FFMAX(packet->size * sizeof(*_buffer_audio), AVCODEC_MAX_AUDIO_FRAME_SIZE)) {
            bufferSize_audio = FFMAX(packet->size * sizeof(*_buffer_audio), AVCODEC_MAX_AUDIO_FRAME_SIZE);
            av_free(_buffer_audio);
            _buffer_audio = av_malloc(bufferSize_audio);
        }
        decodedDataSize_audio = bufferSize_audio;
        
        NSInteger len = avcodec_decode_audio4(_codecCtx_audio, audio_frame, (int *)&decodedDataSize_audio, packet);
        if(len < 0)
        { /* if error, skip frame */
            NSLog(@"Could not decode audio packet.");
            return 0;
        }
        
        packet->data += len;
        packet->size -= len;
        
        if (decodedDataSize_audio <= 0) {
            NSLog(@"Decoding was completed.");
            packet = NULL;
            return 0;
        }
        
        inBuffer_audio = YES;
        break;
    }
        
        
    return decodedDataSize_audio;
}

- (NSInteger)getBufferSize
{
    return decodedDataSize_audio;
}

#pragma mark -  decod
-(int) startDecodingWithCallbackBlock: (void (^) (AVFrameData *frame)) frameCallbackBlock
                      waitForConsumer: (BOOL) wait
                   completionCallback: (void (^)()) completion
{
    NSLog(@"============start Decoding==========");
    stopDecode = false;
    
    FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
    ffNotice.playStatus     = ffmpeg_cushioning;
    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
    
    OSMemoryBarrier();
    dispatch_queue_t decodeQueue = dispatch_queue_create("decodeQueue", NULL);
    dispatch_async(decodeQueue, ^{
        int frameFinished;
        OSMemoryBarrier();
        while (self->stopDecode == false){
            @autoreleasepool {
                CFTimeInterval currentTime = CACurrentMediaTime();
                if ((currentTime - previousDecodedFrameTime_video) > MIN_FRAME_INTERVAL &&
                    av_read_frame(formatCtx, &packet_video) >= 0) {
                    previousDecodedFrameTime_video = currentTime;
                    // Is this a packet from the video stream?
                    if (isSeek) {
                        isSeek = NO;
                        [self seekFrame];
                        
                    }else{
                        if(packet_video.stream_index == videoStreamIndex) {
                            // Decode video frame
                            avcodec_decode_video2(_codecCtx_video, _frame_video, &frameFinished, &packet_video);
                            
                            // Did we get a video frame?
                            if(frameFinished) {
                                
                                if (!playFig) {
                                    playFig = YES;
                                    FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
                                    ffNotice.playStatus     = ffmpeg_playStart;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
                                }
                                // create a frame object and call the block;
                                Stream_nowTime = packet_video.dts / 100000.0f;
                                
                                AVFrameData *frameData = [self createFrameData:_frame_video trimPadding:YES];
                                if (isGetImag && _frame_video->data[0] != nil) {
                                    isGetImag = NO;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:imgeNotificatio object:frameData];
                                }
                                frameCallbackBlock(frameData);
                            }
                        }
                        // Free the packet that was allocated by av_read_frame
                        av_free_packet(&packet_video);
                        
                    }
                    
                }else{
                    Dlog(@"ffmpeg sleep 1000");
                    usleep(1000);
                }
            }
        }
        completion();
    });
    
    return 0;
}

#pragma mark - get Image

//平面YUV420转RGB24
void YUV420p_to_RGB24(unsigned char *yuv420[3], unsigned char *rgb24, int width, int height)
{
    //  int begin = GetTickCount();
    int R,G,B,Y,U,V;
    int x,y;
    int nWidth = width>>1; //色度信号宽度
    for (y=0;y<height;y++)
    {
        for (x=0;x<width;x++)
        {
            Y = *(yuv420[0] + y*width + x);
            U = *(yuv420[1] + ((y>>1)*nWidth) + (x>>1));
            V = *(yuv420[2] + ((y>>1)*nWidth) + (x>>1));
            R = Y + 1.402*(V-128);
            G = Y - 0.34414*(U-128) - 0.71414*(V-128);
            B = Y + 1.772*(U-128);
            
            //防止越界
            if (R>255)R=255;
            if (R<0)R=0;
            if (G>255)G=255;
            if (G<0)G=0;
            if (B>255)B=255;
            if (B<0)B=0;
            
            *(rgb24 + ((height-y-1)*width + x)*3) = B;
            *(rgb24 + ((height-y-1)*width + x)*3 + 1) = G;
            *(rgb24 + ((height-y-1)*width + x)*3 + 2) = R;
            //    *(rgb24 + (y*width + x)*3) = B;
            //    *(rgb24 + (y*width + x)*3 + 1) = G;
            //    *(rgb24 + (y*width + x)*3 + 2) = R;
        }
    }
}

-(UIImage *)imageFromData:(unsigned char *)picData
                 lineSize:(int) linesize
                    width:(int)width height:(int)height
{
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, picData, linesize*height,kCFAllocatorNull);
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	CGImageRef cgImage = CGImageCreate(width,
									   height,
									   8,
									   24,
									   linesize,
									   colorSpace,
									   bitmapInfo,
									   provider,
									   NULL,
									   NO,
									   kCGRenderingIntentDefault);
    
    
	CGColorSpaceRelease(colorSpace);
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGDataProviderRelease(provider);
	CFRelease(data);
	
	return image;
}

-(UIImage *)imageFromAVPicture:(unsigned char **)picData
                      lineSize:(int *) linesize
                         width:(int)width height:(int)height
{
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, picData[0], linesize[0]*height,kCFAllocatorNull);
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGImageRef cgImage = CGImageCreate(width,
									   height,
									   8,
									   24,
									   linesize[0],
									   colorSpace,
									   bitmapInfo,
									   provider,
									   NULL,
									   NO,
									   kCGRenderingIntentDefault);
	CGColorSpaceRelease(colorSpace);
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGDataProviderRelease(provider);
	CFRelease(data);
	
	return image;
}

-(UIImage *)convertFramToImage: (AVCodecContext *) avFrameContext frma:(AVFrame *)frame_
{
    AVFrame *pFrameRGB = av_frame_alloc();
    if(pFrameRGB==NULL)
        return nil;
    int numBytes = avpicture_get_size(PIX_FMT_RGB24, avFrameContext->width,
                                      avFrameContext->height);
    uint8_t *buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));
    
    // of AVPicture
    avpicture_fill((AVPicture *)pFrameRGB, buffer, PIX_FMT_RGB24,
                   avFrameContext->width, avFrameContext->height);
    
    unsigned char *pFrameData[AV_NUM_DATA_POINTERS];
    int size_r = avFrameContext->height * avFrameContext->width *3;
    
    unsigned char *pRGB =(unsigned char*)malloc(size_r);
    memset(pRGB, 0x00, size_r);
    for (int i=0; i<AV_NUM_DATA_POINTERS; i++){
        pFrameData[i] = 0;
    }
    pFrameData[0] = (uint8_t*)(frame_->data[0]);
    pFrameData[1] = (uint8_t*)(frame_->data[1]);
    pFrameData[2] = (uint8_t*)(frame_->data[2]);
    
    YUV420p_to_RGB24(pFrameData, pRGB, avFrameContext->width, avFrameContext->height);
    UIImage *image_down = [self imageFromData:pRGB lineSize:pFrameRGB->linesize[0] width:avFrameContext->width height:avFrameContext->height];
   
    UIImageExtension *imgEx = [[UIImageExtension alloc] initWihtImge:image_down];
    
//    UIImage *image = [imgEx imageRotatedByDegrees:180];
//    UIImage *orientImage = [UIImageExtension image:image rotation:UIImageOrientationDownMirrored];
    UIImage *image = [imgEx imageRotatedByFiyDegrees:180];
    av_free(buffer);
    av_free(pFrameRGB);
    
    return image;
   
}

-(UIImage *)convertFrameDataToImage: (AVFrameData *) avFrameData
{
    // Allocate an AVFrame structure
    AVFrame *pFrameRGB = avcodec_alloc_frame();
    if(pFrameRGB==NULL)
        return nil;
    
    int numBytes = avpicture_get_size(PIX_FMT_RGB24, avFrameData.width.intValue,
                                      avFrameData.height.intValue);
    uint8_t *buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));
    
    // of AVPicture
    avpicture_fill((AVPicture *)pFrameRGB, buffer, PIX_FMT_RGB24,
                   avFrameData.width.intValue, avFrameData.height.intValue);
    
    struct SwsContext *sws_ctx = sws_getContext(avFrameData.width.intValue, avFrameData.height.intValue, PIX_FMT_YUV420P, avFrameData.width.intValue, avFrameData.height.intValue, PIX_FMT_RGB24, SWS_BILINEAR, NULL, NULL, NULL);
    
    // Assign appropriate parts of buffer to image planes in pFrameRGB
    // Note that pFrameRGB is an AVFrame, but AVFrame is a superset
    
    uint8_t *data[AV_NUM_DATA_POINTERS];
    int linesize[AV_NUM_DATA_POINTERS];
    for (int i=0; i<AV_NUM_DATA_POINTERS; i++){
        data[i] = NULL;
        linesize[i] = 0;
    }
    data[0]=(uint8_t*)(avFrameData.colorPlane0.bytes);
    data[1]=(uint8_t*)(avFrameData.colorPlane1.bytes);
    data[2]=(uint8_t*)(avFrameData.colorPlane2.bytes);
    linesize[0]=avFrameData.lineSize0.intValue;
    linesize[1]=avFrameData.lineSize1.intValue;
    linesize[2]=avFrameData.lineSize2.intValue;
    
    sws_scale(sws_ctx, (uint8_t const * const *)data, linesize, 0, avFrameData.height.intValue, pFrameRGB->data, pFrameRGB->linesize);
    
    UIImage *image = [self imageFromAVPicture:pFrameRGB->data
                                     lineSize:pFrameRGB->linesize
                                        width:avFrameData.width.intValue height:avFrameData.height.intValue];
    UIImage *image_reault = [UIImage imageWithData:UIImagePNGRepresentation(image)];
    // Free the RGB image
    av_free(buffer);
    av_free(pFrameRGB);
    
    return image_reault;
}

#pragma mark - exit
-(void)dealloc_helper
{
    // Free the YUV frame
    if (_frame_video){
        av_free(_frame_video);
    }
    
    // Close the codec
    if (_codecCtx_video){
        avcodec_close(_codecCtx_video);
    }
    // Close the video src
    if (formatCtx){
        avformat_close_input(&formatCtx);
    }
    
    av_free_packet(&packet_video);
    
    FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
    ffNotice.playStatus     = ffmpeg_playStop;
    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
}

-(void)dealloc
{
    //    dispatch_group_wait(_decode_queue_group, DISPATCH_TIME_FOREVER);
//    [super dealloc];
    FFmpegNotice *ffNotice  = [[FFmpegNotice alloc] init];
    ffNotice.playStatus     = ffmpeg_playFail;
    ffNotice.message        = @"播放异常";
    [[NSNotificationCenter defaultCenter] postNotificationName:@NSNOTICE_FFMPEG_PLAYSTATUS object:ffNotice];
    
    [self stopDecode];
    sleep(1);
    [self dealloc_helper];
    
    NSLog(@"cleaned up...");
}

@end
