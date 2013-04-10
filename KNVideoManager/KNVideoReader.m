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

@synthesize reader      = _reader;
@synthesize filename    = _filename;


#pragma mark - Public

- (void)dealloc {
    [_filename release];
    [_reader cancelReading];
    [_reader release];
    [super dealloc];
}

- (id)initWithFilenpath:(NSString *)filepath {

    self = [super init];
    if (self) {
        self.filepath = filepath;
        [self initAssetReader];
    }
    return self;
}


#pragma mark - Private
- (void)initAssetReader {
    
    NSURL* url = [NSURL fileURLWithPath:self.filepath];
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
    [urlAsset release];
    [output release];
    [reader release];
}

- (void)readBufferBlock:(void(^)(CMSampleBufferRef buff))completion {
    
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
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            
            [self.reader startReading];

            int read = 0;
            while (self.reader.status == AVAssetReaderStatusReading) {
                @synchronized(self) {

                    CMSampleBufferRef sampleBufferRef = [output copyNextSampleBuffer];
                    
                    if (read > 0) {
                        if (completion && sampleBufferRef)
                            completion(sampleBufferRef);
                    }
                    
                    if (read++ > output.track.nominalFrameRate) {
                        [self.reader cancelReading];
                        break;
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

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}
@end
