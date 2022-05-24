//
//  OESerialNumberDataController.m
//  OpenEssentials
//
//  Created by Gregory Carter on 2/18/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESSerialNumberDataController.h"
#import "OESSerialNumber.h"

NSString *const OESSerialNumberDataControllerLoadedNotification = @"OESSerialNumberDataControllerLoadedNotification";

static NSTimeInterval OESSerialNumberDataControllerRefreshDefault = 120.0f;
static NSString *const OESSerialNumberDataControllerFilenameDefault = @"OESSerialNumbers.json";

@interface OESSerialNumberDataController ()
@property (nonatomic, strong) NSArray *serialNumbers;
@end

@implementation OESSerialNumberDataController

#pragma mark - [OESDataController Overrides]
#pragma mark -- Process

- (BOOL)processJsonFeed:(id)object
{
    if (!isArray(object))
        return NO;

    NSArray *array = object;
 
    NSMutableArray *objects = [NSMutableArray new];
    for(id object in array) {
        NSError *error = nil;
        OESSerialNumber *serialNumber = [OESSerialNumber initWithDictionary:object name:@"OESSerialNumber" error:&error];
        
        if (isNil(serialNumber)) {
            OESLogWarn(@"Could not parse OESSerialNumber object: %@, %@", object, error);
            continue;
        } // if
        
        OESLogDebug(@"Adding object: %@", serialNumber);

        [objects addObject:serialNumber];
    } // for

    self.serialNumbers = [NSArray arrayWithArray:objects];

    return YES;
}

- (BOOL)feedLoadDidComplete:(NSData *)responseData
{
    [self writeNewFile:responseData];

    self.notificationObject = [self.serialNumbers copy];

    return YES;
}

- (NSURL *)remoteFeedUrl
{
    OES_THROW_PUREABSTRACT;
}

- (NSTimeInterval)refreshInterval
{
    return OESSerialNumberDataControllerRefreshDefault;
}

- (NSString *)notificationKey
{
    return OESSerialNumberDataControllerLoadedNotification;
}

- (NSString *)fileName
{
    return OESSerialNumberDataControllerFilenameDefault;
}

#pragma mark - Public

- (OESSerialNumber *)fetchSerialNumberForEndpoint:(NSString *)endpoint
{
    for(OESSerialNumber *serialNumber in self.serialNumbers) {
        BOOL isMatch = [serialNumber isEqualToEndpoint:endpoint];
        if (isMatch)
            return serialNumber;
    } // for

    return nil;
}

- (NSUInteger)fetchSerialNumberValueForEndpoint:(NSString *)endpoint
{
    OESSerialNumber *serialNumber = [self fetchSerialNumberForEndpoint:endpoint];
    return !isNil(serialNumber) ? serialNumber.serial : NSNotFound;
}

#pragma mark - [Accessor Overrides]

- (NSArray *)serialNumbers
{
    return !isNil(_serialNumbers) ? _serialNumbers : (_serialNumbers = [NSArray new]);
}

@end
