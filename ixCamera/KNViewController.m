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

@interface KNViewController () {
    BOOL capture_;
}
@property (strong, nonatomic) KNVideoWriter* videoWriter;
- (void)startCapture;
@end

@implementation KNViewController

@synthesize viewCapturePreview = _viewCapturePreview;
@synthesize capture = _capture;
@synthesize videoWriter = _videoWriter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.wantsFullScreenLayout = YES;
    
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
                          ouputType:kKNCaptureOutputBuffer
              withCaptureCompletion:^(id outputData)
    {
        NSLog(@"%p", outputData);
    }];
    [_capture setMirroring:YES];
}

- (IBAction)testShot:(id)sender {
    
    [_capture setMirroring:![_capture isMirroring]];
    return;
    
    NSString* docPath = [[KNFileManager sharedObject] documentDirectory];
    NSString* filePath = [NSString stringWithFormat:@"%@/@", docPath, [[NSDate date] description]];
        
    
//    [sender setEnabled:NO];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        @autoreleasepool {
//            
//            NSString* savefile = [NSString stringWithFormat:@"%@/%@", [[KNFileManager sharedObject] documentDirectory], @"test"];
//            KNVideoWriter* writer = [[KNVideoWriter alloc] initWithFilepath:savefile
//                                                                   fileType:kKNVideoWriterFileTypeM4V
//                                                                 resolution:CGSizeMake(640, 480)
//                                                                        fps:30
//                                                                   duration:1];
//        }
//        [sender performSelectorOnMainThread:@selector(setEnabled:)
//                                 withObject:[NSNumber numberWithBool:YES]
//                              waitUntilDone:NO];
//    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
