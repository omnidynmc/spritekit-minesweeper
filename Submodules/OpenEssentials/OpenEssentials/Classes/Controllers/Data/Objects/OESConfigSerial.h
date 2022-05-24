//
//  OESConfigSerial.h
//  OpenEssentials
//
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESDynamicObject.h"

@interface OESConfigSerial : OESDynamicObject
@property (nonatomic, assign, readonly) NSUInteger serial;
@property (nonatomic, assign, readonly) NSUInteger jitter;
- (BOOL)isConfigSerialNewer:(OESConfigSerial *)newConfigSerial;
@end
