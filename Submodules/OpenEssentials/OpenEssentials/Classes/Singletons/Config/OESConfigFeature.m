//
//  OESConfigFeature.m
//  OESShared
//
//  Created by Gregory Carter on 9/5/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigFeature.h"
#import "OESConfigVariable.h"

@implementation OESConfigFeature

#pragma mark - Initialization

+ (id)initWithString:(NSString *)enabled name:(NSString *)name error:(NSError **)error
{
    // handle empty dictionary
    if (!isString(enabled)) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:@"enabled is not a string"];
        return nil;
    } // if
    
    OESConfigObject *object = [self new];

    object.name = name;

    OESConfigObjectValidateType isValid = [object validateVariableForSection:@"modes.features" key:@"enabled" value:enabled error:error validHandler:^(OESConfigVariable *variable) {
        if ([enabled isEqualToString:@"auto"])
            object.enabled = OESConfigObjectEnabledAuto;
        else
            object.enabled = [enabled isEqualToString:@"on"] ? OESConfigObjectEnabledOn : OESConfigObjectEnabledOff;
    }];
  
    if (isValid == OESConfigObjectValidateInvalid) {
        //DELogError(@"DEConfigFeature %@", *error);
        return nil;
    } // if

    // if we couldn't find a validator for it, push it into our options for later
    if (isValid == OESConfigObjectValidateNotFound) {
        return nil;
    } // if

    return object;
}

+ (id)initWithNumber:(NSNumber *)enabled name:(NSString *)name error:(NSError **)error
{
    // handle empty dictionary
    if (!isNumber(enabled)) {
        if (error != NULL)
            *error = [NSError OESError:500 description:@"enabled is not a number"];
        return nil;
    } // if
    
    OESConfigObject *object = [self new];

    object.name = name;
    
    switch([enabled intValue]) {
        case 0:
            object.enabled = OESConfigObjectEnabledOff;
            break;
        case 1:
            object.enabled = OESConfigObjectEnabledOn;
            break;
        default:
            object = nil;
            return nil;
    } // switch

    return object;
}

#pragma mark - OESConfigObject Overrides

- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error
{
    if ([super processUnauthorizedKey:key value:value error:error])
        return YES;

    // it wasn't a section we're interested in so try for variables we know in mode
    // NOTE: Don't use [self validator] here, it would be bad, specify the validator statically
    __block BOOL wasProcessed = YES;
    OESConfigObjectValidateType isValid = [self validateVariableForSection:@"modes.features" key:key value:value error:error validHandler:^(OESConfigVariable *variable) {
            if ([key isEqualToString:@"startDate"])
                self.startDate = [variable parseDate];
            else if ([key isEqualToString:@"endDate"])
                self.endDate = [variable parseDate];
            else
                wasProcessed = NO;
    }];
  
    if (isValid == OESConfigObjectValidateInvalid) {
        OESLogError(@"OESConfigFeature %@", *error);
        return NO;
    } // if

    // if we couldn't find a validator for it, push it into our options for later
    if (isValid == OESConfigObjectValidateNotFound) {
        return NO;
    } // if

    return wasProcessed;
}

- (NSArray *)authorizedKeys
{
    return @[ @"forDevices" ];
}

- (NSString *)validator
{
    return @"modes.features";
}

- (BOOL)storeUnauthorizedKeysInUserInfo
{
    return YES;
}

#pragma mark - NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigFeature name = %@, enabled = %@, active = %@, forDevices = %@, startDate = %@, endDate = %@, userInfo = %@", self.name, [self enabledString], [self isEnabledString], self.forDevices, self.startDate, self.endDate, self.userInfo];
}

@end
