//
//  KNVideoManager.h
//  VideoManagerDemo
//
//  Created by Choi Yeong Hyeon on 12. 10. 1..
//  Copyright (c) 2012년 Choi Yeong Hyeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    kKNGravityResizeToFit,
    kKNGravityAspectFill,
    kKNGravityAspectFit
}kKNPreviewGravity;

typedef enum {
    kKNCameraFront,
    kKNCameraBack,
    kKNCameraOff,
}kKNCameraPosition;


typedef enum {
    kKNCaptureHigh,
    kKNCaptureMedium,
    kKNCaptureLow,
    kKNCapture480,
    kKNCapture720
}kKNCaptureResolution;

@interface KNVideoCapture : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

- (void)startVideoWithPreview:(UIView *)preview
                    frameRate:(NSInteger)frameRate
                   resolution:(kKNCaptureResolution)resolution
        withCaptureCompletion:(void(^)(UIImage* img))competion;

- (void)stopVideo;


- (void)previewVideoGravity:(kKNPreviewGravity)gravity;

- (void)changeCameraPosition:(kKNCameraPosition)cameraPosition;

- (BOOL)changeCaptureResolution:(kKNCaptureResolution)resolution;

- (void)changeCaptureFrameRate:(NSInteger)framerate;

- (void)totchToggle;
- (void)setAutoTorchMode:(BOOL)use;
- (void)setTorchLevel:(float)level;

@end
