//
//  NSDictionary+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "NSDictionary+OESAdditions.h"

@implementation NSDictionary (OESAdditions)

// Using valueForKeyPath is reportedly slower than drilling down with objectForKey
- (NSDictionary *)valueForDotPath:(NSString *)dotPath
{
    if (isEmpty(dotPath))
        return nil;

    NSMutableArray *dotPathArray = [NSMutableArray arrayWithArray:[dotPath componentsSeparatedByString:@"."]];

    NSDictionary *current = self;

    while([dotPathArray count]) {
        current = [current objectForKey:[dotPathArray objectAtIndex:0]];

        if (isEmpty(current))
            return nil;

        [dotPathArray removeObjectAtIndex:0];
    } // while

    return current;
}

- (NSNumber *)numberForDotPath:(NSString *)dotPath
{
    id object = [self valueForDotPath:dotPath];

    if (!isNumber(object))
        return nil;
    
    return object;
}

- (NSNumber *)numberForKey:(NSString *)key
{
    id object = [self objectForKey:key];

    if (!isNumber(object))
        return nil;
    
    return object;
}

- (NSString *)stringForDotPath:(NSString *)dotPath
{
    id object = [self valueForDotPath:dotPath];

    if (!isString(object))
        return nil;
    
    return object;
}

- (NSString *)stringForKey:(NSString *)key
{
    id object = [self objectForKey:key];

    if (!isString(object))
        return nil;
    
    return object;
}

- (NSArray *)arrayForDotPath:(NSString *)dotPath
{
    id object = [self valueForDotPath:dotPath];

    if (!isArray(object))
        return nil;
    
    return object;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    id object = [self objectForKey:key];

    if (!isArray(object))
        return nil;
    
    return object;
}

- (NSDictionary *)dictionaryForDotPath:(NSString *)dotPath
{
    id object = [self valueForDotPath:dotPath];

    if (!isDictionary(object))
        return nil;
    
    return object;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    id object = [self objectForKey:key];

    if (!isDictionary(object))
        return nil;
    
    return object;
}
@end
