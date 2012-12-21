//
//  KNViewController.m
//  ixCamera
//
//  Created by cyh on 12. 11. 20..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import "KNViewController.h"
#import "KNVideoCapture.h"
#import "KNVideoWriter.h"
#import "KNFileManager.h"
#import "KNEncoder.h"

@interface KNViewController () {
    BOOL fileWrite_;
}
@property (strong, nonatomic) KNVideoWriter* videoWriter;
@property (strong, nonatomic) KNEncoder* encoder;
- (void)startCapture;
@end

@implementation KNViewController

@synthesize viewCapturePreview = _viewCapturePreview;
@synthesize capture = _capture;
@synthesize videoWriter = _videoWriter;

@synthesize encoder = _encoder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.wantsFullScreenLayout = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self startCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startCapture {
    
    _encoder = [[KNEncoder alloc] initWithResolution:CGSizeMake(640, 480)
                                      segmentDuation:3
                                           frameRate:5
                                      frameRecvBlock:^(UInt8 *data, int size, int width, int height, int codecid)
    {
        NSLog(@"Encode : %d %d %d %d", size, width, height, codecid);
    }];
    
    _capture = [[KNVideoCapture alloc] init];
    [_capture startVideoWithPreview:_viewCapturePreview
                          frameRate:5
                         resolution:kKNCaptureHigh
                          ouputType:kKNCaptureOutputBuffer
                          mirroring:YES
              withCaptureCompletion:^(id outputData)
    {
        if (_encoder) {
            [_encoder encodeFrame:(__bridge CVPixelBufferRef)(outputData)];
        }
    }];
    [_capture setMirroring:YES];
}

- (IBAction)testShot:(id)sender {
}

- (IBAction)position:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


@end
