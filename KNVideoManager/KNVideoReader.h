//
//  KNVideoReader.h
//  MediaAccelatorDemo
//
//  Created by cyh on 12. 11. 16..
//  Copyright (c) 2012년 cyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNVideoBase.h"

@interface KNVideoReader : KNVideoBase
- (id)initWithFilename:(NSString *)filename;
- (void)readBufferBlock:(void(^)(id buff))completion;
- (void)readFinish;

@end
