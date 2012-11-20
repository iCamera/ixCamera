//
//  KNVideoCapture.h
//  VideoManagerDemo
//
//  Created by Choi Yeong Hyeon on 12. 10. 1..
//  Copyright (c) 2012년 Choi Yeong Hyeon. All rights reserved.
//

#import "KNVideoCapture.h"

const NSInteger MAX_CAPTURE_FRAMERATE = 30;
const NSInteger SECOND = 1;
const NSInteger DEFAULT_FRAMERATE = 30;

@interface KNVideoCapture() {

    AVCaptureDevicePosition devicePostion_;
    BOOL autoTorch_;
    
    void(^captureCompletion)(UIImage* img);
}

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* previewLayer;
@property (strong, nonatomic) UIView* viewPreview;
@property NSInteger captureFrameRate;
@property kKNCaptureResolution captureResolution;

- (AVCaptureSession *)session;
- (AVCaptureDevice *)cameraPosition:(AVCaptureDevicePosition)position;

- (NSString *)preset:(kKNCaptureResolution)resolution;

- (AVCaptureDeviceInput *)currentInput;
- (AVCaptureVideoDataOutput *)currentOutput;
- (void)removeCurrentInput;
- (void)removeCurrentOutput;
- (void)changeFrameRate:(AVCaptureConnection *)conn;
- (void)autoTorch;
- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
@end

@implementation KNVideoCapture

@synthesize session             = _session;
@synthesize previewLayer        = _previewLayer;
@synthesize viewPreview         = _viewPreview;
@synthesize captureFrameRate    = _captureFrameRate;
@synthesize captureResolution   = _captureResolution;

- (id)init {
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

#pragma mark - Private
- (AVCaptureDevice *)cameraPosition:(AVCaptureDevicePosition)position {
    
    for (AVCaptureDevice* device in [AVCaptureDevice devices]) {
        
        if (device.position == position)
            return device;
    }
    return nil;
}

- (NSString *)preset:(kKNCaptureResolution)resolution {
    
    NSString* preset = AVCaptureSessionPresetMedium;
 
    switch (resolution) {
        case kKNCaptureHigh:
            preset = AVCaptureSessionPresetHigh;
            break;
            
        case kKNCaptureMedium:
            preset = AVCaptureSessionPresetMedium;
            break;
            
        case kKNCaptureLow:
            preset = AVCaptureSessionPresetLow;
            break;
            
        case kKNCapture480:
            preset = AVCaptureSessionPreset640x480;
            break;
            
        case kKNCapture720:
            preset = AVCaptureSessionPreset1280x720;
            break;
    }

    return preset;
}

- (AVCaptureDeviceInput *)currentInput {
    return [_session.inputs objectAtIndex:0];
}

- (AVCaptureVideoDataOutput *)currentOutput {
    return [_session.outputs objectAtIndex:0];
}

- (void)removeCurrentInput {
    [_session removeInput:[self currentInput]];
}

- (void)removeCurrentOutput {
    [_session removeOutput:[self currentOutput]];
}

- (void)changeFrameRate:(AVCaptureConnection *)conn {
    
    if (conn.supportsVideoMinFrameDuration)
        conn.videoMinFrameDuration = CMTimeMake(SECOND, _captureFrameRate);
    if (conn.supportsVideoMaxFrameDuration)
        conn.videoMaxFrameDuration = CMTimeMake(SECOND, _captureFrameRate);
}

- (void)autoTorch {
    
    AVCaptureDeviceInput* input = [self currentInput];
    
    if ([input.device isTorchAvailable] == NO)
        return;
    
    if ([input.device isTorchActive] == NO)
        return;

    [input.device lockForConfiguration:nil];
    if ([input.device isTorchModeSupported:AVCaptureTorchModeAuto]) {
        [input.device setTorchMode:AVCaptureTorchModeAuto];
    }
    [input.device unlockForConfiguration];
}

- (AVCaptureSession *)session {
    
    if (_session)
        return nil;
 
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = [self preset:_captureResolution];
    

    devicePostion_ = AVCaptureDevicePositionFront;
    AVCaptureDevice* device = [self cameraPosition:devicePostion_];
    
    NSError* error = nil;
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"%s %@", __func__, [error localizedDescription]);
        session = nil;
        return  session;
    }
    [session addInput:input];
    
    
    AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    
    AVCaptureConnection* connection = [output connectionWithMediaType:AVMediaTypeVideo];
    [self changeFrameRate:connection];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                              forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [output setVideoSettings:videoSettings];
    dispatch_queue_t queue = dispatch_queue_create("captureQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    [session addOutput:output];
    

    if (_viewPreview) {
        AVCaptureVideoPreviewLayer* previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        previewLayer.frame = _viewPreview.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResize;
        [_viewPreview.layer addSublayer:previewLayer];
        
        self.previewLayer = previewLayer;
    }

    return  session;
}

#pragma mark - Public
- (void)startVideoWithPreview:(UIView *)preview
                    frameRate:(NSInteger)frameRate
                   resolution:(kKNCaptureResolution)resolution
        withCaptureCompletion:(void(^)(UIImage* img))competion {

    self.viewPreview        = preview;
    self.captureFrameRate   = frameRate;
    self.captureResolution  = resolution;
    captureCompletion       = [competion copy];
    
    self.session = [self session];
    if (_session) {
        [_session startRunning];
    }
}

- (void)stopVideo {
    
    [self.session stopRunning];
    
    [self removeCurrentInput];
    [self removeCurrentOutput];
    
    
    [self.previewLayer removeFromSuperlayer];
    
    self.previewLayer = nil;
    self.session = nil;
}


- (void)previewVideoGravity:(kKNPreviewGravity)gravity {
    
    NSString* g = AVLayerVideoGravityResize;
    switch (gravity) {
        case kKNGravityAspectFill:
            g = AVLayerVideoGravityResizeAspectFill;
            break;

        case kKNGravityAspectFit:
            g = AVLayerVideoGravityResizeAspect;
            break;

        default:
            g = AVLayerVideoGravityResize;
            break;
    }
    self.previewLayer.videoGravity = g;
}

- (void)changeCameraPosition:(kKNCameraPosition)cameraPosition {
    
    AVCaptureDevicePosition pos = AVCaptureDevicePositionUnspecified;
    
    switch (cameraPosition) {
        case kKNCameraFront:
            pos = AVCaptureDevicePositionFront;
            break;

        case kKNCameraBack:
            pos = AVCaptureDevicePositionBack;
            break;

        case kKNCameraOff:
            pos = AVCaptureDevicePositionUnspecified;
            break;

        default:
            break;
    }
    devicePostion_ = pos;
    
    [_session beginConfiguration];
    
    NSError* error = nil;
    AVCaptureDevice* device = [self cameraPosition:devicePostion_];
    AVCaptureDeviceInput* newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!newInput) {
        NSLog(@"%s %@", __func__, [error localizedDescription]);
    } else {
        
        [self removeCurrentInput];
        if ([_session canAddInput:newInput]) {
            [_session addInput:newInput];
        
        }else {
            NSLog(@"%s : failed.", __func__);
        }
    }
    [_session commitConfiguration];
    
    
    if (devicePostion_ == AVCaptureDevicePositionBack && autoTorch_) {
        [self autoTorch];
    }
}


- (BOOL)changeCaptureResolution:(kKNCaptureResolution)resolution {
    
    NSString* preset = [self preset:resolution];
    
    if ([_session.sessionPreset isEqualToString:preset]) {
        NSLog(@"%s Same Preset.", __func__);
        return NO;
    }
    
    if ([_session canSetSessionPreset:preset]) {

        [_session beginConfiguration];
        
        NSError* error = nil;
        AVCaptureDevice* device = [self cameraPosition:devicePostion_];
        AVCaptureDeviceInput* newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!newInput) {
            NSLog(@"%s %@", __func__, [error localizedDescription]);
        } else {
            
            [self removeCurrentInput];
            if ([_session canAddInput:newInput]) {
                [_session addInput:newInput];
            }else
                NSLog(@"%s can addInput", __func__);
        }
        _session.sessionPreset = preset;
        
        [_session commitConfiguration];
        
        if (devicePostion_ == AVCaptureDevicePositionBack && autoTorch_)
            [self autoTorch];
        
        return YES;
    }
    
    NSLog(@"%s doesn't support.[%@].", __func__, preset);
    return NO;
}

- (void)changeCaptureFrameRate:(NSInteger)framerate {

    if (_captureFrameRate == framerate)
        return;

    if (framerate > MAX_CAPTURE_FRAMERATE)
        framerate = MAX_CAPTURE_FRAMERATE;
    
    if (framerate <= 0)
        framerate = 1;

    _captureFrameRate = framerate;
}


- (void)totchToggle {

    AVCaptureDeviceInput* input = [self currentInput];
    
    if ([input.device isTorchAvailable] == NO)
        return;
    
    [input.device lockForConfiguration:nil];
    
    if ([input.device isTorchActive]) {
        
        if ([input.device isTorchModeSupported:AVCaptureTorchModeOff])
            [input.device setTorchMode:AVCaptureTorchModeOff];
    } else {
        
        if ([input.device isTorchModeSupported:AVCaptureTorchModeOn])
            [input.device setTorchMode:AVCaptureTorchModeOn];
        
    }
    [input.device unlockForConfiguration];
}

- (void)setAutoTorchMode:(BOOL)use {
    autoTorch_ = use;
}
- (void)setTorchLevel:(float)level {
    
}


- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width,
                                                    height,
                                                    8,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    return newImage;
}



#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    if (captureCompletion) {
        
        CGImageRef imageRef = [self imageFromSampleBuffer:sampleBuffer];
        UIImage* img = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationLeftMirrored];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            captureCompletion(img);
            CGImageRelease(imageRef);
        });
    }
    [self changeFrameRate:connection];
}


@end
