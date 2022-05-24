//
//  OESConfigDatatypeParser.m
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigDatatypeParser.h"
#import "OESConfigDatatype.h"

@implementation OESConfigDatatypeParser

#pragma mark - OESConfigParser Overrides

- (BOOL)processDictionaryFromConfig:(NSDictionary *)dictionary
{
    NSError *error;
    for(NSString *key in dictionary) {
        NSDictionary *object = [dictionary objectForKey:key];
        OESConfigDatatype *datatype = [OESConfigDatatype initWithDictionary:object name:key error:&error];
        if (datatype == nil) {
            OESLogError(@"Could not parse variable type for key %@: %@", key, error);
            continue;
        } // if

        OESLogDebug(@"Result %@", datatype);
        [self.objects setObject:datatype forKey:datatype.name];
    } // for

    return YES;
}
@end
