//
//  OESFileStoreController.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OESFileStoreControllerSuccessHandler)(NSData *);
typedef void (^OESFileStoreControllerFailHandler)(NSError *);

@interface OESFileStoreController : NSObject
// Factory Methods
+ (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents;

// Public Methods
+ (BOOL)copyFileFromBundleToLibrary:(NSString *)filename destination:(NSString *)destination bundle:(NSBundle *)bundle;
- (BOOL)fileExists;
+ (NSString *)libraryDirectory;
- (NSString *)libraryFilePath;
- (BOOL)writeNewFile:(NSData *)data;

// -- Abstract
- (NSString *)fileName;
- (NSBundle *)bundle;
- (BOOL)loadFileFromBundle;

// -- Local File
- (NSData *)fetchLocalFile;

@end
