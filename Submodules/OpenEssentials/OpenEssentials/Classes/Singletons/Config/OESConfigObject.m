//
//  OESConfigObject.m
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//

#import "OESConfigObject.h"
#import "OESConfigException.h"
#import "OESConfig.h"
#import "OESConfigVariableParser.h"
#import "OESConfigVariable.h"

@interface OESConfigObject ()
@end

@implementation OESConfigObject

#pragma mark - Factory Methods

// We're going to run through the dictionary and attempt to do something with all of the keys.
// All subclasses must implement "authorizedKeys" which is what tells this parser what keys
// to attempt to store automatically (as a safeguard) into class instance variables. Everything else gets placed
// in the userInfo dictionary that is not processed by subclass's processUnauthorizedKey.
+ (id)initWithDictionary:(NSDictionary *)dictionary name:(NSString *)name error:(NSError **)error
{
    // may not need this anymore
    if (error != NULL)
       *error = nil;
    
    // handle empty dictionary
    if (!isDictionary(dictionary)) {
        if (error != NULL)
            *error = [NSError OESConfigError:500 description:@"dictionary is empty"];
        return nil;
    } // if

    OESConfigObject *object = [self new];

    object.name = name;

    [object initWithDictionaryWillBegin];

    // evil, stupid or awesome, you be the judge; handles basic values
    for(NSString *key in dictionary) {
        id value = [dictionary objectForKey:key];

        // don't allow unauthorized keys to be set with KVC
        BOOL isAuthorizedKey = [[object authorizedKeys] containsObject:key];
        if (!isAuthorizedKey) {
            //OESLogWarn(@"Skipping unauthorized key '%@' for object '%@'", key, object.name);
            BOOL wasHandled = [object processUnauthorizedKey:key value:value error:error];

            if (!isDerefNil(error))
                return nil;

            // we couldn't processes it so add it as a userInfo record
            if (!wasHandled && [object storeUnauthorizedKeysInUserInfo])
                [object.userInfo setObject:value forKey:key];
            continue;
        } //if

        BOOL wasSet = [object trySetterForKey:key value:value error:error];

        if (!wasSet)
            return (object = nil);
    } // for
    
    // here we will attempt to fill in missing dates from parent
    // if enabled in subclass
    [object overrideDatesForEnabledParent];
    
    BOOL isObjectOk = [object initWithDictionaryDidComplete:dictionary error:error];
    
    return !isObjectOk ? (object = nil) : object;
}

- (BOOL)trySetterForKey:(NSString *)key value:(id)value error:(NSError **)error
{
    SEL setterSelector = NSSelectorFromString(key);
    if ([self respondsToSelector:setterSelector]) {
        BOOL isValid =  [self validateValue:&value forKey:key error:error];
        if (!isValid) {
            *error = [NSError OESConfigError:501 description:[NSString stringWithFormat:@"value for '%@' doesn't match type", key]];
            return NO;
        } // if

        [self setValue:value forKey:key];

        return YES;
    } // if

    return NO;
}

- (NSString *)nameWithoutSubcategory
{
    return [OESConfigObject removeSubcategoryFromObjectName:self.name];
}

+ (NSString *)removeSubcategoryFromObjectName:(NSString *)name
{
    // rangeOfString will throw an exception if string is nil
    if (isNil(name))
        return nil;
        
    NSRange range = [name rangeOfString:@"#"];
    if (range.location == NSNotFound)
        return name;
    
    return [name substringToIndex:range.location];
}

#pragma mark - OESConfigObject Abstract Methods

- (void)initWithDictionaryWillBegin
{
    // abstract default method
    self.enabled = OESConfigObjectEnabledOn;
}

- (BOOL)initWithDictionaryDidComplete:(NSDictionary *)dictionary error:(NSError **)error
{
    return ![self areAnyVariablesMissing:dictionary error:error];
}

- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error
{
    // we own the enabled instance variable so we can handle it
    if ([key isEqualToString:@"enabled"]) {
        if (isString(value)) {
            if ([value isEqualToString:@"auto"])
                self.enabled = OESConfigObjectEnabledAuto;
            else
                self.enabled = [value isEqualToString:@"on"] ? OESConfigObjectEnabledOn : OESConfigObjectEnabledOff;
        } // if
        else if (isNumber(value))
            self.enabled = [(NSNumber *)value intValue] == 1;
        
        return YES;
    } // if

    // abstract default method
    return NO;
}

- (BOOL)storeUnauthorizedKeysInUserInfo
{
    // some objects (like features) can span the tree and process everything
    // others we just want to add unprocessed options to userInfo
    return YES;
}

- (NSArray *)authorizedKeys
{
    @throw [OESConfigException exceptionWithName:NSInternalInconsistencyException
                            reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                             userInfo:nil];
}

- (NSString *)validator
{
    // This abstract method is primarily used to allow this base class to extract and match
    // variables from JSON to the instance variables (via initWithDictionary) for whatever inherited class
    // is initializing.
    return nil;
}

- (void)overrideDatesForEnabledParent
{
    // abstract method
}

#pragma mark - Public

- (OESConfigObjectValidateType)validateVariableForSection:(NSString *)section key:(NSString *)key value:(NSString *)value error:(NSError **)error validHandler:(OESConfigObjectValidHandler)validHandler
{
    // it wasn't a section we're interested in so try for variables we know in mode
    OESConfigVariableParser *validators = [[OESConfig sharedInstance] validators];
    NSDictionary *variables = [validators variablesForSection:section];
    
    OESConfigVariable *variable = [variables objectForKey:key];
    // if it doesn't exist we'll default to putting this variable
    // in the userInfo dictionary
    if (isNil(variable) || ![variable isKindOfClass:[OESConfigVariable class]])
        return OESConfigObjectValidateNotFound;
 
    BOOL isValid = [variable isValidField:value error:error];
    if (!isValid) {
        *error = [NSError OESConfigError:500 description:[NSString stringWithFormat:@"invalid value for key '%@' with value '%@': %@", key, value, *error]];
        return OESConfigObjectValidateInvalid;
    } // if

    if (!isNil(validHandler)) {
        validHandler(variable);
    } // if

    return OESConfigObjectValidateOk;
}

- (BOOL)isBetweenDateRange
{
    BOOL areDatesValid = !isEmpty(self.startDate) && !isEmpty(self.endDate);
    
    // by default if no dates are set, we return YES
    if (!areDatesValid)
        return YES;
    
    NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
    BOOL isBetween = now >= self.startTimeInterval && now <= self.endTimeInterval;
    
    OESLogDebug(@"OESConfigObject '%@': Is timestamp %f between %f and %f? %@", self.name, now, self.startTimeInterval, self.endTimeInterval, boolAsString(isBetween));

    return isBetween;
}

- (BOOL)isEnabled
{
    BOOL isAuto = self.enabled == OESConfigObjectEnabledAuto;
    if (isAuto)
        return [self isBetweenDateRange];
    
    return self.enabled == OESConfigObjectEnabledOn;
}

- (NSString *)isEnabledString
{
    return boolAsString([self isEnabled]);
}

- (NSString *)enabledString
{
    switch(self.enabled) {
        case OESConfigObjectEnabledAuto:
            return @"AUTO";
        case OESConfigObjectEnabledOff:
            return @"OFF";
        case OESConfigObjectEnabledOn:
            return @"ON";
        default:
            return @"UNKNOWN";
    } // switch
}

- (void)overrideDatesWithConfigObject:(OESConfigObject *)configObject
{
    self.startDate = configObject.startDate;
    self.endDate = configObject.endDate;
}

- (BOOL)areAnyVariablesMissing:(NSDictionary *)dictionary error:(NSError **)error
{ 
    if (!isDictionary(dictionary))
        return NO;

    // loop through main variables and validate
    OESConfigVariableParser *validators = [[OESConfig sharedInstance] validators];
    NSDictionary *variables = [validators variablesForSection:[self validator]];

    if (!isDictionary(variables))
        return NO;

    for(NSString *key in variables) {
        OESConfigVariable *variable = [variables objectForKey:key];

        if (![variable isKindOfClass:[OESConfigVariable class]])
            continue;

        id object = [dictionary objectForKey:key];

        BOOL isMissingAndRequied = variable.required && isNil(object);
        if (isMissingAndRequied) {
            if (error != NULL)
                *error = [NSError OESConfigError:500 description:[NSString stringWithFormat:@"missing required variable '%@' in '%@' section: %@ ", key, self.name, [self validator]]];
            return YES;
        } // if
    } // for
    
    return NO;
}

- (BOOL)isForDevicesMatch
{
    NSArray *forDevices = [[OESConfig sharedInstance] forDevices];

    // if forDevices wasn't set in config then default to YES
    // we access the instance variable directly to check to see if it was set
    // to prevent accessor from auto allocating; save resources
    BOOL canWeCompare = isArray(forDevices)
                        && isArray(_forDevices)
                        && [self.forDevices count] > 0;
    if (!canWeCompare)
        return YES;

    for(NSString *device in forDevices) {
        // some one messed up the config they all should be strings
        if (!isString(device))
            continue;

        BOOL isIn = [self.forDevices containsObject:device];
        if (isIn)
            return YES;
    } // for
    
    return NO;
}


#pragma mark - Object Overrides
#pragma mark -- NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigObject name = %@", self.name];
}

#pragma mark - Accessor Overrides

- (NSMutableDictionary *)userInfo
{
    return !isNil(_userInfo) ? _userInfo : (_userInfo = [NSMutableDictionary new]);
}

- (void)setStartDate:(NSDate *)date
{
    _startDate = date;
    self.startTimeInterval = [date timeIntervalSince1970];
}

- (void)setEndDate:(NSDate *)date
{
    _endDate = date;
    self.endTimeInterval = [date timeIntervalSince1970];
}

- (NSArray *)forDevices
{
    return !isNil(_forDevices) ? _forDevices :  (_forDevices = [NSArray new]);
}

@end
