//
//  KNViewController.m

//
//  Created by cyh on 12. 11. 20..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import "KNViewController.h"
#import "KNVideoCapture.h"
#import "KNVideoWriter.h"
#import "KNFileManager.h"
#import "KNEncoder.h"
#import "KNRenderOperation.h"

@interface KNViewController () {
    BOOL fileWrite_;
    CFSocketRef socket_;
    
}
@property (strong, nonatomic) KNVideoWriter* videoWriter;
@property (strong, nonatomic) KNEncoder* encoder;
- (void)startCapture;
@end

@implementation KNViewController

@synthesize viewCapturePreview = _viewCapturePreview;
@synthesize capture = _capture;
@synthesize videoWriter = _videoWriter;
@synthesize render = _render;
@synthesize glView = _glView;
@synthesize imgView = _imgView;
@synthesize encoder = _encoder;
@synthesize renderQueue = _renderQueue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.wantsFullScreenLayout = YES;
    
    _glView = [[KNGLView alloc] initWithFrame:_render.bounds];
    [_render addSubview:_glView];
    _glView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSOperationQueue* q = [[NSOperationQueue alloc] init];
    q.maxConcurrentOperationCount = 1;
    self.renderQueue = q;
    [q release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startCapture {
    
    _encoder = [[KNEncoder alloc] initWithResolution:CGSizeMake(640, 480)
                                      segmentDuation:1
                                           frameRate:30
                                      frameRecvBlock:^(CMSampleBufferRef pixelBuffer)
    {
        if (pixelBuffer == nil)
            return;
        
        KNRenderOperation* op = [[KNRenderOperation alloc] initWithRender:_glView withPixelBuffer:pixelBuffer];
        [_renderQueue addOperation:op];
        [op release];
        
    }];
    
    _capture = [[KNVideoCapture alloc] init];
    [_capture startVideoWithPreview:_viewCapturePreview
                          frameRate:30
                         resolution:kKNCapture480
                          ouputType:kKNCaptureOutputBuffer
                          mirroring:YES
              withCaptureCompletion:^(id outputData)
        {
            if (_encoder) {
                [_encoder encodeFrame:(CVPixelBufferRef)(outputData)];
        }
    }];
    [_capture setMirroring:YES];
}

- (IBAction)start:(id)sender {
    [self startCapture];
}

- (IBAction)stop:(id)sender {
    [_capture stopVideo];
    [_encoder stopEncode:nil];
}



@end
