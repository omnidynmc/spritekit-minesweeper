//
//  OESerialNumberDataController.h
//  OpenEssentials
//
//  Created by Gregory Carter on 2/18/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESDataController.h"

extern NSString *const OESSerialNumberDataControllerLoadedNotification;

@class OESSerialNumber;

@interface OESSerialNumberDataController : OESDataController
- (OESSerialNumber *)fetchSerialNumberForEndpoint:(NSString *)endpoint;
- (NSUInteger)fetchSerialNumberValueForEndpoint:(NSString *)endpoint;
@end
