//
//  OESConfigSerialDataController.h
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESDataController.h"

extern NSString *const OESConfigSerialDataControllerLoadedNotification;

@class OESConfigSerial;

@interface OESConfigSerialDataController : OESDataController
@property (nonatomic, copy, readonly) NSDictionary *updatedSerials;
@property (nonatomic, copy, readonly) NSDictionary *serials;
- (OESConfigSerial *)fetchSerialByName:(NSString *)name;
- (NSUInteger)fetchSerialNumberByName:(NSString *)name;
- (OESConfigSerial *)fetchUpdatedSerialByName:(NSString *)name;
- (NSUInteger)fetchUpdatedSerialNumberByName:(NSString *)name;
@end
