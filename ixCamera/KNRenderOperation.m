//
//  KNRenderOperation.m
//  ixCamera
//
//  Created by ken on 13. 4. 10..
//  Copyright (c) 2013년 cyh3813. All rights reserved.
//

#import "KNRenderOperation.h"
#import "KNGLView.h"

static Float64 gDispplayTime;
@interface KNRenderOperation() {
}
@property (retain, nonatomic) KNGLView* render;
@property (assign) CMSampleBufferRef pixelBuffer;
@end

@implementation KNRenderOperation

@synthesize render      = _render;
@synthesize pixelBuffer = _pixelBuffer;

- (void)dealloc {
    
    [_render release];
    [super dealloc];
}

- (id)initWithRender:(KNGLView *)glView withPixelBuffer:(CMSampleBufferRef)pixelBuffer {

    self = [super init];
    if (self) {
        self.render = glView;
        self.pixelBuffer = pixelBuffer;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        
        dispatch_sync(dispatch_get_main_queue(), ^{

            NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
            
            CMTime cmDispTime = CMSampleBufferGetPresentationTimeStamp(_pixelBuffer);
            Float64 dispTime = CMTimeGetSeconds(cmDispTime);
            if (gDispplayTime == 0) {
                gDispplayTime = dispTime;
            }
            
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_pixelBuffer);
            CVPixelBufferLockBaseAddress(imageBuffer, 0);
            

            [_render renderBuffer:imageBuffer];

            
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            CMSampleBufferInvalidate(_pixelBuffer);
            CFRelease(_pixelBuffer);
            _pixelBuffer = nil;
            
            NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSince1970] - startTime;
            
            NSTimeInterval sleepTime = gDispplayTime - elapsedTime;
            if (sleepTime >= gDispplayTime)
                return;
            
            if (sleepTime < 0)
                return;
            
            [NSThread sleepForTimeInterval:gDispplayTime - elapsedTime];
        });
    }
}
@end
