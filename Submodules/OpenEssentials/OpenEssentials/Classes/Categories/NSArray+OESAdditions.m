//
//  NSArray+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 3/7/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "NSArray+OESAdditions.h"

@implementation NSArray (OESAdditions)

- (BOOL)oesContainsString:(NSString *)string
{
    for(NSString *object in self) {
        if (!isString(object))
            continue;
        
        BOOL isMatch = [object isEqualToString:string];
        if (isMatch)
            return YES;
    } // for

    return NO;
}

@end
