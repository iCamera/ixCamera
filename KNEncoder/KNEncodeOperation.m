//
//  KNEncodeOperation.m
//  ixCamera
//
//  Created by cyh on 12. 12. 17..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import "KNEncodeOperation.h"
#import "KNFileManager.h"

@interface KNEncodeOperation () {
    void(^frameBlock_)(UInt8* data, int dataSize, int width, int height, int codecid);
}
@property (copy, nonatomic) NSString* filepath;
@end

@implementation KNEncodeOperation

@synthesize filepath = _filepath;

- (id)initWithFilepath:(NSString *)filepath
        frameRecvBlock:(void(^)(UInt8* data, int dataSize, int width, int height, int codecid))frameRecvBlock {
    
    self = [super init];
    if (self) {
        self.filepath = filepath;
        frameBlock_ = [frameRecvBlock copy];
    }
    return self;
}

- (void)main {
    
    NSLog(@"##[thread_id:%p] %s START", [NSThread currentThread], __func__);

    @autoreleasepool {
        [[KNFileManager sharedObject] deleteFile:self.filepath];
    }
    
    NSLog(@"##[thread_id:%p] %s END", [NSThread currentThread], __func__);
}

@end
