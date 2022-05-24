//
//  OESSerialNumber.h
//  OpenEssentials
//
//  Created by Gregory Carter on 2/18/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESDynamicObject.h"

@interface OESSerialNumber : OESDynamicObject
@property (nonatomic, strong, readonly) NSString *endpoint;
@property (nonatomic, assign, readonly) NSUInteger serial;
- (BOOL)isEqualToEndpoint:(NSString *)endpoint;
@end
