//
//  KNEncodeOperation.m
//  ixCamera
//
//  Created by cyh on 12. 12. 17..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import "KNEncodeOperation.h"
#import "KNFileManager.h"
#import "KNVideoReader.h"

@interface KNEncodeOperation () {
    void(^frameBlock_)(CMSampleBufferRef pixelBuffer);
}
@property (retain, nonatomic) KNVideoReader* reader;
@property (copy, nonatomic) NSString* filepath;
@end

@implementation KNEncodeOperation

@synthesize filepath = _filepath;
@synthesize reader = _reader;

- (void)dealloc {
    [_filepath release];
    [_reader release];
    [frameBlock_ release];
    [super dealloc];
}

- (id)initWithFilepath:(NSString *)filepath
        frameRecvBlock:(void(^)(CMSampleBufferRef pixelBuffer))frameRecvBlock {
    
    self = [super init];
    if (self) {
        self.filepath = filepath;
        frameBlock_ = [frameRecvBlock copy];
        
        KNVideoReader* r = [[KNVideoReader alloc] initWithFilenpath:_filepath];
        self.reader = r;
        [r release];
    }
    return self;
}

- (void)main {
    
    @autoreleasepool {
        ///인코더 : 여기서 FFmpeg으로 파일까서 AVFrame 얻어내면 h.264 인코딩 데이터임. 현재 테스트위해 AVAssetReader 사용.
        
        [self.reader readBufferBlock:^(CMSampleBufferRef buff) {
            frameBlock_(buff);
        }];
        [[KNFileManager sharedObject] deleteFile:self.filepath];
    }
}

@end
