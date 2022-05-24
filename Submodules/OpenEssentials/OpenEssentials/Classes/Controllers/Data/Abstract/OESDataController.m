//
//  OESDataController.m
//  OESShared
//
//  Created by Gregory Carter on 9/27/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

// Workflow
//
// startLoadingFeed
//  |- dataControllerWillStart
//  |- startInternalTimer
//  |   `- initiateNextTimer
//  |       `- fetchRemoteFeedTimer
//  |           `- fetchRemoteFeed (1)
//  |- fetchLocalFeed
//  |   `- performFetchLocalFeed
//  |       |- performFetchLocalFeed(Json|Raw)
//  |       |   `- process(Json|Raw)Feed (return YES if processed)
//  |       |- internalFeedLoadDidComplete (2)
//  |       `- fetchRemoteFeed (1)
//  `- dataControllerDidStart

// fetchRemoteFeed (1)
//  |- fetchRemoteFeed(Json|Raw)
//  |- internalFeedLoadDidComplete (2)
//  `- postFeedDidCompleteNotification

// internalFeedLoadDidComplete (2)
//  |- startInternalTimer
//  `- feedLoadDidComplete (return YES to post notification)

//
//  OESDataController.m
//  OESShared
//
//  Created by Gregory Carter on 9/27/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//


#import "OESDataController.h"
#import "NSError+OESAdditions.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#import "OESSBJson.h"
#endif

@interface OESDataController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval currentRefreshInterval;
@property (nonatomic, assign) BOOL stopFeedLoad;
@end

@implementation OESDataController

#pragma mark - [NSObject Overrides]

- (void)dealloc
{
    [self stopLoadingFeed];
}

#pragma mark - Private
#pragma mark -- Feed

- (void)performFetchLocalFeed:(OESNetworkControllerFetchType)fetchType
{
    NSData *data = [self fetchLocalFile];
    
    BOOL wasProcessed = (fetchType == OESNetworkControllerFetchTypeJson ? [self performFetchLocalFeedJson:data] : [self processRawFeed:data]);

    if (wasProcessed) {
        BOOL postNotification = [self internalFeedLoadDidComplete:data];

        if (postNotification)
            [self postFeedDidCompleteNotification];
    } // if
    else {
        OESLogError(@"Unable to process local feed: %@", [self fileName]);
    } // else
    
    [self fetchRemoteFeed];
}

- (BOOL)performFetchLocalFeedJson:(NSData *)data
{
        NSError *error = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
        OESSBJsonParser *parser = [OESSBJsonParser new];
        id object = [parser objectWithData:data];
        if (isNil(object))
            error = [NSError OESError:500 description:parser.error];
#else
        id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
#endif
    
    return [self processJsonFeed:object];
}

- (void)fetchRemoteFeedJson:(NSURL *)url
{
    __weak OESDataController *weakSelf = self;
    [OESDataController fetchRemoteJson:url priority:[self dispatchPriority] timeoutInterval:[self fetchTimeoutInterval] cachePolicy:[self requestCachePolicy] synchronously:[self fetchSynchronously] completionHandler:^(NSData *responseData, id object, NSError *error) {
        BOOL feedOk = !isNil(object) && [weakSelf processJsonFeed:object];

        if (!feedOk) {
            [self internalFeedLoadDidFail:error];
            return;
        } // if
        
        BOOL postNotification = [self internalFeedLoadDidComplete:responseData];
        
        if (postNotification)
            [self postFeedDidCompleteNotification];
    }];
}

- (void)fetchRemoteFeedRaw:(NSURL *)url
{
    __weak OESDataController *weakSelf = self;
    [OESDataController fetchRemoteUrl:url completionHandler:^(NSData *responseData, id object, NSError *error) {
        BOOL feedOk = !isNil(responseData) && [weakSelf processRawFeed:responseData];

        if (!feedOk) {
            [self internalFeedLoadDidFail:error];
            return;
        } // if
        
        BOOL postNotification = [self internalFeedLoadDidComplete:responseData];
        
        if (postNotification)
            [self postFeedDidCompleteNotification];
    }];
}

- (void)fetchRemoteFeedXml:(NSURL *)url
{
    __weak OESDataController *weakSelf = self;
    [OESDataController fetchRemoteXml:url priority:[self dispatchPriority] timeoutInterval:[self fetchTimeoutInterval] cachePolicy:[self requestCachePolicy] synchronously:[self fetchSynchronously] completionHandler:^(NSData *responseData, id object, NSError *error) {
        BOOL feedOk = !isNil(object) && [weakSelf processXmlFeed:object];

        if (!feedOk) {
            [self internalFeedLoadDidFail:error];
            return;
        } // if
        
        BOOL postNotification = [self internalFeedLoadDidComplete:responseData];
        
        if (postNotification)
            [self postFeedDidCompleteNotification];
    }];
}

- (void)fetchRemoteFeed
{
    NSURL *url = [self remoteFeedUrl];
    
    if (isNil(url)) {
        OESLogError(@"Could not find endpoint.");
        return;
    } // if

    // stop the internal timer to prevent dups
    [self.timer invalidate];
    
    OESLogInfo(@"Fetching %@", url);

    switch([self feedType]) {
        case OESNetworkControllerFetchTypeRaw:
            [self fetchRemoteFeedRaw:url];
            break;
        case OESNetworkControllerFetchTypeJson:
            [self fetchRemoteFeedJson:url];
            break;
        case OESNetworkControllerFetchTypeXml:
            [self fetchRemoteFeedXml:url];
            break;
    } // switch
}

- (BOOL)internalFeedLoadDidComplete:(NSData *)data
{
    // restart timer if needed
    [self startInternalTimer];

    return [self feedLoadDidComplete:data];
}

- (void)internalFeedLoadDidFail:(NSError *)error
{
    // restart timer if needed
    [self startInternalTimer];
    
    [self feedLoadDidFail:error];
}

#pragma mark -- Timer Handling

- (void)initiateNextTimer:(NSTimeInterval)refreshInterval
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:refreshInterval
                                        target:self
                                        selector:@selector(fetchRemoteFeedTimer:)
                                        userInfo:nil
                                        repeats:NO];
}

- (void)startInternalTimer
{
    if (self.stopFeedLoad)
        return;
    
    BOOL wasTimerIntervalUpdated = self.currentRefreshInterval != [self refreshInterval];

    if (wasTimerIntervalUpdated) {
        OESLogInfo(@"Update timer interval from %.1f to %.1f for %@? %@", self.currentRefreshInterval, [self refreshInterval], NSStringFromClass([self class]), boolAsString(wasTimerIntervalUpdated));
    } // if
    else
        OESLogInfo(@"Next '%@' refresh in %.1f", NSStringFromClass([self class]), [self refreshInterval]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timer invalidate];
    
        NSTimeInterval refreshInterval = [self refreshInterval];
        self.currentRefreshInterval = refreshInterval;

        if (refreshInterval < 5.0f) {
            OESLogInfo(@"Automatic refresh is disabled for %@, interval: %.1f", NSStringFromClass([self class]), refreshInterval);
            return;
        } // if
    
        [self initiateNextTimer:refreshInterval];
    });
}

- (void)fetchRemoteFeedTimer:(NSTimer *)timer
{
    [self fetchRemoteFeed];
}

#pragma mark - Public
#pragma mark -- Feed

- (void)startLoadingFeed
{
    self.stopFeedLoad = NO;
    
    [self dataControllerWillStart];
    [self startInternalTimer];
    [self fetchLocalFeed];
    [self dataControllerDidStart];
}

- (void)stopLoadingFeed
{
    self.stopFeedLoad = YES;
    [self.timer invalidate];
}

#pragma mark -- Notifications

- (BOOL)shouldPostNotification
{
    return !isNil([self notificationKey]);
}

#pragma mark - {Abstract Methods}
#pragma mark --  Data Controller

- (void)dataControllerWillStart
{
    // abstract method
}

- (void)dataControllerDidStart
{
    // abstract method
}

#pragma mark -- Feed

- (BOOL)feedLoadDidComplete:(NSData *)data
{
    // Abstract call to signal fetch was completed
    // return value directs whether to post notification or not
    return NO;
}

- (void)feedLoadDidFail:(NSError *)error
{
    // Abstract call to signal fetch was completed
}

- (void)fetchLocalFeed
{
    [self performFetchLocalFeed:[self feedType]];
}

- (NSURL *)remoteFeedUrl
{
    OES_THROW_PUREABSTRACT
}

- (long)dispatchPriority
{
    return DISPATCH_QUEUE_PRIORITY_DEFAULT;
}

#pragma mark -- Fetch Synchronously

- (BOOL)fetchSynchronously
{
    return NO;
}

#pragma mark -- Refresh Timer

- (NSTimeInterval)refreshInterval
{
    OES_THROW_PUREABSTRACT
}

#pragma mark -- Notifications

- (NSString *)notificationKey
{
    // notification to post if any
    return nil;
}

- (void)postFeedDidCompleteNotification
{
    if (![self shouldPostNotification])
        return;

    OESLogInfo(@"Posting complete notification for '%@' on file '%@'", NSStringFromClass([self class]), [self fileName]);

    __weak OESDataController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        OESDataController *blockSelf = weakSelf;
        [[NSNotificationCenter defaultCenter] postNotificationName:[blockSelf notificationKey] object:blockSelf.notificationObject];
        blockSelf.notificationObject = nil;
    });
}

#pragma mark -- Processing

- (BOOL)processJsonFeed:(id)object
{
    OES_THROW_PUREABSTRACT
}

- (BOOL)processXmlFeed:(id)object
{
    OES_THROW_PUREABSTRACT
}

- (BOOL)processRawFeed:(NSData *)responseData
{
    OES_THROW_PUREABSTRACT
}

- (OESNetworkControllerFetchType)feedType
{
    return OESNetworkControllerFetchTypeJson;
}

@end

