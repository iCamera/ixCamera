//
//  KNVideoBase.m
//  MediaAccelatorDemo
//
//  Created by cyh on 12. 11. 16..
//  Copyright (c) 2012년 cyh. All rights reserved.
//

#import "KNVideoBase.h"


@implementation KNVideoBase

@synthesize filepath        = _filepath;
@synthesize filename        = _filename;
@synthesize filenameExt     = _filenameExt;
@synthesize fileType        = _fileType;

- (id)init {
    self = [super init];
    if (self) {
        
        @try {
            NSArray* filepathcomp = [_filepath componentsSeparatedByString:@"/"];
            NSString* name = [filepathcomp lastObject];
            
            NSArray* filenamecomp = [name componentsSeparatedByString:@"."];
            self.filename = [filenamecomp objectAtIndex:0];
            self.filepath = [filenamecomp objectAtIndex:1];
        }
        @catch (NSException *exception) {
            NSLog(@"%s %@", __func__, [exception description]);
        }
    }
    return self;
}


- (NSString *)videoFileType {
    
    NSString* type = nil;
    
    switch (_fileType) {
        case kKNVideoWriterFileTypeMP4:
            type = AVFileTypeMPEG4;
            self.filenameExt = @"mp4";
            break;
            
        case kKNVideoWriterFileTypeM4V:
            type = AVFileTypeAppleM4V;
            self.filenameExt = @"m4v";
            break;
            
        default:
            type = AVFileTypeQuickTimeMovie;
            self.filenameExt = @"mov";
            break;
    }
    return type;
}

- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width,
                                                    height,
                                                    8,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    return newImage;
}

@end
