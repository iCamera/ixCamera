//
//  KNVideoReader.m
//  MediaAccelatorDemo
//
//  Created by cyh on 12. 11. 16..
//  Copyright (c) 2012년 cyh. All rights reserved.
//

#import "KNVideoReader.h"

@interface KNVideoReader () {
    BOOL finishRead_;
    void(^readBlock)(id buffer);
}
@property (strong, nonatomic) AVAssetReader* reader;
@property (copy, nonatomic) NSString* filename;
- (void)initAssetReader;
@end

@implementation KNVideoReader

@synthesize filename = _filename;


#pragma mark - Public
- (id)initWithFilename:(NSString *)filename {

    self = [super init];
    if (self) {
        self.filename = filename;
        [self initAssetReader];
    }
    return self;
}


#pragma mark - Private
- (void)initAssetReader {

    NSString* path = [NSString stringWithFormat:@"%@/%@", [self getDocPath], self.filename];
    NSURL* url = [NSURL fileURLWithPath:path];
    AVURLAsset* urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];

    NSArray* tracks = [urlAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack* track = [tracks objectAtIndex:0];
    NSDictionary* trackDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                         forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track
                                                                        outputSettings:trackDic];
    
    NSError* error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:urlAsset error:&error];
    [reader addOutput:output];
    self.reader = reader;
}

- (void)readBufferBlock:(void(^)(id buff))completion {
    
    if (finishRead_) {
        NSLog(@"%s AVAsset read canceled.", __func__);
        return;
    }
    
    __block AVAssetReaderTrackOutput* output = nil;
    
    NSArray* outputs = self.reader.outputs;
    [outputs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([[obj mediaType] isEqualToString:AVMediaTypeVideo]) {
            output = obj;
            *stop = YES;
        }
    }];
    
    if (output == nil) {
        NSLog(@"%s We can't found AVAssetReaderTrackOutput.", __func__);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
    
            [self.reader startReading];
            while (self.reader.status == AVAssetReaderStatusReading) {
                
                CMSampleBufferRef sampleBufferRef = [output copyNextSampleBuffer];
                
                UIImage* img = nil;
                if (sampleBufferRef){
                    CGImageRef imgRef = [self imageFromSampleBuffer:sampleBufferRef];
                    img = [UIImage imageWithCGImage:imgRef];
                    CMSampleBufferInvalidate(sampleBufferRef);
                    CFRelease(sampleBufferRef);
                    
                    if (completion && img) {
                        completion(img);
                    }
                }
            }
        }
    });
}

- (void)readFinish {

    finishRead_ = YES;
    [self.reader cancelReading];
    
}
@end
