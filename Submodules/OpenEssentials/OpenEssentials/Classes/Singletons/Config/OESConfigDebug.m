//
//  OESConfigDebug.m
//  OESShared
//
//  Created by Gregory Carter on 9/25/12.
//  Copyright (c) 2012 OpenEssentials, Inc. All rights reserved.
//

#import "OESConfigDebug.h"
#import "OESConfigVariable.h"

@implementation OESConfigDebug

- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error
{
    if ([super processUnauthorizedKey:key value:value error:error])
        return YES;

    OESLogDebug(@"Unauthorized key '%@' with value '%@'", key, value);


    // it wasn't a section we're interested in so try for variables we know in mode
    __block BOOL wasProcessed = YES;
    OESConfigObjectValidateType isValid = [self validateVariableForSection:@"debug" key:key value:value error:error validHandler:^(OESConfigVariable *variable) {
            if ([key isEqualToString:@"deviceDate"])
                self.deviceDate = [variable parseDate];
            else
                // if we did nothing, allow a subclass to handle it
                wasProcessed = NO;
    }];

    if (isValid == OESConfigObjectValidateInvalid) {
        OESLogError(@"OESConfigMode %@", !isDerefNil(error) ? *error : @"(unknown error)");
        return NO;
    } // if
    
    if (isValid == OESConfigObjectValidateNotFound)
        return NO;
    
    return wasProcessed;
}

- (NSArray *)authorizedKeys
{
    return @[ ];
}

#pragma mark - NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigDebug name = %@, deviceDate = %@", self.name, self.deviceDate];
}

@end
