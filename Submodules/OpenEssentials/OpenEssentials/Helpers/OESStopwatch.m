//
//  OESStopwatch.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OESStopwatch.h"

@interface OESStopwatch ()
@property (nonatomic, assign) double currentTime;
@end

@implementation OESStopwatch

- (id)init
{
    if (self = [super init]) {
        self.running = NO;
    } // if

    return self;
}

#pragma mark - Public
#pragma mark -- Start/Restart/Stop

- (BOOL)start
{
    if (self.isRunning)
        return NO;
        
    self.currentTime = [self now];
    self.running = YES;

    return YES;
}

- (BOOL)restart
{
    BOOL wasRunning = self.isRunning;

    if (self.isRunning)
        self.running = NO;
        
    [self start];
    
    return wasRunning;
}

- (double)stop
{
    return self.isRunning ? [self diff] : -1.0;
}

#pragma mark -- Inquery

- (double)time
{
    return [self diff];
}

- (NSUInteger)ms
{
    return round([self diff] * 1000.0);
}

- (NSString *)msAsString
{
    return [NSString stringWithFormat:@"%d ms", [self ms]];
}

- (NSUInteger)microseconds
{
    return round([self diff] * 10000.0);
}

- (NSString *)microsecondsAsString
{
    return [NSString stringWithFormat:@"%d microseconds", [self microseconds]];
}

#pragma mark - Private

- (double)now
{
    return CACurrentMediaTime();
}

- (double)diff
{
    return [self now] - [self currentTime];
}

@end
