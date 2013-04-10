//
//  KNCVImageRender.h
//  ixCamera
//
//  Created by ken on 13. 4. 9..
//  Copyright (c) 2013년 cyh3813. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNCVImageRender : UIView
- (void)render:(CVImageBufferRef)pixelBuffer;
@end
