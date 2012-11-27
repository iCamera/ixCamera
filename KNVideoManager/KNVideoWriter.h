//
//  KNVideoWriter.h
//  VideoManagerDemo
//
//  Created by Choi Yeong Hyeon on 12. 10. 2..
//  Copyright (c) 2012년 Choi Yeong Hyeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNVideoBase.h"

@interface KNVideoWriter : KNVideoBase

- (id)initWithFilepath:(NSString *)filepath
              fileType:(KNVideoWriterFileType)type
            resolution:(CGSize)resolution
                   fps:(NSInteger)fps
              duration:(NSInteger)duration;

- (void)writeBuffer:(UIImage *)image
     withCompletion:(void(^)(BOOL finishedByDuration))completion;

- (void)writeFinishWithCompletion:(void(^)(void))completion;

@end
