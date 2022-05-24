//
//  OESSerialNumber.m
//  OpenEssentials
//
//  Created by Gregory Carter on 2/18/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESSerialNumber.h"

@interface OESSerialNumber ()
@property (nonatomic, strong, readwrite) NSNumber *serialString;
@property (nonatomic, strong, readwrite) NSString *endpoint;
@property (nonatomic, assign, readwrite) NSUInteger serial;
@end

@implementation OESSerialNumber

- (NSDictionary *)authorizedKeys
{
    return @{
        @"serial": @{ @"mapTo": @"serialString" },
        @"endpoint": @{ }
    };
}

- (BOOL)initWithDictionaryDidComplete:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error
{
    self.serial = [self.serialString integerValue];
    self.serialString = nil;
    
    return YES;
}

#pragma mark - Public

- (BOOL)isEqualToEndpoint:(NSString *)endpoint
{
    return [[endpoint lowercaseString] isEqualToString:[self.endpoint lowercaseString]];
}

#pragma mark - [Accessor Overrides]

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESSerialNumber name = %@, endpoint = %@, serial = %d", self.name, self.endpoint, self.serial];
}

@end
