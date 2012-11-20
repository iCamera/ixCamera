//
//  KNVideoWriter.m
//  VideoManagerDemo
//
//  Created by Choi Yeong Hyeon on 12. 10. 2..
//  Copyright (c) 2012년 Choi Yeong Hyeon. All rights reserved.
//

#import "KNVideoWriter.h"

@interface KNVideoWriter() {
    
    BOOL finishWrite_;
    dispatch_queue_t writeQueue;
}
@property (strong, nonatomic) AVAssetWriter* videoWriter;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor* videoWriteAdapter;
@property (assign) AVAssetWriterInput* videoWriteInput;
@property (assign) NSInteger writtenDuration;
@property (assign) NSInteger writtenFrame;
@property (assign) NSInteger fps;
@property (assign) CGSize resolution;
@property (readonly) NSInteger duration;

- (void)initAssetWriter;
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;
@end

@implementation KNVideoWriter

@synthesize videoWriter         = _videoWriter;
@synthesize videoWriteInput     = _videoWriteInput;
@synthesize videoWriteAdapter   = _videoWriteAdapter;
@synthesize resolution          = _resolution;
@synthesize writtenDuration     = _writtenDuration;
@synthesize writtenFrame        = _writtenFrame;
@synthesize fileType            = _fileType;
@synthesize fps                 = _fps;
@synthesize duration            = _duration;

- (id)initWithFilename:(NSString *)filename
              fileType:(KNVideoWriterFileType)type
            resolution:(CGSize)resolution
                   fps:(NSInteger)fps
              duration:(NSInteger)duration {
    

    self = [super init];
    if (self) {
        
        self.filename       = filename;
        self.fileType       = type;
        _writtenDuration    = 0;
        _resolution         = resolution;
        _fileType           = type;
        _fps                = fps;
        _duration           = duration;
        
        [self initAssetWriter];
    }
    return self;
}

- (void)writeBuffer:(UIImage *)image
     withCompletion:(void(^)(BOOL finishedByDuration))completion {

    if (finishWrite_) {
        NSLog(@"%s Video wrinting is done.", __func__);
        return;
    }
    
    if ([_videoWriteInput isReadyForMoreMediaData]) {
        
        CGImageRef cgImage = [image CGImage];
        CVPixelBufferRef buffer = [self pixelBufferFromCGImage:cgImage];
        
        CMTime frameTime = CMTimeMake(1, _fps);
        CMTime lastTime=CMTimeMake(_writtenFrame++, _fps);
        CMTime presentTime=CMTimeAdd(lastTime, frameTime);
        
        BOOL ret = [_videoWriteAdapter appendPixelBuffer:buffer
                                    withPresentationTime:presentTime];
        
        if (ret == NO)
            NSLog(@"%s failed to append buffe.", __func__);
        
        if (buffer)
            CVBufferRelease(buffer);
        
//        [NSThread sleepForTimeInterval:0.05];
        
        if (_writtenFrame % _fps == 0) {
            ++_writtenDuration;
            NSLog(@"%s wrriten duration : %d sec", __func__, _writtenDuration);
        }
    
        
        ///After Write.
        if (_duration == _writtenDuration) {
            
            void(^writeFinishByDutation)(void) = ^(void) {
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES);
                    });
                }
            };
            [self writeFinishWithCompletion:writeFinishByDutation];
            return;
            
        } else {
         
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
        }
    }
}


- (void)writeFinishWithCompletion:(void(^)(void))completion {

    [_videoWriteInput markAsFinished];
    [_videoWriter finishWritingWithCompletionHandler:^{
        CVPixelBufferPoolRelease(_videoWriteAdapter.pixelBufferPool);
        
        self.videoWriteAdapter = nil;
        self.videoWriteInput = nil;
        self.videoWriter = nil;
        
        finishWrite_ = YES;
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}


#pragma mark - Private
- (void)initAssetWriter {
    
    NSString* fileType = [self videoFileType];
    
    NSError* error = nil;
    NSString* savePath = [NSString stringWithFormat:@"%@/%@.%@", [self getDocPath], self.filename, self.filenameExt];
    NSURL* url = [NSURL fileURLWithPath:savePath];
    
    
    ///Writer
    AVAssetWriter* videoWriter = [[AVAssetWriter alloc] initWithURL:url fileType:fileType error:&error];
    NSParameterAssert(videoWriter);
    if (error) {
        NSLog(@"%s %@", __func__, [error localizedDescription]);
        return;
    }
    self.videoWriter = videoWriter;
    
    
    ///Input
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:_resolution.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:_resolution.height], AVVideoHeightKey, nil];
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                              outputSettings:videoSettings];
//    videoWriterInput.expectsMediaDataInRealTime = YES;
    self.videoWriteInput = videoWriterInput;
    
    
    ///Adaptor
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    [videoWriter addInput:videoWriterInput];
    
    
    self.videoWriteAdapter = adaptor;
    
    writeQueue = dispatch_queue_create("com.cyh.assetVideoWriteQueue", NULL);
    
    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
}



- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    int frameWidth = _resolution.width;
    int frameHeight = _resolution.height;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault,
                        frameWidth,
                        frameHeight,
                        kCVPixelFormatType_32ARGB,
                        (__bridge CFDictionaryRef) options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 4*frameWidth,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


@end
