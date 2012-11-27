//
//  KNFileManager.h
//  ixCamera
//
//  Created by Choi Yeong Hyeon on 12. 11. 28..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNFileManager : NSObject
+ (KNFileManager *)sharedObject;

- (NSString *)documentDirectory;
- (NSString *)cacheDirectory;
- (NSString *)libraryDirectoty;
@end
