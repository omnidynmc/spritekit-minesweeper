//
//  OESFileStoreController.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

//
//  OESJsonDataManager.m
//  OESShared
//
//  Created by Gregory Carter on 9/20/12.
//  Copyright (c) 2012 OpenEssentials, Inc. All rights reserved.
//

#import "OESFileStoreController.h"

@implementation OESFileStoreController

#pragma mark - Factory Methods

+ (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents
{
    OESLogInfo(@"Writing file: %@", path);
    BOOL fileWrittenSuccessfully = [[NSFileManager defaultManager] createFileAtPath:path contents:contents attributes:nil];
    return fileWrittenSuccessfully;
}

#pragma mark - Public

+ (BOOL)copyFileFromBundleToLibrary:(NSString *)filename destination:(NSString *)destination bundle:(NSBundle *)bundle
{
    NSString *bundlePath = [[bundle resourcePath] stringByAppendingPathComponent:filename];
    OESLogInfo(@"Copying file from bundle '%@' to library '%@'", bundlePath, destination);

    NSError *error = nil;

    BOOL fileWasCopied = [[NSFileManager defaultManager] copyItemAtPath:bundlePath
                                                                 toPath:destination
                                                                  error:&error];
    if (!fileWasCopied) {
        OESLogError(@"Could not copy file '%@' to documents: %@", filename, error);
        return NO;
    } // if
    
    return YES;
}

- (BOOL)fileExists
{
    OESLogInfo(@"Looking for file in Library: %@", [self libraryFilePath]);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self libraryFilePath]];
    return fileExists;
}

- (BOOL)writeNewFile:(NSData *)data
{
    return [OESFileStoreController createFileAtPath:[self libraryFilePath] contents:data];
}

+ (NSString *)libraryDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *)libraryFilePath
{
    return [[OESFileStoreController libraryDirectory] stringByAppendingPathComponent:[self fileName]];
}

#pragma mark -- Abstract Methods

- (NSString *)fileName
{
    OES_THROW_PUREABSTRACT
}

- (BOOL)loadFileFromBundle
{
    return NO;
}

- (NSBundle *)bundle
{
    return [NSBundle bundleForClass:[self class]];
}

#pragma mark -- Local File

- (NSData *)fetchLocalFile
{
    NSString *path = [self libraryFilePath];

    BOOL loadFileFromBundle = [self loadFileFromBundle];
    if (!loadFileFromBundle) {
        BOOL doesFileExist = [self fileExists];

        OESLogInfo(@"Found file at '%@'? %@", [self libraryFilePath], boolAsString(doesFileExist));

        if (!doesFileExist) {
            // copy config from bundle
            BOOL fileWasCopied = [OESFileStoreController copyFileFromBundleToLibrary:[self fileName] destination:[self libraryFilePath] bundle:[self bundle]];
            if (!fileWasCopied) {
#ifdef DEBUG
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                reason:@"Could not copy file from bundle to Library"
                                 userInfo:nil];
#else
                OESLogError(@"Could not copy '%@' to Library", [self fileName]);
                return nil;
#endif
            } // if
        } // if
    } // if
    else
        path = [[[self bundle] resourcePath] stringByAppendingPathComponent:[self fileName]];

    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    if (isNil(data)) {
#ifdef DEBUG
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                             reason:[NSString stringWithFormat:@"Could not read file from Library: %@", [self libraryFilePath]]
                                           userInfo:nil];
#else
        return nil;
#endif
    } // if

    return data;
}

@end
