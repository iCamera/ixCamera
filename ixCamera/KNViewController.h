//
//  KNViewController.h
//  ixCamera
//
//  Created by cyh on 12. 11. 20..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNCVImageRender.h"
#import "KNGLView.h"

@class KNVideoCapture;
@interface KNViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView* viewCapturePreview;
@property (strong, nonatomic) IBOutlet UIView* render;
@property (strong, nonatomic) IBOutlet UIImageView* imgView;
@property (strong, nonatomic) IBOutlet KNGLView* glView;
@property (strong, nonatomic) KNVideoCapture* capture;

@property (retain, nonatomic) NSOperationQueue* renderQueue;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
@end
