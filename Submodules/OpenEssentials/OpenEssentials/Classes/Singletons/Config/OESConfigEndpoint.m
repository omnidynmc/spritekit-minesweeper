//
//  OESConfigEndpoint.m
//  OESShared
//
//  Created by Gregory Carter on 9/5/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigEndpoint.h"
#import "OESConfigVariable.h"

@implementation OESConfigEndpoint

#pragma mark - Initialization

+ (id)initWithString:(NSString *)url name:(NSString *)name error:(NSError **)error
{
    // handle empty dictionary
    if (!isString(url)) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:@"url is not a string"];
        return nil;
    } // if
    
    OESConfigEndpoint *object = [self new];

    object.name = name;

    OESConfigObjectValidateType isValid = [object validateVariableForSection:@"modes.endpoints" key:@"url" value:url error:error validHandler:^(OESConfigVariable *variable) {
        object.url = url;
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

#pragma mark - OESConfigObject Overrides

- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error
{

    if ([super processUnauthorizedKey:key value:value error:error])
        return YES;
 
    // it wasn't a section we're interested in so try for variables we know in mode
    // NOTE: Don't use [self validator] here, it would be bad, specify the validator statically
    OESConfigObjectValidateType isValid = [self validateVariableForSection:@"modes.endpoints" key:key value:value error:error validHandler:^(OESConfigVariable *variable) {
            if ([key isEqualToString:@"startDate"])
                self.startDate = [variable parseDate];
            else if ([key isEqualToString:@"endDate"])
                self.endDate = [variable parseDate];
            else if ([key isEqualToString:@"url"])
                self.url = [NSURL URLWithString:value];
       }];

    if (isValid == OESConfigObjectValidateInvalid) {
        OESLogError(@"OESConfigFeature %@", *error);
        return NO;
    } // if

    if (isValid == OESConfigObjectValidateNotFound) {
        return NO;
    } // if

    return YES;
}

- (NSArray *)authorizedKeys
{
    return @[ @"url", @"serial", @"refreshInterval", @"forDevices" ];
}

- (NSString *)validator
{
    return @"modes.endpoints";
}

#pragma mark - NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigEndpoint name = %@, enabled = %@, active = %@, forDevices = %@, url = %@, serial = %@, refreshInterval = %@, userInfo = %@", self.name, [self enabledString], [self isEnabledString], self.forDevices, self.url, self.serial, self.refreshInterval, self.userInfo];
}

@end
