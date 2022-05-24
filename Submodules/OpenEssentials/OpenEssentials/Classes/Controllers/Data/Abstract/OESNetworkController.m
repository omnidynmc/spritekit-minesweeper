//
//  OESNetworkController.m
//  OpenEssentials
//
//  Created by Gregory Carter on 11/9/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "OESNetworkController.h"
#import "OESXMLReader.h"

static const NSTimeInterval OESNetworkControllerTimeoutInterval = 30.0f;
static const NSURLRequestCachePolicy OESNetworkControllerRequestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

typedef void (^OESNetworkControllerResponseHandler)(NSData *responseData, NSError *error);

@implementation OESNetworkController

#pragma mark - Factory Methods

+ (void)fetchRemoteUrlSynchronously:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy responseHandler:(OESNetworkControllerResponseHandler)responseHandler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    responseHandler(responseData, error);
}


+ (void)fetchRemoteUrl:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy responseHandler:(OESNetworkControllerResponseHandler)responseHandler
{
    dispatch_queue_t queue = dispatch_get_global_queue(priority, 0);
    
    dispatch_async(queue, ^ {
        [[self class] fetchRemoteUrlSynchronously:url priority:priority timeoutInterval:timeoutInterval cachePolicy:cachePolicy responseHandler:responseHandler];
    }); // dispatch_async
}

+ (void)fetchRemoteUrl:(NSURL *)url completionHandler:(OESNetworkControllerCompletionHandler)completionHandler
{
    [OESNetworkController fetchRemoteUrl:url priority:DISPATCH_QUEUE_PRIORITY_DEFAULT timeoutInterval:30.0f cachePolicy:OESNetworkControllerRequestCachePolicy completionHandler:completionHandler];
}

+ (void)fetchRemoteUrl:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy completionHandler:(OESNetworkControllerCompletionHandler)completionHandler
{
    OESNetworkControllerResponseHandler responseHandler = ^(NSData *responseData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(responseData, nil, error); });
    };
    
    [self fetchRemoteUrl:url priority:priority timeoutInterval:timeoutInterval cachePolicy:cachePolicy responseHandler:responseHandler];
}

+ (void)fetchRemoteJson:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy synchronously:(BOOL)synchronously completionHandler:(OESNetworkControllerCompletionHandler)completionHandler
{
    OESNetworkControllerResponseHandler responseHandler = ^(NSData *responseData, NSError *error) {
        NSError *processError = nil;

        id object;
        @try {
            // Stupid apple: If obj will not produce valid JSON, an exception is thrown.
            // This is totally incorrect behavior, it's not a programming error so it should return nil and set processError. LAMESAUCE -gc
            object = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&processError];
        }
        @catch (NSException *exception) {
            OESLogWarn(@"Could not parse json: %@", exception);
            object = nil;
        }

        BOOL wasProcessingError = isNil(object) && isNil(error) && !isNil(processError);
        if (wasProcessingError)
            error = processError;

        if (synchronously) {
            completionHandler(responseData, object, error);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(responseData, object, error); });
        }
    };
    
    if (synchronously) {
        [self fetchRemoteUrlSynchronously:url priority:priority timeoutInterval:timeoutInterval cachePolicy:cachePolicy responseHandler:responseHandler];
    }
    else {
        [self fetchRemoteUrl:url priority:priority timeoutInterval:timeoutInterval cachePolicy:cachePolicy responseHandler:responseHandler];
    }
}

+ (void)fetchRemoteXml:(NSURL *)url priority:(long)priority timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy synchronously:(BOOL)synchronously completionHandler:(OESNetworkControllerCompletionHandler)completionHandler
{
    OESNetworkControllerResponseHandler responseHandler = ^(NSData *responseData, NSError *error) {
        NSError *processError = nil;

        id object = [OESXMLReader objectWithData:responseData error:&processError];
        
        BOOL wasProcessingError = isNil(object) && isNil(error) && !isNil(processError);
        if (wasProcessingError)
            error = processError;
        
        if (synchronously) {
            completionHandler(responseData, object, error);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(responseData, object, error); });
        }
    };
    
    if (synchronously) {
        [self fetchRemoteUrlSynchronously:url priority:priority timeoutInterval:timeoutInterval cachePolicy:cachePolicy responseHandler:responseHandler];
    }
    else {
        [self fetchRemoteUrl:url priority:priority timeoutInterval:timeoutInterval cachePolicy:cachePolicy responseHandler:responseHandler];
    }
}

#pragma mark - {Abstract Methods}

- (NSTimeInterval)fetchTimeoutInterval
{
    return OESNetworkControllerTimeoutInterval;
}

- (NSArray *)trustedHosts
{
    return @[ ];
}

- (NSURLRequestCachePolicy)requestCachePolicy
{
    return OESNetworkControllerRequestCachePolicy;
}

#pragma mark - <NSURLConnectionDelegate>

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
  return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
 
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    if ([[self trustedHosts] containsObject:challenge.protectionSpace.host])
      [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];

    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
