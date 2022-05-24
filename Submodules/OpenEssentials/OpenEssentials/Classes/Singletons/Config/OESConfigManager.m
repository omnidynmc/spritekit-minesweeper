//
//  OESConfigManager.m
//  OESShared
//
//  Created by Gregory Carter on 9/20/12.
//  Copyright (c) 2012 OpenEssentials, Inc. All rights reserved.
//

#import "OESConfigManager.h"
#import "OESConfigException.h"

static NSString *OESConfigManagerVersionUserDefaultsKey = @"OESConfigManagerVersionUserDefaultsKey";

@implementation OESConfigManager

#pragma mark - Factory Methods

+ (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents
{
    BOOL fileWrittenSuccessfully = [[NSFileManager defaultManager] createFileAtPath:path contents:contents attributes:nil];
    return fileWrittenSuccessfully;
}

#pragma mark - Public

- (BOOL)removeFileFromLibrary:(NSString *)filename
{
    NSString *libraryPath = [self libraryConfigPath];
    OESLogInfo(@"Removing file from library '%@'", libraryPath);

    NSError *error = nil;

    BOOL fileWasCopied = [[NSFileManager defaultManager] removeItemAtPath:libraryPath
                                                                  error:&error];
    if (!fileWasCopied) {
        OESLogError(@"Could not copy file '%@' to documents: %@", filename, error);
        return NO;
    } // if
    
    return YES;
}

- (BOOL)copyFileFromBundleToLibrary:(NSString *)filename bundle:(NSBundle *)bundle
{
    NSString *bundlePath = [[bundle resourcePath] stringByAppendingPathComponent:filename];
    NSString *libraryPath = [self libraryConfigPath];
    OESLogInfo(@"Copying file from bundle '%@' to library '%@'", bundlePath, libraryPath);

    NSError *error = nil;

    BOOL fileWasCopied = [[NSFileManager defaultManager] copyItemAtPath:bundlePath
                                                                 toPath:libraryPath
                                                                  error:&error];
    if (!fileWasCopied) {
        OESLogError(@"Could not copy file '%@' to Library: %@", filename, error);
        return NO;
    } // if
    
    return YES;
}

- (BOOL)configFileExists
{
    OESLogInfo(@"Looking for config in Library: %@", [self libraryConfigPath]);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self libraryConfigPath]];
    return fileExists;
}

- (BOOL)writeNewConfig:(NSData *)data
{
    return [OESConfigManager createFileAtPath:[self libraryConfigPath] contents:data];
}

+ (NSString *)libraryDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *)libraryConfigPath
{
    return [[OESConfigManager libraryDirectory] stringByAppendingPathComponent:[self configName]];
}

#pragma mark -- Abstract Methods

- (NSString *)configName
{
    return @"OESConfig.json";
}

- (NSBundle *)bundle
{
    return [NSBundle bundleForClass:[self class]];
}

#pragma mark -- Local Config

- (NSData *)fetchLocalConfig
{
    BOOL doesConfigExist = [self configFileExists];

    // pull NSUserDefaults for the current version
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [userDefaults objectForKey:OESConfigManagerVersionUserDefaultsKey];

    BOOL wasAppUpdated = !isString(lastVersion)
                        || ![self isAppVersion:lastVersion];
    
    if (doesConfigExist && wasAppUpdated) {
        OESLogWarn(@"Detected app update, overwriting Library confg with bundled config: %@", lastVersion);
        [self removeConfigFromLibrary];

        doesConfigExist = NO;
    }

    OESLogInfo(@"Found config at '%@'? %@", [self libraryConfigPath], boolAsString(doesConfigExist));

    if (!doesConfigExist) {
        // copy config from bundle
        BOOL fileWasCopied = [self copyFileFromBundleToLibrary:[self configName] bundle:[self bundle]];
        if (!fileWasCopied) {
#ifdef DEBUG
            @throw [OESConfigException exceptionWithName:NSInternalInconsistencyException
                            reason:@"Could not copy config from bundle to documents"
                             userInfo:nil];
#else
            return nil;
#endif
        } // if
    } // if
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[self libraryConfigPath]];
    if (isNil(data)) {
#ifdef DEBUG
        @throw [OESConfigException exceptionWithName:NSInternalInconsistencyException
                                             reason:[NSString stringWithFormat:@"Could not read config from documents: %@", [self libraryConfigPath]]
                                           userInfo:nil];
#else
        return nil;
#endif
    } // if

    return data;
}

- (BOOL)isAppVersion:(NSString *)version
{
    NSNumber *appVersion = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    

    BOOL isAtVersion = [[appVersion stringValue] isEqualToString:version];
    
    return isAtVersion;
}

- (void)removeConfigFromLibrary
{
    [self removeFileFromLibrary:[self configName]];
}

#pragma mark -- Remote Config

+ (void)fetchRemoteConfig:(NSURL *)url successHandler:(OESConfigManagerSuccessHandler)successHandler failHandler:(OESConfigManagerFailHandler)failHandler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^ {
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
        NSError *error = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
        if (isNil(response)) {
            failHandler(error);
            return;
        } // if

        successHandler(response);
    }); // dispatch_async
}

@end
