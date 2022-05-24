//
//  OESConfigApp.m
//  OESShared
//
//  Created by Gregory Carter on 9/7/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigApp.h"

@implementation OESConfigApp

#pragma mark - Overrides
#pragma mark -- OESConfigObject

- (NSArray *)authorizedKeys
{
    return @[ @"mode", @"minimumVersion", @"latestVersion", @"forceLoad", @"serial", @"refreshInterval" ];
}

- (BOOL)isAppMinimumVersion
{
    return [self.minimumVersion doubleValue] <= [self.appVersion doubleValue];
}

- (BOOL)isAppLatestVersion
{
    return [self.latestVersion doubleValue] == [self.appVersion doubleValue];
}

- (BOOL)isConfigNewer:(OESConfigApp *)newApp
{
    BOOL shouldForceLoad = [newApp shouldForceLoad];

    if (shouldForceLoad)
        OESLogWarn(@"Force loading: %@", self);

    return isNil(self.serial)
            || [self.serial intValue] < [newApp.serial intValue]
            || shouldForceLoad;
}

- (BOOL)shouldForceLoad
{
    return !isNil(self.forceLoad) && [self.forceLoad intValue] == 1;
}

#pragma mark -- NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigApp name = %@, mode = %@, forceLoad = %@, serial = %@, refreshInterval = %@, appVersion = %f, minimumVersion = %f, latestVersion = %f", self.name, self.mode, self.forceLoad, self.serial, self.refreshInterval, [self.appVersion doubleValue], [self.minimumVersion doubleValue], [self.latestVersion doubleValue]];
}

@end
