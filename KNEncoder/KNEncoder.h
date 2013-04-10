//
//  KNEncoder.h
//  ixCamera
//
//  Created by cyh on 12. 12. 17..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface KNEncoder : NSObject

//- (id)initWithResolution:(CGSize)resolution
//          segmentDuation:(NSInteger)duration
//               frameRate:(NSInteger)fps
//          frameRecvBlock:(void(^)(UInt8* data, int size, int width, int height, int codecid))frameRecvBlock;

- (id)initWithResolution:(CGSize)resolution
          segmentDuation:(NSInteger)duration
               frameRate:(NSInteger)fps
          frameRecvBlock:(void(^)(CMSampleBufferRef pixelBuffer))frameRecvBlock;


- (void)encodeFrame:(CVPixelBufferRef)frameBuff;

- (void)stopEncode:(void(^)(void))completion;
@end
