//
//  OESNetworkController.h
//  OpenEssentials
//
//  Created by Gregory Carter on 11/9/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESFileStoreController.h"

typedef enum {
    OESNetworkControllerFetchTypeRaw = 0,
    OESNetworkControllerFetchTypeJson = 1,
    OESNetworkControllerFetchTypeXml = 2
} OESNetworkControllerFetchType;

// The completion and failure blocks are dispatched on the main queue
typedef void (^OESNetworkControllerCompletionHandler)(NSData *data, id topLevelObject, NSError *error);
typedef void (^OESNetworkControllerSuccessHandler)(NSData *data);
typedef void (^OESNetworkControllerJsonSuccessHandler)(id topLevelObject, NSData *responseData);
typedef void (^OESNetworkControllerFailHandler)(NSError *error);

@interface OESNetworkController : OESFileStoreController <NSURLConnectionDelegate>
+ (void)fetchRemoteUrl:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy completionHandler:(OESNetworkControllerCompletionHandler)completionHandler;
+ (void)fetchRemoteUrl:(NSURL *)url completionHandler:(OESNetworkControllerCompletionHandler)completionHandler;
+ (void)fetchRemoteJson:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy synchronously:(BOOL)synchronously completionHandler:(OESNetworkControllerCompletionHandler)completionHandler;
+ (void)fetchRemoteXml:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy synchronously:(BOOL)synchronously completionHandler:(OESNetworkControllerCompletionHandler)completionHandler;
// Abstract Methods
- (NSTimeInterval)fetchTimeoutInterval;
- (NSArray *)trustedHosts;
- (NSURLRequestCachePolicy)requestCachePolicy;
@end
