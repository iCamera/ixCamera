//
//  KNViewController.m
//  ixCamera
//
//  Created by cyh on 12. 11. 20..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import "KNViewController.h"
#import "KNVideoCapture.h"

@interface KNViewController ()
- (void)startCapture;
@end

@implementation KNViewController

@synthesize viewCapturePreview = _viewCapturePreview;
@synthesize capture = _capture;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.wantsFullScreenLayout = YES;
    
    NSLog(@"_____________%f %f %f %f", _viewCapturePreview.frame.origin.x, _viewCapturePreview.frame.origin.y, _viewCapturePreview.frame.size.width, _viewCapturePreview.frame.size.height);
    
    [self startCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startCapture {
    
    _capture = [[KNVideoCapture alloc] init];
    [_capture startVideoWithPreview:_viewCapturePreview
                          frameRate:30
                         resolution:kKNCaptureHigh 
              withCaptureCompletion:^(UIImage *img) {
                  
                  
    }];
    [_capture setMirroring:YES];
}

static BOOL mirror;
- (IBAction)mirror:(id)sender {
    [_capture setMirroring:!mirror];
}
@end
