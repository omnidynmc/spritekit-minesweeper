//
//  OESConfigApp.h
//  OESShared
//
//  Created by Gregory Carter on 9/7/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigObject.h"

@interface OESConfigApp : OESConfigObject
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSNumber *appVersion;
@property (nonatomic, strong) NSNumber *minimumVersion;
@property (nonatomic, strong) NSNumber *latestVersion;
@property (nonatomic, strong) NSNumber *serial;
@property (nonatomic, strong) NSNumber *refreshInterval;
@property (nonatomic, strong) NSNumber *forceLoad;

- (BOOL)isAppMinimumVersion;
- (BOOL)isAppLatestVersion;
- (BOOL)isConfigNewer:(OESConfigApp *)newApp;
- (BOOL)shouldForceLoad;
@end
