//
//  KNEncodeOperation.h
//  ixCamera
//
//  Created by cyh on 12. 12. 17..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface KNEncodeOperation : NSOperation
- (id)initWithFilepath:(NSString *)filepath
        frameRecvBlock:(void(^)(CMSampleBufferRef pixelBuffer))frameRecvBlock;
@end
