//
//  KNViewController.h
//  ixCamera
//
//  Created by cyh on 12. 11. 20..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KNVideoCapture;
@interface KNViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView* viewCapturePreview;
@property (strong, nonatomic) KNVideoCapture* capture;

- (IBAction)testShot:(id)sender;
- (IBAction)position:(id)sender;
@end
