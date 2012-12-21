//
//  KNEncodeOperation.h
//  ixCamera
//
//  Created by cyh on 12. 12. 17..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNEncodeOperation : NSOperation
- (id)initWithFilepath:(NSString *)filepath
        frameRecvBlock:(void(^)(UInt8* data, int dataSize, int width, int height, int codecid))frameRecvBlock;
@end
