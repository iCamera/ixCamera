//
//  KNVideoBase.h
//  MediaAccelatorDemo
//
//  Created by cyh on 12. 11. 16..
//  Copyright (c) 2012년 cyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum tagKNVideoWriterFileType {
    
    kKNVideoWriterFileTypeMov = 0,
    kKNVideoWriterFileTypeMP4,
    kKNVideoWriterFileTypeM4V
    
}KNVideoWriterFileType;


@interface KNVideoBase : NSObject

@property (copy, nonatomic) NSString* filepath;
@property (copy, nonatomic) NSString* filename;
@property (copy, nonatomic) NSString* filenameExt;
@property (assign) KNVideoWriterFileType fileType;

- (NSString *)videoFileType;
- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
