//
//  OESConfigSerial.m
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESConfigSerial.h"

static NSUInteger OESConfigSerialDataControllerMinJitterDefault  = 60.0f;
static NSUInteger OESConfigSerialDataControllerMaxJitterDefault  = 300.0f;

@interface OESConfigSerial ()
@property (nonatomic, strong) NSNumber *serialNumber;
@property (nonatomic, strong) NSNumber *minJitterNumber;
@property (nonatomic, strong) NSNumber *maxJitterNumber;
@property (nonatomic, assign, readwrite) NSUInteger serial;
@property (nonatomic, assign, readwrite) NSUInteger minJitter;
@property (nonatomic, assign, readwrite) NSUInteger maxJitter;
@end

@implementation OESConfigSerial

- (NSDictionary *)authorizedKeys
{
    return @{
        @"name": @ { },
        @"minJitter": @{ @"mapTo": @"minJitterNumber" },
        @"maxJitter": @{ @"mapTo": @"maxJitterNumber" },
        @"serial": @{ @"mapTo": @"serialNumber" }
    };
}

- (BOOL)initWithDictionaryDidComplete:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error
{
    self.serial = [self.serialNumber integerValue];
    self.minJitter = [self.minJitterNumber integerValue];
    self.maxJitter = [self.maxJitterNumber integerValue];

    self.serialNumber = nil;
    self.minJitterNumber = nil;
    self.maxJitterNumber = nil;
    
    return YES;
}

#pragma mark - Public

- (BOOL)isConfigSerialNewer:(OESConfigSerial *)newConfigSerial
{
    return self.serial < newConfigSerial.serial;
}

- (NSUInteger)jitter
{
    if (_maxJitter == 0) {
        _maxJitter = OESConfigSerialDataControllerMaxJitterDefault;
    }

    if (_minJitter >= _maxJitter) {
        _minJitter = OESConfigSerialDataControllerMinJitterDefault;
        _maxJitter = OESConfigSerialDataControllerMaxJitterDefault;
    }

    return arc4random_uniform(_maxJitter - _minJitter) + _minJitter;
}

#pragma mark - [NSObject Overrides]

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigSerial name = %@, serial = %d, jitter = %d", self.name, self.serial, self.jitter];
}

@end
