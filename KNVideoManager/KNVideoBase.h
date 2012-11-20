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
    
    KNVideoWriterFileTypeMov = 0,
    KNVideoWriterFileTypeMP4,
    KNVideoWriterFileTypeM4V
    
}KNVideoWriterFileType;


@interface KNVideoBase : NSObject

@property (copy, nonatomic) NSString* filename;
@property (copy, nonatomic) NSString* filenameExt;
@property (assign) KNVideoWriterFileType fileType;

- (NSString *)getDocPath;
- (NSString *)videoFileType;
- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
