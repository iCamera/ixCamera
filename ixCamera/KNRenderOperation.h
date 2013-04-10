//
//  KNRenderOperation.h
//  ixCamera
//
//  Created by ken on 13. 4. 10..
//  Copyright (c) 2013년 cyh3813. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class KNGLView;
@interface KNRenderOperation : NSOperation
- (id)initWithRender:(KNGLView *)glView withPixelBuffer:(CMSampleBufferRef)pixelBuffer;
@end
