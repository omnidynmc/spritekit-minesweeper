//
//  OESConfigMode.m
//  OESShared
//
//  Created by Gregory Carter on 8/31/12.
//  Copyright (c) 2012 Gregory Carter. All rights reserved.
//
#import "NSDictionary+OESAdditions.h"

#import "OESConfigMode.h"
#import "OESConfigFeature.h"
#import "OESConfigEndpoint.h"
#import "OESConfigVariableParser.h"
#import "OESConfigVariable.h"
#import "OESConfigFeature.h"
#import "OESConfig.h"

@interface OESConfigMode()
@property (nonatomic, strong) NSMutableArray *path;

// Private
// -- Process
- (BOOL)processFeaturesSection:(NSString *)key value:(id)value error:(NSError **)error;
- (BOOL)processEndpointsSection:(NSString *)key value:(id)value error:(NSError **)error;

// -- Inheritence
- (void)inheritFeaturesFromConfigMode:(OESConfigMode *)configMode;
- (void)inheritEndpointsFromConfigMode:(OESConfigMode *)configMode;
@end

@implementation OESConfigMode

#pragma mark - OESConfigObject Overrides

- (void)initWithDictionaryWillBegin
{
    // initialize stuff
    self.inheritFeatures = true;
    self.inheritEndpoints = true;
}

- (BOOL)processUnauthorizedKey:(NSString *)key value:(id)value error:(NSError **)error
{
    if ([super processUnauthorizedKey:key value:value error:error])
        return YES;

    OESLogDebug(@"Unauthorized key '%@' with value '%@'", key, value);

    // these will abort if it's not the correct section or
    // value isn't a dictionary
    __block BOOL wasProcessed = [self processFeaturesSection:key value:value error:error]
                        || [self processEndpointsSection:key value:value error:error];
    if (wasProcessed) return YES;

    // it wasn't a section we're interested in so try for variables we know in mode
    wasProcessed = YES;
    OESConfigObjectValidateType isValid = [self validateVariableForSection:@"modes" key:key value:value error:error validHandler:^(OESConfigVariable *variable) {
            if ([key isEqualToString:@"startDate"])
                self.startDate = [variable parseDate];
            else if ([key isEqualToString:@"endDate"])
                self.endDate = [variable parseDate];
            else if ([key isEqualToString:@"inheritFeatures"])
                self.inheritFeatures = [value isEqualToString:@"on"];
            else if ([key isEqualToString:@"inheritEndpoints"])
                self.inheritEndpoints = [value isEqualToString:@"on"];
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

#pragma mark - Private
#pragma mark -- Process Features

- (BOOL)processFeaturesSection:(NSString *)key value:(id)value error:(NSError **)error
{
    BOOL ok = [key isEqualToString:@"features"] && [value isKindOfClass:[NSDictionary class]];
    if (!ok) return NO;

    [self drillDownDictionaryForFeatures:value];
    
    return YES;
}

- (void)drillDownDictionaryForFeatures:(NSDictionary *)dictionary
{
    if (!isDictionary(dictionary))
        return;

    OESLogDebug(@"processing '%@'", [self currentFeaturePath]);
    
    
    for(NSString *key in dictionary) {
        [self.path addObject:[OESConfigObject removeSubcategoryFromObjectName:key]];
        id object = [dictionary objectForKey:key];

        if (!isNil(object)) {
            NSError *error = nil;
            OESConfigFeature *feature = [self createFeatureFromDictionary:object error:&error];

            if (!isNil(feature)) {
                if (![feature isForDevicesMatch]) {
                    OESLogInfo(@"Ignoring feature: %@, forDevices = %@", [self currentFeaturePath], feature.forDevices);
                } // if
                else {
                    OESLogDebug(@"Adding feature: %@", [self currentFeaturePath]);
                    [self.features setObject:feature forKey:[self currentFeaturePath]];
                } // else
            } // if
        
            if (isDictionary(object))
                [self drillDownDictionaryForFeatures:object];
        } // if
        
        [self.path removeLastObject];
    } // for
}

- (OESConfigFeature *)createFeatureFromDictionary:(id)object error:(NSError **)error
{
    if ([[self currentFeatureName] isEqualToString:@"enabled"])
        return nil;

    OESConfigFeature *feature = nil;

    if (isDictionary(object))
        feature = [OESConfigFeature initWithDictionary:object name:[self currentFeatureName] error:error];
    else if (isString(object))
        feature = [OESConfigFeature initWithString:object name:[self currentFeatureName] error:error];
    else if (isNumber(object))
        feature = [OESConfigFeature initWithDictionary:object name:[self currentFeatureName] error:error];

    if (isNil(feature)) {
        OESLogDebug(@"Could not create feature '%@': %@", [self currentFeatureName], (!isDerefNil(error) ? *error : @"(unknown error)"));
        return nil;
    } // if

    OESLogDebug(@"Feature %@", feature);
    
    return feature;
}

- (OESConfigEndpoint *)createEndpointFromDictionary:(id)object name:(NSString *)name error:(NSError **)error
{
    OESConfigEndpoint *endpoint = nil;

    if (isDictionary(object))
        endpoint = [OESConfigEndpoint initWithDictionary:object name:name error:error];
    else if (isString(object))
        endpoint = [OESConfigEndpoint initWithString:object name:name error:error];

    if (isNil(endpoint)) {
        OESLogDebug(@"Could not create endpoint '%@': %@", name, (!isDerefNil(error) ? *error : @"(unknown error)"));
        return nil;
    } // if

    OESLogDebug(@"Endpoint %@", endpoint);
    
    return endpoint;
}

#pragma mark ---- Feature Path Helpers

- (NSString *)currentFeaturePath
{
    return [self.path componentsJoinedByString:@"."];
}

- (NSString *)currentFeatureName
{
    return [self.path lastObject];
}

#pragma mark -- Process Endpoints

- (BOOL)processEndpointsSection:(NSString *)key value:(id)value error:(NSError **)error
{
    BOOL ok = [key isEqualToString:@"endpoints"] && [value isKindOfClass:[NSDictionary class]];
    if (!ok) return NO;
    
    for(NSString *endpointName in value) {
        id endpointValue = [value objectForKey:endpointName];

        OESConfigEndpoint *endpoint = [self createEndpointFromDictionary:endpointValue name:endpointName error:error];

        if (isNil(endpoint))
            return NO;
        
        if (![endpoint isForDevicesMatch]) {
            OESLogInfo(@"Ignoring endpoint: %@, forDevices = %@", endpointName, endpoint.forDevices);
        } // if
        else {
            OESLogDebug(@"Adding endpoint: %@", endpoint);
            [self.endpoints setObject:endpoint forKey:[endpoint nameWithoutSubcategory]];
        } // else
    } // for
    
    return YES;
}

#pragma mark -- Overrides

- (void)overrideDatesForEnabledParent
{
    NSArray *dictionaries = @[ self.features, self.endpoints ];
    
    for(NSDictionary *dictionary in dictionaries) {
        // step through all of our features and endpoints and override their startDate/endDate values with parent
        for(NSString *key in dictionary) {
            OESConfigObject *configObject = [dictionary objectForKey:key];
            if (configObject.enabled != OESConfigObjectEnabledAuto)
                continue;
            
            BOOL overrideDates = isEmpty(configObject.startDate) && isEmpty(configObject.endDate);
            if (!overrideDates)
                continue;
            
            [configObject overrideDatesWithConfigObject:self];
        } // for
    } // for
}

#pragma mark -- Inheritence

- (void)inheritFeaturesFromConfigMode:(OESConfigMode *)configMode
{
    if (!self.inheritFeatures) {
        OESLogInfo(@"Config mode '%@' has inheritance disabled for features; not inheriting from '%@'", self.name, configMode.name);
        return;
    } // if

    NSDictionary *features = configMode.features;
    for(NSString *featureKey in features) {
        OESConfigFeature *feature = [features objectForKey:featureKey];
        
        // try and locate endpoint in our config
        OESConfigFeature *localFeature = [self.features objectForKey:featureKey];
        if (!isEmpty(localFeature))
            continue;
            
        [self.features setObject:feature forKey:featureKey];
    } // for
    
    OESLogNotice(@"Config mode '%@' has inherited features from '%@'", self.name, configMode.name);
}

- (void)inheritEndpointsFromConfigMode:(OESConfigMode *)configMode
{
    if (!self.inheritEndpoints) {
        OESLogInfo(@"Config mode '%@' has inheritance disabled for endpoints; not inheriting from '%@'", self.name, configMode.name);
        return;
    } // if

    NSDictionary *endpoints = configMode.endpoints;
    for(NSString *endpointKey in endpoints) {
        OESConfigEndpoint *endpoint = [endpoints objectForKey:endpointKey];
        
        // try and locate endpoint in our config
        OESConfigEndpoint *localEndpoint = [self.endpoints objectForKey:endpointKey];
        if (!isEmpty(localEndpoint))
            continue;

        [self.endpoints setObject:endpoint forKey:endpointKey];
    } // for
    
    OESLogNotice(@"Config mode '%@' has inherited endpoints from '%@'", self.name, configMode.name);
}

- (void)inheritDatesFromConfigMode:(OESConfigMode *)configMode
{
    OESLogInfo(@"Config mode '%@' has inheritance disabled for dates; not inheriting from '%@'", self.name, configMode.name);
}

#pragma mark - Public
#pragma mark -- Inheritence

- (void)inheritFromConfigMode:(OESConfigMode *)configMode
{
    OESLogInfo(@"'%@' config mode inheriting from '%@'", self.name, configMode.name);
    
    [self inheritFeaturesFromConfigMode:configMode];
    [self inheritEndpointsFromConfigMode:configMode];
    [self inheritDatesFromConfigMode:configMode];
}

#pragma mark -- Feature Accessors

- (OESConfigFeature *)fetchFeatureByName:(NSString *)name
{
    return [self.features objectForKey:name];
}

- (BOOL)isFeatureEnabled:(NSString *)name default:(BOOL)defaultValue
{
    OESConfigFeature *feature = [self fetchFeatureByName:name];
    return feature ? [feature isEnabled] : defaultValue;
}

- (BOOL)isFeatureEnabled:(NSString *)name
{
    return [[self fetchFeatureByName:name] isEnabled];
}

#pragma mark -- Endpoint Accessors

- (OESConfigEndpoint *)fetchEndpointByName:(NSString *)name
{
    return [self.endpoints objectForKey:name];
}

- (NSTimeInterval)refreshIntervalForEndpoint:(NSString *)name default:(NSTimeInterval)defaultInterval
{
    OESConfigEndpoint *endpoint = [self fetchEndpointByName:name];
    return (!isNil(endpoint) && !isNil([endpoint refreshInterval]) ? [endpoint.refreshInterval doubleValue] : defaultInterval);
}

- (NSString *)urlForEndpoint:(NSString *)name default:(NSString *)defaultValue
{
    OESConfigEndpoint *endpoint = [self fetchEndpointByName:name];
    return !isNil(endpoint) && !isNil([endpoint url]) ? [endpoint url] : defaultValue;
}

- (NSString *)urlForEndpoint:(NSString *)name
{
    return [self urlForEndpoint:name default:nil];
}

#pragma mark - NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"OESConfigMode name = %@, enabled = %@, active = %@, startDate = %@, endDate = %@, features = %@, endpoints = %@", self.name, [self enabledString], [self isEnabledString], self.startDate, self.endDate, self.features, self.endpoints];
}

#pragma mark - Accessor Overrides

- (NSMutableDictionary *)features
{
    return !isNil(_features) ? _features : (_features = [NSMutableDictionary new]);
}

- (NSMutableDictionary *)endpoints
{
    return !isNil(_endpoints) ? _endpoints : (_endpoints = [NSMutableDictionary new]);
}

- (NSMutableArray *)path
{
    return !isNil(_path) ? _path : (_path = [NSMutableArray new]);
}

@end
