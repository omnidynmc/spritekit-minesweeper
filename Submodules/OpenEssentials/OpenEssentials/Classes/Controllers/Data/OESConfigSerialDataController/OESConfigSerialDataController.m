//
//  OESConfigSerialDataController.m
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESConfigSerialDataController.h"
#import "OESConfigSerial.h"
#import "OESConfig.h"

NSString *const OESConfigSerialDataControllerLoadedNotification = @"OESConfigSerialDataControllerLoadedNotification";

static NSTimeInterval OESConfigSerialDataControllerRefreshDefault = 120.0f;
static NSString *const OESConfigSerialDataControllerFilenameDefault = @"OESConfigSerial.json";

@interface OESConfigSerialDataController ()
@property (nonatomic, copy, readwrite) NSDictionary *updatedSerials;
@property (nonatomic, copy, readwrite) NSDictionary *serials;
@end


@implementation OESConfigSerialDataController

#pragma mark - Private
#pragma mark -- Process

- (BOOL)processJsonFeed:(id)arrayObject
{
    if (!isArray(arrayObject))
        return NO;
 
    NSArray *serialCollection = arrayObject;
 
    NSMutableDictionary *newConfigSerials = [NSMutableDictionary new];
    for(id object in serialCollection) {
        NSError *error = nil;
        NSString *name = [object stringForKey:@"name"];
        
        if (isNil(name)) {
            name = @"unknown";
        }
        
        OESConfigSerial *serial = [OESConfigSerial initWithDictionary:object name:name error:&error];
        
        if (isNil(serial)) {
            OESLogWarn(@"Could not parse OESConfigSerial object: %@, %@", object, error);
            continue;
        }
        
        OESLogDebug(@"Adding object: %@", serial);
        [newConfigSerials setObject:serial forKey:serial.name];
    }

    self.notificationObject = self;

    self.updatedSerials = [self discoverUpdatedSerials:newConfigSerials];
    self.serials = newConfigSerials;

    return YES;
}

- (NSDictionary *)discoverUpdatedSerials:(NSDictionary *)newConfigSerials
{
    BOOL firstRun = self.updatedSerials == nil;
    if (firstRun) {
        return [NSDictionary new];
    }

    // find update config serials
    NSMutableDictionary *updatedSerials = [NSMutableDictionary new];
    for(NSString *key in newConfigSerials) {
        OESConfigSerial *currentConfigSerial = [self.serials objectForKey:key];
        OESConfigSerial *newConfigSerial = [newConfigSerials objectForKey:key];

        BOOL isConfigSerialNewer = currentConfigSerial == nil || [currentConfigSerial isConfigSerialNewer:newConfigSerial];
        if (isConfigSerialNewer == NO) {
            continue;
        } // if
        
        OESLogInfo(@"Discovered updated config serial: %@", newConfigSerial);
        
        [updatedSerials setObject:newConfigSerial forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:updatedSerials];
}

- (BOOL)feedLoadDidComplete:(NSData *)responseData
{
    [self writeNewFile:responseData];
    
    return YES;
}

#pragma mark - Public

- (OESConfigSerial *)fetchSerialByName:(NSString *)name
{
    return [self.serials objectForKey:name];
}

- (NSUInteger)fetchSerialNumberByName:(NSString *)name
{
    OESConfigSerial *configSerial = [self fetchSerialByName:name];
    
    if (configSerial == nil) {
        return NSNotFound;
    }
    
    return configSerial.serial;
}

- (OESConfigSerial *)fetchUpdatedSerialByName:(NSString *)name
{
    return [self.updatedSerials objectForKey:name];
}

- (NSUInteger)fetchUpdatedSerialNumberByName:(NSString *)name
{
    OESConfigSerial *configSerial = [self fetchUpdatedSerialByName:name];
    
    if (configSerial == nil) {
        return NSNotFound;
    }
    
    return configSerial.serial;
}

#pragma mark - [OESDataController Overrides]

- (NSURL *)remoteFeedUrl
{
    //return OESEndpointURL(@"configSerial", @{ });
    return nil;
}

- (NSTimeInterval)refreshInterval
{
    return OESConfigSerialDataControllerRefreshDefault;
}

- (NSString *)notificationKey
{
    return OESConfigSerialDataControllerLoadedNotification;
}

#pragma mark - [OESFileStoreController Overrides]

- (NSString *)fileName
{
    return OESConfigSerialDataControllerFilenameDefault;
}

- (NSBundle *)bundle
{
    return nil;
}

@end
