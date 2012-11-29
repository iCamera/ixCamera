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
}KNPreviewGravity;

typedef enum {
    kKNCameraFront,
    kKNCameraBack,
    kKNCameraOff,
}KNCameraPosition;


typedef enum {
    kKNCaptureHigh,
    kKNCaptureMedium,
    kKNCaptureLow,
    kKNCapture288,
    kKNCapture480,
    kKNCapture720,
    kKNCapture1080
}KNCaptureResolution;

typedef enum {
    kKNCaptureOutputBuffer,
    kKNCaptureOutputImage
}KNCaptureOutput;

@interface KNVideoCapture : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
@property CGSize captureSize;

- (void)startVideoWithPreview:(UIView *)preview
                    frameRate:(NSInteger)frameRate
                   resolution:(KNCaptureResolution)resolution
                    ouputType:(KNCaptureOutput)outputType
        withCaptureCompletion:(void(^)(id outputData))competion;

- (void)stopVideo;


- (void)previewVideoGravity:(KNPreviewGravity)gravity;

- (void)changeCameraPosition:(KNCameraPosition)cameraPosition;

- (BOOL)changeCaptureResolution:(KNCaptureResolution)resolution;

- (void)changeCaptureFrameRate:(NSInteger)framerate;

- (void)totchToggle;
- (void)setAutoTorchMode:(BOOL)use;
- (void)setTorchLevel:(float)level;
- (BOOL)isMirroring;
- (void)setMirroring:(BOOL)mirror;

@end
