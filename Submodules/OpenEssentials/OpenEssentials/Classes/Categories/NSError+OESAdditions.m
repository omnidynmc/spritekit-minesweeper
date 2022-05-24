//
//  NSError+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "NSError+OESAdditions.h"

@implementation NSError (OESAdditions)
// this does not begin with lower case because it has namespacing
+ (id)OESConfigError:(NSInteger)code description:(NSString *)description
{
    return [self errorWithDomain:@"org.openessentials.config" code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}

// this does not begin with lower case because it has namespacing
+ (id)OESError:(NSInteger)code description:(NSString *)description
{
    return [self errorWithDomain:@"org.openessentials.error" code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}
@end
