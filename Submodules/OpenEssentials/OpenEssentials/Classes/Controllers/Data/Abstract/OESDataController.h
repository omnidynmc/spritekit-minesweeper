//
//  OESDataController.h
//  OESShared
//
//  Created by Gregory Carter on 9/27/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OESNetworkController.h"

@interface OESDataController : OESNetworkController
@property (nonatomic, strong) id notificationObject;


// Abstract
// -- Data Controller
- (void)dataControllerWillStart;
- (void)dataControllerDidStart;
// -- Feed
- (void)fetchLocalFeed;
- (void)fetchRemoteFeed;
- (long)dispatchPriority;
- (OESNetworkControllerFetchType)feedType;
- (NSURL *)remoteFeedUrl;
- (BOOL)feedLoadDidComplete:(NSData *)data;
- (void)feedLoadDidFail:(NSError *)error;
// -- Refresh Timer
- (NSTimeInterval)refreshInterval;
// -- Notifications
- (NSString *)notificationKey;
- (void)postFeedDidCompleteNotification;
// -- Processing
- (BOOL)processJsonFeed:(id)object;
- (BOOL)processRawFeed:(NSData *)responseData;
- (BOOL)processXmlFeed:(id)object;

// Public
- (void)startLoadingFeed;
- (void)stopLoadingFeed;
- (BOOL)shouldPostNotification;
@end
