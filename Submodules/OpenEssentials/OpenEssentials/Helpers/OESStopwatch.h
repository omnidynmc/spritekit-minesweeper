//
//  OESStopwatch.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OESStopwatch : NSObject
@property (nonatomic, assign, getter=isRunning) BOOL running;
// Public
// -- Start/Restart/Stop
- (BOOL)start;
- (BOOL)restart;
- (double)stop;
// -- Inquery
- (double)time;
- (NSUInteger)ms;
- (NSString *)msAsString;
- (NSUInteger)microseconds;
- (NSString *)microsecondsAsString;
@end
