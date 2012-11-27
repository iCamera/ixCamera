//
//  KNFileManager.m
//  ixCamera
//
//  Created by Choi Yeong Hyeon on 12. 11. 28..
//  Copyright (c) 2012년 cyh3813. All rights reserved.
//

#import "KNFileManager.h"

static KNFileManager* gInstance = nil;
@implementation KNFileManager

+ (KNFileManager *)sharedObject {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gInstance = [[KNFileManager alloc] init];
    });
    return gInstance;
}

- (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    return cacheDirectory;
}

- (NSString *)libraryDirectoty {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libDirectory = [paths objectAtIndex:0];
    return libDirectory;
}

@end
