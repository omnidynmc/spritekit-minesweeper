//
//  NSObject+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/14/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "NSObject+OESAdditions.h"

@implementation NSObject (OESAdditions)

- (BOOL)isArray
{
    return [self isKindOfClass:[NSArray class]];
}

- (BOOL)isDictionary
{
    return [self isKindOfClass:[NSDictionary class]];
}

- (BOOL)isString
{
    return [self isKindOfClass:[NSString class]];
}

- (BOOL)isNumber
{
    return [self isKindOfClass:[NSNumber class]];
}

@end
