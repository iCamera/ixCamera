//
//  KNEncoder.m
//  ixCamera
//
//  Created by cyh on 12. 12. 17..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import "KNEncoder.h"
#import "KNVideoWriter.h"
#import "KNFileManager.h"
#import "KNEncodeOperation.h"

@interface KNEncoder () {
    void(^frameBlock_)(UInt8* data, int dataSize, int width, int height, int codecid);
    void(^encodeStop_)(void);
}
@property (retain, nonatomic)   KNVideoWriter* writer;
@property (copy, nonatomic)     NSString* filename;
@property (retain, nonatomic)   NSOperationQueue* frameQueue;
@property CGSize resolution;
@property NSInteger fileSegmentDuration;
@property NSInteger fps;
@property BOOL stopEncode;

- (void)createVideoWriter;
- (void)releaseVideoWriter;
- (void)addFrameOperation;
@end

@implementation KNEncoder

@synthesize resolution              = _resolution;
@synthesize fileSegmentDuration     = _fileSegmentDuration;
@synthesize fps                     = _fps;
@synthesize stopEncode              = _stopEncode;

- (id)initWithResolution:(CGSize)resolution
          segmentDuation:(NSInteger)duration
               frameRate:(NSInteger)fps
          frameRecvBlock:(void(^)(UInt8* data, int size, int width, int height, int codecid))frameRecvBlock {

    self = [super init];
    if (self) {
        
        _resolution = resolution;
        _fileSegmentDuration = duration;
        _fps = fps;
        frameBlock_ = [frameRecvBlock copy];
        
        NSOperationQueue* q = [[NSOperationQueue alloc] init];
        self.frameQueue = q;
        
        [self createVideoWriter];
    }
    return self;
}

- (void)encodeFrame:(CVPixelBufferRef)frameBuff {
    
    if (_stopEncode) {
        [_writer writeFinishWithCompletion:encodeStop_];
        encodeStop_ = nil;
        return;
    }

    if (_writer) {
        [_writer writeBufferSample:frameBuff withCompletion:^(BOOL finishedByDuration) {
            
            if (finishedByDuration) {
                [self addFrameOperation];
                [self createVideoWriter];
            }
        }];
    }
}


- (void)createVideoWriter {
    
    NSDate* curDate = [NSDate date];
    NSString* videofilePath = [NSString stringWithFormat:@"%@/%@.mp4", [[KNFileManager sharedObject] documentDirectory], [curDate description]];
    
    KNVideoWriter* writer  = [[KNVideoWriter alloc] initWithFilepath:videofilePath
                                                            fileType:kKNVideoWriterFileTypeMP4
                                                          resolution:_resolution
                                                                 fps:_fps
                                                            duration:_fileSegmentDuration];
    self.writer = writer;
    writer = nil;
}

- (void)releaseVideoWriter {
    
}

- (void)addFrameOperation {

    KNEncodeOperation* op = [[KNEncodeOperation alloc] initWithFilepath:_writer.filepath
                                                         frameRecvBlock:frameBlock_];
    [_frameQueue addOperation:op];
}

- (void)stopEncode:(void(^)(void))completion {

    encodeStop_ = [completion copy];
    _stopEncode = YES;
}

@end
