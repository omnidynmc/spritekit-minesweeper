//
//  OESConfigManager.h
//  OESShared
//
//  Created by Gregory Carter on 9/20/12.
//  Copyright (c) 2012 OpenEssentials, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OESConfigManagerSuccessHandler)(NSData *);
typedef void (^OESConfigManagerFailHandler)(NSError *);

@interface OESConfigManager : NSObject
// Factory Methods
+ (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents;

// Public Methods
- (BOOL)copyFileFromBundleToLibrary:(NSString *)filename bundle:(NSBundle *)bundle;
- (BOOL)configFileExists;
+ (NSString *)libraryDirectory;
- (NSString *)libraryConfigPath;
- (BOOL)writeNewConfig:(NSData *)data;
- (void)removeConfigFromLibrary;

// -- Abstract
- (NSString *)configName;
- (NSBundle *)bundle;

// -- Local Config
- (NSData *)fetchLocalConfig;

// -- Remote Config
+ (void)fetchRemoteConfig:(NSURL *)url successHandler:(OESConfigManagerSuccessHandler)successHandle failHandler:(OESConfigManagerFailHandler)failHandler;
@end
